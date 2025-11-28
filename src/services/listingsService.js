const { v4: uuidv4 } = require('uuid');
const { pool } = require('../config/db');

const MAX_RADIUS_KM = 200;
const MIN_RADIUS_KM = 0.1;
const MAX_RESULTS = 100;
const DEFAULT_LATITUDE = 34.0522;
const DEFAULT_LONGITUDE = -118.2437;

const LISTING_STATUS = {
  ACTIVE: 'ACTIVE',
  RESERVED: 'RESERVED',
  SOLD: 'SOLD',
};

const parseImages = (raw) => {
  if (!raw) {
    return [];
  }

  if (Array.isArray(raw)) {
    return raw;
  }

  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch (err) {
    return [];
  }
};

const serializeListing = (row) => ({
  id: row.id,
  sellerId: row.seller_id,
  title: row.title,
  price: Number(row.price),
  status: row.status,
  images: parseImages(row.images),
  location: {
    latitude: row.latitude,
    longitude: row.longitude,
  },
});

const buildHttpError = (status, message) => {
  const error = new Error(message);
  error.status = status;
  return error;
};

const findNearby = async ({ latitude, longitude, radiusKm }) => {
  const boundedRadiusKm = Math.min(Math.max(radiusKm, MIN_RADIUS_KM), MAX_RADIUS_KM);
  const radiusMeters = boundedRadiusKm * 1000;

  const sql = `
    SELECT
      l.id,
      l.seller_id,
      l.title,
      l.price,
      l.status,
      l.images,
      ST_X(l.location) AS longitude,
      ST_Y(l.location) AS latitude,
      ST_Distance_Sphere(l.location, POINT(?, ?)) AS distance_meters
    FROM listings l
    WHERE l.status = 'ACTIVE'
      AND ST_Distance_Sphere(l.location, POINT(?, ?)) <= ?
    ORDER BY distance_meters ASC
    LIMIT ?
  `;

  const params = [longitude, latitude, longitude, latitude, radiusMeters, MAX_RESULTS];
  const [rows] = await pool.execute(sql, params);

  return rows.map((row) => ({
    ...serializeListing(row),
    distanceKm: Number((row.distance_meters / 1000).toFixed(3)),
  }));
};

const selectListingByIdSql = `
  SELECT
    id,
    seller_id,
    title,
    price,
    status,
    images,
    ST_Y(location) AS latitude,
    ST_X(location) AS longitude
  FROM listings
  WHERE id = ?
`;

const getListingById = async (id) => {
  const [rows] = await pool.execute(selectListingByIdSql, [id]);
  return rows[0] ? serializeListing(rows[0]) : null;
};

const normalizeImages = (images = []) => JSON.stringify(Array.isArray(images) ? images : []);

const clampCoordinate = (value, { fallback, min, max }) => {
  const numeric = typeof value === 'number' ? value : Number.parseFloat(value);
  if (!Number.isFinite(numeric)) {
    return fallback;
  }
  if (numeric < min || numeric > max) {
    return fallback;
  }
  return numeric;
};

const createListing = async ({ sellerId, title, price, latitude, longitude, images }) => {
  const listingId = uuidv4();
  const resolvedLatitude = clampCoordinate(latitude, {
    fallback: DEFAULT_LATITUDE,
    min: -90,
    max: 90,
  });
  const resolvedLongitude = clampCoordinate(longitude, {
    fallback: DEFAULT_LONGITUDE,
    min: -180,
    max: 180,
  });

  await pool.execute(
    `INSERT INTO listings (id, seller_id, title, price, status, location, images)
     VALUES (?, ?, ?, ?, ?, POINT(?, ?), ?)`,
    [
      listingId,
      sellerId,
      title,
      price,
      LISTING_STATUS.ACTIVE,
      resolvedLongitude,
      resolvedLatitude,
      normalizeImages(images),
    ],
  );

  return getListingById(listingId);
};

const updateListing = async ({ listingId, sellerId, updates }) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [listingRows] = await connection.execute(
      `${selectListingByIdSql} FOR UPDATE`,
      [listingId],
    );

    if (!listingRows.length) {
      throw buildHttpError(404, 'Listing not found');
    }

    if (listingRows[0].seller_id !== sellerId) {
      throw buildHttpError(403, 'You do not own this listing');
    }

    const fields = [];
    const params = [];

    if (Object.prototype.hasOwnProperty.call(updates, 'title')) {
      fields.push('title = ?');
      params.push(updates.title);
    }

    if (Object.prototype.hasOwnProperty.call(updates, 'price')) {
      fields.push('price = ?');
      params.push(updates.price);
    }

    if (Object.prototype.hasOwnProperty.call(updates, 'images')) {
      fields.push('images = ?');
      params.push(normalizeImages(updates.images));
    }

    if (
      Object.prototype.hasOwnProperty.call(updates, 'latitude') &&
      Object.prototype.hasOwnProperty.call(updates, 'longitude')
    ) {
      fields.push('location = POINT(?, ?)');
      params.push(
        clampCoordinate(updates.longitude, {
          fallback: DEFAULT_LONGITUDE,
          min: -180,
          max: 180,
        }),
        clampCoordinate(updates.latitude, {
          fallback: DEFAULT_LATITUDE,
          min: -90,
          max: 90,
        }),
      );
    }

    if (!fields.length) {
      await connection.rollback();
      return serializeListing(listingRows[0]);
    }

    params.push(listingId);

    await connection.execute(`UPDATE listings SET ${fields.join(', ')} WHERE id = ?`, params);

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const listing = await getListingById(listingId);
  if (!listing) {
    throw buildHttpError(404, 'Listing not found after update');
  }

  return listing;
};

const deleteListing = async ({ listingId, sellerId }) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [listingRows] = await connection.execute(
      'SELECT seller_id FROM listings WHERE id = ? FOR UPDATE',
      [listingId],
    );

    if (!listingRows.length) {
      throw buildHttpError(404, 'Listing not found');
    }

    if (listingRows[0].seller_id !== sellerId) {
      throw buildHttpError(403, 'You do not own this listing');
    }

    await connection.execute('DELETE FROM listings WHERE id = ?', [listingId]);

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
};

module.exports = {
  findNearby,
  createListing,
  updateListing,
  deleteListing,
  LISTING_STATUS,
};
