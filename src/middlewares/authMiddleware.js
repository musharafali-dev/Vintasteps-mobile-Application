const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

const selectUserByIdSql = `
  SELECT id, email, is_phone_verified, stripe_connect_id, rating
  FROM users
  WHERE id = ?
  LIMIT 1
`;

const ensureJwtSecret = () => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET env var is not configured');
  }

  return process.env.JWT_SECRET;
};

const mapUser = (row) => ({
  id: row.id,
  email: row.email,
  isPhoneVerified: Boolean(row.is_phone_verified),
  stripeConnectId: row.stripe_connect_id,
  rating: row.rating !== null && row.rating !== undefined ? Number(row.rating) : null,
});

const unauthorizedResponse = (res, message = 'Not authorized') =>
  res.status(401).json({ message });

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || '';

    if (!authHeader.startsWith('Bearer ')) {
      return unauthorizedResponse(res);
    }

    const token = authHeader.split(' ')[1]?.trim();

    if (!token) {
      return unauthorizedResponse(res);
    }

    const payload = jwt.verify(token, ensureJwtSecret(), {
      algorithms: [(process.env.JWT_ALGORITHM || 'HS256').trim()],
    });

    if (!payload?.sub) {
      return unauthorizedResponse(res);
    }

    if (!payload.exp || Date.now() >= payload.exp * 1000) {
      return unauthorizedResponse(res, 'Invalid or expired token');
    }

    const [rows] = await pool.execute(selectUserByIdSql, [payload.sub]);

    if (!rows.length) {
      return unauthorizedResponse(res);
    }

    req.user = mapUser(rows[0]);

    return next();
  } catch (error) {
    if (error.name === 'TokenExpiredError' || error.name === 'JsonWebTokenError') {
      return unauthorizedResponse(res, 'Invalid or expired token');
    }

    return next(error);
  }
};

module.exports = { protect };
