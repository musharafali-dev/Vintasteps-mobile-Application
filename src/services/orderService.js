const { v4: uuidv4 } = require('uuid');
const { pool } = require('../config/db');

const ORDER_STATUS = {
  PENDING_PAYMENT: 'pending_payment',
  PENDING_SHIPMENT: 'pending_shipment',
  SHIPPED: 'shipped',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
};

const LISTING_STATUS = {
  ACTIVE: 'ACTIVE',
  RESERVED: 'RESERVED',
  SOLD: 'SOLD',
};

const buildHttpError = (status, message) => {
  const error = new Error(message);
  error.status = status;
  return error;
};

const serializeOrder = (row) => ({
  id: row.id,
  listingId: row.listing_id,
  buyerId: row.buyer_id,
  sellerId: row.seller_id,
  status: row.status,
  totalAmount: Number(row.total_amount),
  trackingNumber: row.tracking_number,
  fundsReleasedAt: row.funds_released_at,
  placedAt: row.placed_at,
  shippedAt: row.shipped_at,
  deliveredAt: row.delivered_at,
});

const fetchListingForUpdateSql = `
  SELECT id, seller_id, title, price, status
  FROM listings
  WHERE id = ?
  FOR UPDATE
`;

const reserveListingSql = `
  UPDATE listings
  SET status = ?
  WHERE id = ?
`;

const insertOrderSql = `
  INSERT INTO orders (id, listing_id, buyer_id, seller_id, status, total_amount, tracking_number)
  VALUES (?, ?, ?, ?, ?, ?, NULL)
`;

const insertOrderItemSql = `
  INSERT INTO order_items (order_id, label, price, quantity)
  VALUES (?, ?, ?, ?)
`;

const updateOrderStatusSql = `
  UPDATE orders
  SET status = ?, tracking_number = ?, funds_released_at = NULL
  WHERE id = ?
`;

const selectOrderByIdSql = `
  SELECT id, listing_id, buyer_id, seller_id, status, total_amount, tracking_number, funds_released_at, placed_at, shipped_at, delivered_at
  FROM orders
  WHERE id = ?
  LIMIT 1
`;

const selectOrderForUpdateSql = `${selectOrderByIdSql} FOR UPDATE`;

const selectOrderHistorySql = `
  SELECT
    o.id,
    o.listing_id,
    o.buyer_id,
    o.seller_id,
    o.status,
    o.total_amount AS price,
    o.placed_at,
    o.shipped_at,
    o.delivered_at,
    l.title AS listing_title,
    COALESCE(JSON_UNQUOTE(JSON_EXTRACT(l.images, '$[0]')), '') AS thumbnail_url
  FROM orders o
  INNER JOIN listings l ON l.id = o.listing_id
  WHERE o.buyer_id = ? OR o.seller_id = ?
  ORDER BY o.placed_at DESC
  LIMIT 100
`;

const fetchOrderById = async (orderId) => {
  const [rows] = await pool.execute(selectOrderByIdSql, [orderId]);
  return rows[0] ? serializeOrder(rows[0]) : null;
};

const normalizeQuantity = (quantity) => {
  const parsed = Number.parseInt(quantity, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return 1;
  }
  return Math.min(parsed, 10);
};

const createOrderRecord = async ({ connection, listingId, buyerId, quantity = 1 }) => {
  const orderId = uuidv4();
  const [listingRows] = await connection.execute(fetchListingForUpdateSql, [listingId]);

  if (!listingRows.length) {
    throw buildHttpError(404, 'Listing not found');
  }

  const listing = listingRows[0];

  if (listing.status !== LISTING_STATUS.ACTIVE) {
    throw buildHttpError(400, 'Listing is not available for purchase');
  }

  const resolvedQuantity = normalizeQuantity(quantity);
  const listingPrice = Number(listing.price);
  const totalAmount = listingPrice * resolvedQuantity;
  const initialStatus = totalAmount > 0 ? ORDER_STATUS.PENDING_PAYMENT : ORDER_STATUS.PENDING_SHIPMENT;

  await connection.execute(reserveListingSql, [LISTING_STATUS.RESERVED, listingId]);

  await connection.execute(insertOrderSql, [
    orderId,
    listingId,
    buyerId,
    listing.seller_id,
    initialStatus,
    totalAmount,
  ]);

  await connection.execute(insertOrderItemSql, [
    orderId,
    listing.title,
    listingPrice,
    resolvedQuantity,
  ]);

  return orderId;
};

