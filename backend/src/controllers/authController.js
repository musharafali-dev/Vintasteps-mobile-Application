const authService = require('../services/authService');

const register = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await authService.registerUser({ email, password });

    return res.status(201).json({
      data: result.user,
      token: result.token,
    });
  } catch (error) {
    return next(error);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const result = await authService.loginUser({ email, password });

    return res.status(200).json({
      data: result.user,
      token: result.token,
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  register,
  login,
};
