const express = require('express');
const { query, body, param } = require('express-validator');

const listingsController = require('../controllers/listingsController');
const validateRequest = require('../middlewares/validateRequest');
const { protect } = require('../middlewares/authMiddleware');

const router = express.Router();

router.get(
  '/api/v1/listings/nearby',
  [
    query('lat')
      .exists({ checkFalsy: true })
      .withMessage('lat is required')
      .bail()
      .isFloat({ min: -90, max: 90 })
      .withMessage('lat must be a valid latitude between -90 and 90')
      .toFloat(),
    query('lon')
      .exists({ checkFalsy: true })
      .withMessage('lon is required')
      .bail()
      .isFloat({ min: -180, max: 180 })
      .withMessage('lon must be a valid longitude between -180 and 180')
      .toFloat(),
    query('radiusKm')
      .optional()
      .isFloat({ min: 0.1, max: 200 })
      .withMessage('radiusKm must be between 0.1km and 200km')
      .toFloat(),
  ],
  validateRequest,
  listingsController.getNearbyListings,
);

router.post(
  '/api/v1/listings',
  protect,
  [
    body('title')
      .exists({ checkFalsy: true })
      .withMessage('title is required')
      .bail()
      .isLength({ min: 3, max: 120 })
      .withMessage('title must be between 3 and 120 characters'),
    body('price')
      .exists({ checkFalsy: true })
      .withMessage('price is required')
      .bail()
      .isFloat({ min: 0.5 })
      .withMessage('price must be at least 0.5')
      .toFloat(),
    body('images')
      .optional()
      .isArray({ max: 12 })
      .withMessage('images must be an array with up to 12 entries'),
  ],
  validateRequest,
  listingsController.createListing,
);

router.put(
  '/api/v1/listings/:id',
  protect,
  [
    param('id').isUUID().withMessage('listing id must be a valid UUID'),
    body('title')
      .optional()
      .isLength({ min: 3, max: 120 })
      .withMessage('title must be between 3 and 120 characters'),
    body('price')
      .optional()
      .isFloat({ min: 0.5 })
      .withMessage('price must be at least 0.5')
      .toFloat(),
    body('latitude')
      .optional()
      .isFloat({ min: -90, max: 90 })
      .withMessage('latitude must be valid')
      .toFloat(),
    body('longitude')
      .optional()
      .isFloat({ min: -180, max: 180 })
      .withMessage('longitude must be valid')
      .toFloat(),
    body('images')
      .optional()
      .isArray({ max: 12 })
      .withMessage('images must be an array with up to 12 entries'),
  ],
  (req, res, next) => {
    const hasLat = Object.prototype.hasOwnProperty.call(req.body, 'latitude');
    const hasLon = Object.prototype.hasOwnProperty.call(req.body, 'longitude');
    if (hasLat !== hasLon) {
      return res.status(400).json({ message: 'latitude and longitude must both be provided together' });
    }
    return validateRequest(req, res, next);
  },
  listingsController.updateListing,
);

router.delete(
  '/api/v1/listings/:id',
  protect,
  [param('id').isUUID().withMessage('listing id must be a valid UUID')],
  validateRequest,
  listingsController.deleteListing,
);

module.exports = router;