const createOrder = async ({ listingId, buyerId, quantity = 1 }) => {
  const connection = await pool.getConnection();
  let orderId;

  try {
    await connection.beginTransaction();
    orderId = await createOrderRecord({ connection, listingId, buyerId, quantity });
    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const order = await fetchOrderById(orderId);
  if (!order) {
    throw buildHttpError(500, 'Order persistence failure');
  }

  return { ...order, escrowStatus: 'funds_held' };
};

const checkoutCart = async ({ buyerId, items = [] }) => {
  if (!Array.isArray(items) || items.length === 0) {
    throw buildHttpError(400, 'At least one item is required to checkout');
  }

  const connection = await pool.getConnection();
  const orderIds = [];

  try {
    await connection.beginTransaction();

    for (const item of items) {
      const { listingId, quantity = 1 } = item;
      if (!listingId) {
        throw buildHttpError(400, 'listingId is required for each item');
      }
      const orderId = await createOrderRecord({
        connection,
        listingId,
        buyerId,
        quantity,
      });
      orderIds.push(orderId);
    }

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const orders = await Promise.all(orderIds.map((id) => fetchOrderById(id)));
  const resolvedOrders = orders.filter(Boolean).map((order) => ({ ...order, escrowStatus: 'funds_held' }));

  if (!resolvedOrders.length) {
    throw buildHttpError(500, 'Unable to load created orders');
  }

  return resolvedOrders;
};

const markShipped = async ({ orderId, sellerId, trackingNumber }) => {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [orderRows] = await connection.execute(selectOrderForUpdateSql, [orderId]);

    if (!orderRows.length) {
      throw buildHttpError(404, 'Order not found');
    }

    const order = orderRows[0];

    if (order.seller_id !== sellerId) {
      throw buildHttpError(403, 'You are not authorized to update this order');
    }

    if (
      order.status !== ORDER_STATUS.PENDING_SHIPMENT &&
      order.status !== ORDER_STATUS.PENDING_PAYMENT
    ) {
      throw buildHttpError(400, `Order cannot be marked shipped from status ${order.status}`);
    }

    await connection.execute(updateOrderStatusSql, [ORDER_STATUS.SHIPPED, trackingNumber || null, orderId]);

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const updatedOrder = await fetchOrderById(orderId);
  if (!updatedOrder) {
    throw buildHttpError(500, 'Order not found after update');
  }

  return { ...updatedOrder, escrowStatus: 'funds_held' };
};

const completeOrderAndReleaseFunds = async ({ orderId, buyerId }, options = {}) => {
  const skipBuyerValidation = Boolean(options.skipBuyerValidation);
  if (!orderId) {
    throw buildHttpError(400, 'orderId is required');
  }

  if (!buyerId) {
    throw buildHttpError(400, 'buyerId is required');
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [orderRows] = await connection.execute(selectOrderForUpdateSql, [orderId]);

    if (!orderRows.length) {
      throw buildHttpError(404, 'Order not found');
    }

    const order = orderRows[0];

    if (!skipBuyerValidation) {
      if (order.buyer_id !== buyerId) {
        throw buildHttpError(403, 'Only the buyer can confirm delivery');
      }
    }

    if (order.status !== ORDER_STATUS.SHIPPED) {
      throw buildHttpError(400, 'Order must be shipped before completion');
    }

    const payoutAmount = Number(order.total_amount);
    if (!Number.isFinite(payoutAmount)) {
      throw buildHttpError(400, 'Order total amount is invalid');
    }

    await connection.execute(
      `UPDATE orders
         SET status = ?,
             delivered_at = COALESCE(delivered_at, NOW()),
             funds_released_at = NOW()
       WHERE id = ?`,
      [ORDER_STATUS.COMPLETED, orderId],
    );

    await connection.execute(
      'UPDATE listings SET status = ? WHERE id = ?',
      [LISTING_STATUS.SOLD, order.listing_id],
    );

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const completedOrder = await fetchOrderById(orderId);
  if (!completedOrder) {
    throw buildHttpError(500, 'Order not found after completion');
  }

  return {
    order: completedOrder,
    payout: {
      orderId: completedOrder.id,
      listingId: completedOrder.listingId,
      sellerId: completedOrder.sellerId,
      buyerId: completedOrder.buyerId,
      amount: completedOrder.totalAmount,
      currency: 'USD',
      releasedAt: completedOrder.fundsReleasedAt,
      status: 'ready_for_payout',
      note: 'Funds held in escrow have been released to the seller.',
    },
  };
};

const listOrdersForUser = async (userId) => {
  const [rows] = await pool.execute(selectOrderHistorySql, [userId, userId]);

  return rows.map((row) => ({
    id: row.id,
    listing_id: row.listing_id,
    listing_title: row.listing_title,
    thumbnail_url: row.thumbnail_url,
    price: Number(row.price),
    status: row.status,
    seller_id: row.seller_id,
    buyer_id: row.buyer_id,
    placed_at: row.placed_at,
    shipped_at: row.shipped_at,
    delivered_at: row.delivered_at,
  }));
};

const adminConfirmOrder = async ({ orderId }) => {
  if (!orderId) {
    throw buildHttpError(400, 'orderId is required');
  }

  const order = await fetchOrderById(orderId);
  if (!order) {
    throw buildHttpError(404, 'Order not found');
  }

  return completeOrderAndReleaseFunds(
    { orderId, buyerId: order.buyerId },
    { skipBuyerValidation: true },
  );
};

const adminUpdateOrderStatus = async ({ orderId, status }) => {
  if (!orderId) {
    throw buildHttpError(400, 'orderId is required');
  }

  if (!Object.values(ORDER_STATUS).includes(status)) {
    throw buildHttpError(400, `Unsupported status ${status}`);
  }

  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [orderRows] = await connection.execute(selectOrderForUpdateSql, [orderId]);

    if (!orderRows.length) {
      throw buildHttpError(404, 'Order not found');
    }

    const order = orderRows[0];

    await connection.execute(
      `UPDATE orders
         SET status = ?,
             shipped_at = CASE WHEN ? = ? THEN COALESCE(shipped_at, NOW()) ELSE shipped_at END,
             delivered_at = CASE WHEN ? = ? THEN COALESCE(delivered_at, NOW()) ELSE delivered_at END,
             funds_released_at = CASE WHEN ? = ? THEN COALESCE(funds_released_at, NOW()) ELSE funds_released_at END
       WHERE id = ?`,
      [
        status,
        status,
        ORDER_STATUS.SHIPPED,
        status,
        ORDER_STATUS.COMPLETED,
        status,
        ORDER_STATUS.COMPLETED,
        orderId,
      ],
    );

    if (status === ORDER_STATUS.COMPLETED) {
      await connection.execute('UPDATE listings SET status = ? WHERE id = ?', [LISTING_STATUS.SOLD, order.listing_id]);
    }

    if (status === ORDER_STATUS.CANCELLED) {
      await connection.execute('UPDATE listings SET status = ? WHERE id = ?', [LISTING_STATUS.ACTIVE, order.listing_id]);
    }

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  const updatedOrder = await fetchOrderById(orderId);
  if (!updatedOrder) {
    throw buildHttpError(500, 'Order not found after admin update');
  }

  return updatedOrder;
};

module.exports = {
  createOrder,
  markShipped,
  completeOrderAndReleaseFunds,
  listOrdersForUser,
  checkoutCart,
  adminUpdateOrderStatus,
  adminConfirmOrder,
};
