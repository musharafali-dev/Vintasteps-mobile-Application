const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { pool } = require('../config/db');

const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

const serializeUser = (row) => ({
  id: row.id,
  email: row.email,
  isPhoneVerified: Boolean(row.is_phone_verified),
  stripeConnectId: row.stripe_connect_id,
  rating: row.rating !== null && row.rating !== undefined ? Number(row.rating) : null,
});

const buildHttpError = (status, message) => {
  const error = new Error(message);
  error.status = status;
  return error;
};

const ensureJwtSecret = () => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET env var is not configured');
  }

  return process.env.JWT_SECRET;
};

const fetchUserByEmail = async (email) => {
  const [rows] = await pool.execute(
    `SELECT id, email, password_hash, is_phone_verified, stripe_connect_id, rating FROM users WHERE email = ? LIMIT 1`,
    [email],
  );

  return rows[0] || null;
};

const fetchUserPublicById = async (id) => {
  const [rows] = await pool.execute(
    `SELECT id, email, is_phone_verified, stripe_connect_id, rating FROM users WHERE id = ? LIMIT 1`,
    [id],
  );

  return rows[0] ? serializeUser(rows[0]) : null;
};

const generateToken = (userId) =>
  jwt.sign({ sub: userId }, ensureJwtSecret(), { expiresIn: JWT_EXPIRES_IN });

const registerUser = async ({ email, password }) => {
  const normalizedEmail = email.trim().toLowerCase();
  const existingUser = await fetchUserByEmail(normalizedEmail);

  if (existingUser) {
    throw buildHttpError(409, 'Email already in use');
  }

  const userId = uuidv4();
  const passwordHash = await bcrypt.hash(password, 12);

  await pool.execute(
    `INSERT INTO users (id, email, password_hash, is_phone_verified, stripe_connect_id, rating)
     VALUES (?, ?, ?, 0, NULL, 0)`,
    [userId, normalizedEmail, passwordHash],
  );

  const user = await fetchUserPublicById(userId);
  const token = generateToken(user.id);

  return { user, token };
};

const loginUser = async ({ email, password }) => {
  const normalizedEmail = email.trim().toLowerCase();
  const userRecord = await fetchUserByEmail(normalizedEmail);

  if (!userRecord) {
    throw buildHttpError(401, 'Invalid credentials');
  }

  if (!userRecord.password_hash) {
    throw buildHttpError(401, 'Invalid credentials');
  }

  const isMatch = await bcrypt.compare(password, userRecord.password_hash);

  if (!isMatch) {
    throw buildHttpError(401, 'Invalid credentials');
  }

  const user = serializeUser(userRecord);
  const token = generateToken(user.id);

  return { user, token };
};

module.exports = {
  registerUser,
  loginUser,
};
