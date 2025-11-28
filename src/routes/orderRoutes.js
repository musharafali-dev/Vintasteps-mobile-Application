const express = require('express');
const { body, param } = require('express-validator');

const orderController = require('../controllers/orderController');
const validateRequest = require('../middlewares/validateRequest');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router();

router.get('/api/v1/orders', protect, orderController.listOrders);

router.post(
  '/api/v1/orders',
  protect,
  [
    body('listingId')
      .exists({ checkFalsy: true })
      .withMessage('listingId is required')
      .bail()
      .isUUID()
      .withMessage('listingId must be a valid UUID'),
    body('quantity')
      .optional()
      .isInt({ min: 1, max: 10 })
      .withMessage('quantity must be between 1 and 10')
      .toInt(),
  ],
  validateRequest,
  orderController.createOrder,
);

router.post(
  '/api/v1/orders/checkout',
  protect,
  [
    body('items')
      .isArray({ min: 1 })
      .withMessage('items must be a non-empty array'),
    body('items.*.listingId')
      .exists({ checkFalsy: true })
      .withMessage('listingId is required for each item')
      .bail()
      .isUUID()
      .withMessage('Each listingId must be a valid UUID'),
    body('items.*.quantity')
      .optional()
      .isInt({ min: 1, max: 10 })
      .withMessage('quantity must be between 1 and 10')
      .toInt(),
  ],
  validateRequest,
  orderController.checkoutCart,
);

router.put(
  '/api/v1/orders/:orderId/ship',
  protect,
  [
    param('orderId').isUUID().withMessage('orderId must be a valid UUID'),
    body('trackingNumber')
      .optional()
      .isLength({ min: 3, max: 128 })
      .withMessage('trackingNumber must be between 3 and 128 characters'),
  ],
  validateRequest,
  orderController.markShipped,
);

router.post(
  '/api/v1/orders/:orderId/complete',
  protect,
  [param('orderId').isUUID().withMessage('orderId must be a valid UUID')],
  validateRequest,
  orderController.completeOrder,
);

module.exports = router;
