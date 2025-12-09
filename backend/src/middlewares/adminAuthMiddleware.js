const adminToken = process.env.ADMIN_DASHBOARD_TOKEN || 'vintastep-admin';

const requireAdminToken = (req, res, next) => {
  const headerToken = req.headers['x-admin-token'];

  if (!headerToken || headerToken !== adminToken) {
    return res.status(401).json({ message: 'Admin token missing or invalid' });
  }

  return next();
};

module.exports = {
  requireAdminToken,
};
