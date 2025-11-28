const { validationResult } = require('express-validator');

const formatErrors = (errors) =>
  errors.array().map((error) => ({
    field: error.param,
    message: error.msg,
  }));

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(400).json({
      errors: formatErrors(errors),
    });
  }

  return next();
};

module.exports = validateRequest;
