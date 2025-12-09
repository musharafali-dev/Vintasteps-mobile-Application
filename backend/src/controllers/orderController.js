const orderService = require('../services/orderService');

const listOrders = async (req, res, next) => {
  try {
    const orders = await orderService.listOrdersForUser(req.user.id);
    return res.status(200).json({ data: orders });
  } catch (error) {
    return next(error);
  }
};

const createOrder = async (req, res, next) => {
  try {
    const { listingId, quantity } = req.body;

    const order = await orderService.createOrder({
      listingId,
      buyerId: req.user.id,
      quantity,
    });

    return res.status(201).json({ data: order });
  } catch (error) {
    return next(error);
  }
};

const checkoutCart = async (req, res, next) => {
  try {
    const { items } = req.body;

    const orders = await orderService.checkoutCart({
      buyerId: req.user.id,
      items,
    });

    return res.status(201).json({ data: orders });
  } catch (error) {
    return next(error);
  }
};

const markShipped = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { trackingNumber } = req.body;

    const order = await orderService.markShipped({
      orderId,
      sellerId: req.user.id,
      trackingNumber,
    });

    return res.status(200).json({ data: order });
  } catch (error) {
    return next(error);
  }
};

const completeOrder = async (req, res, next) => {
  try {
    const { orderId } = req.params;

    const result = await orderService.completeOrderAndReleaseFunds({
      orderId,
      buyerId: req.user.id,
    });

    return res.status(200).json({ data: result.order, payout: result.payout });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  listOrders,
  createOrder,
  checkoutCart,
  markShipped,
  completeOrder,
};
