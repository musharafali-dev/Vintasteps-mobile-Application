const express = require('express');
const { body } = require('express-validator');

const authController = require('../controllers/authController');
const validateRequest = require('../middlewares/validateRequest');

const router = express.Router();

const emailValidator = body('email')
  .exists({ checkFalsy: true })
  .withMessage('email is required')
  .bail()
  .isEmail()
  .withMessage('email must be valid')
  .bail()
  .normalizeEmail();

const passwordValidator = body('password')
  .exists({ checkFalsy: true })
  .withMessage('password is required')
  .bail()
  .isLength({ min: 8 })
  .withMessage('password must be at least 8 characters long');

router.post(
  '/api/v1/auth/register',
  [emailValidator, passwordValidator],
  validateRequest,
  authController.register,
);

router.post(
  '/api/v1/auth/login',
  [emailValidator, passwordValidator],
  validateRequest,
  authController.login,
);

module.exports = router;
