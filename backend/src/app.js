const express = require('express');
const helmet = require('helmet');
const morgan = require('morgan');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const listingsRoutes = require('./routes/listingsRoutes');
const orderRoutes = require('./routes/orderRoutes');
const adminRoutes = require('./routes/adminRoutes');
const { protect } = require('./middlewares/authMiddleware');

dotenv.config();

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*', methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'] }));
app.use(express.json({ limit: '1mb' }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.static(path.resolve(__dirname, 'public')));

const isPublicRoute = (req) => {
  const method = req.method.toUpperCase();
  const path = req.path;

  const authPaths = ['/api/v1/auth/register', '/api/v1/auth/login'];
  if (method === 'POST' && authPaths.includes(path)) {
    return true;
  }

  if (method === 'GET' && path === '/api/v1/listings/nearby') {
    return true;
  }

  if (path.startsWith('/api/v1/admin') || path.startsWith('/admin')) {
    return true;
  }

  return false;
};

app.use((req, res, next) => {
  if (isPublicRoute(req)) {
    return next();
  }
  return protect(req, res, next);
});

app.use(authRoutes);
app.use(listingsRoutes);
app.use(orderRoutes);
app.use(adminRoutes);

app.use((req, res) => res.status(404).json({ message: 'Route not found' }));

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  const status = err.status || 500;
  const message = err.message || 'Internal server error';
  return res.status(status).json({ message });
});

module.exports = app;
