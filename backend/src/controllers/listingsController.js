const listingsService = require('../services/listingsService');

const DEFAULT_RADIUS_KM = 10;

const getNearbyListings = async (req, res, next) => {
  try {
    const latitude = typeof req.query.lat === 'number' ? req.query.lat : parseFloat(req.query.lat);
    const longitude = typeof req.query.lon === 'number' ? req.query.lon : parseFloat(req.query.lon);
    const radiusKmRaw =
      typeof req.query.radiusKm === 'number' ? req.query.radiusKm : parseFloat(req.query.radiusKm);

    const radiusKm = Number.isFinite(radiusKmRaw) ? radiusKmRaw : DEFAULT_RADIUS_KM;

    const listings = await listingsService.findNearby({
      latitude,
      longitude,
      radiusKm,
    });

    return res.status(200).json({
      data: listings,
      meta: {
        latitude,
        longitude,
        radiusKm,
        count: listings.length,
      },
    });
  } catch (error) {
    return next(error);
  }
};

const createListing = async (req, res, next) => {
  try {
    const { title, price, latitude, longitude, images = [] } = req.body;

    const listing = await listingsService.createListing({
      sellerId: req.user.id,
      title,
      price,
      latitude,
      longitude,
      images,
    });

    return res.status(201).json({ data: listing });
  } catch (error) {
    return next(error);
  }
};

const updateListing = async (req, res, next) => {
  try {
    const listing = await listingsService.updateListing({
      listingId: req.params.id,
      sellerId: req.user.id,
      updates: req.body,
    });

    return res.status(200).json({ data: listing });
  } catch (error) {
    return next(error);
  }
};

const deleteListing = async (req, res, next) => {
  try {
    await listingsService.deleteListing({
      listingId: req.params.id,
      sellerId: req.user.id,
    });

    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  getNearbyListings,
  createListing,
  updateListing,
  deleteListing,
};
