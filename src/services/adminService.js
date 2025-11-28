const fs = require('fs/promises');
const path = require('path');

const { pool } = require('../config/db');
const authService = require('./authService');
const orderService = require('./orderService');

const SCHEMA_PATH = path.resolve(__dirname, '../scripts/schema.sql');

const splitStatements = (sql) =>
  sql
    .split(/;\s*(?:\r?\n|$)/)
    .map((statement) => statement.trim())
    .filter(Boolean);

const getDashboardSummary = async () => {
  const [[users]] = await pool.execute('SELECT COUNT(*) AS total FROM users');
  const [[listings]] = await pool.execute('SELECT COUNT(*) AS total FROM listings');
  const [[orders]] = await pool.execute('SELECT COUNT(*) AS total FROM orders');
  const [[pendingOrders]] = await pool.execute(
    "SELECT COUNT(*) AS total FROM orders WHERE status IN ('pending_payment','pending_shipment')",
  );

  return {
    totalUsers: users.total,
    totalListings: listings.total,
    totalOrders: orders.total,
    pendingOrders: pendingOrders.total,
  };
};

const getRecentUsers = async (limit = 20) => {
  const [rows] = await pool.execute(
    `SELECT id, email, created_at FROM users ORDER BY created_at DESC LIMIT ?`,
    [limit],
  );
  return rows;
};

const searchUsers = async (query) => {
  const like = `%${query.toLowerCase()}%`;
  const [rows] = await pool.execute(
    `SELECT id, email, full_name, created_at
       FROM users
      WHERE LOWER(email) LIKE ? OR id LIKE ?
      ORDER BY created_at DESC
      LIMIT 20`,
    [like, like],
  );
  return rows;
};

const getUserDetail = async (userId) => {
  const [users] = await pool.execute(
    `SELECT id, email, full_name, phone, is_phone_verified, rating, created_at
       FROM users
      WHERE id = ?
      LIMIT 1`,
    [userId],
  );

  if (!users.length) {
    return null;
  }

  const user = users[0];

  const [[orderStats]] = await pool.execute(
    `SELECT COUNT(*) AS totalOrders, COALESCE(SUM(total_amount), 0) AS grossVolume
       FROM orders
      WHERE buyer_id = ? OR seller_id = ?`,
    [userId, userId],
  );

  const [[listingStats]] = await pool.execute(
    `SELECT COUNT(*) AS totalListings
       FROM listings
      WHERE seller_id = ?`,
    [userId],
  );

  const [recentOrders] = await pool.execute(
    `SELECT id, status, total_amount, placed_at
       FROM orders
      WHERE buyer_id = ? OR seller_id = ?
      ORDER BY placed_at DESC
      LIMIT 5`,
    [userId, userId],
  );

  const [recentListings] = await pool.execute(
    `SELECT id, title, price, status, created_at
       FROM listings
      WHERE seller_id = ?
      ORDER BY created_at DESC
      LIMIT 5`,
    [userId],
  );

  return {
    ...user,
    orderStats,
    listingStats,
    recentOrders,
    recentListings,
  };
};

const registerUser = async ({ email, password }) => {
  const result = await authService.registerUser({ email, password });
  return result.user;
};

const getOrders = async ({ status, limit = 25 }) => {
  const filters = [];
  const params = [];

  if (status) {
    filters.push('status = ?');
    params.push(status);
  }

  params.push(limit);

  const [rows] = await pool.execute(
    `SELECT id, listing_id, buyer_id, seller_id, status, total_amount, placed_at
       FROM orders
      ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''}
      ORDER BY placed_at DESC
      LIMIT ?`,
    params,
  );

  return rows;
};

const updateOrderStatus = async ({ orderId, status }) => {
  const updatedOrder = await orderService.adminUpdateOrderStatus({ orderId, status });
  return updatedOrder;
};

const confirmOrder = async ({ orderId }) => {
  const confirmation = await orderService.adminConfirmOrder({ orderId });
  return confirmation;
};

const getDbMetrics = async () => {
  const [tables] = await pool.execute(
    `SELECT table_name AS tableName, table_rows AS estimatedRows
       FROM information_schema.tables
      WHERE table_schema = DATABASE()
      ORDER BY table_name ASC`,
  );

  const [[uptime]] = await pool.execute('SHOW STATUS LIKE "Uptime"');

  return {
    tables,
    uptimeSeconds: Number(uptime.Value || 0),
  };
};

const reseedDatabase = async () => {
  const sql = await fs.readFile(SCHEMA_PATH, 'utf8');
  const statements = splitStatements(sql);

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    for (const statement of statements) {
      await connection.query(statement);
    }
    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }

  return { executedStatements: statements.length };
};

const exportDatabaseSnapshot = async () => {
  const [users] = await pool.execute(
    'SELECT id, email, created_at FROM users ORDER BY created_at DESC LIMIT 50',
  );
  const [listings] = await pool.execute(
    'SELECT id, title, price, status, created_at FROM listings ORDER BY created_at DESC LIMIT 50',
  );
  const [orders] = await pool.execute(
    'SELECT id, status, total_amount, placed_at FROM orders ORDER BY placed_at DESC LIMIT 50',
  );

  return {
    generatedAt: new Date().toISOString(),
    users,
    listings,
    orders,
  };
};

// Categories
const getCategories = async () => {
  const [rows] = await pool.execute(
    `SELECT id, name, slug, description, parent_id, icon_url, display_order, is_active, created_at
       FROM categories
      ORDER BY display_order ASC, name ASC`,
  );
  return rows;
};

const createCategory = async ({ name, slug, description, displayOrder = 0 }) => {
  const { v4: uuidv4 } = require('uuid');
  const id = uuidv4();
  
  await pool.execute(
    `INSERT INTO categories (id, name, slug, description, display_order)
     VALUES (?, ?, ?, ?, ?)`,
    [id, name, slug, description || null, displayOrder],
  );

  const [rows] = await pool.execute('SELECT * FROM categories WHERE id = ?', [id]);
  return rows[0];
};

const updateCategory = async ({ categoryId, name, slug, description, displayOrder, isActive }) => {
  const updates = [];
  const params = [];

  if (name !== undefined) {
    updates.push('name = ?');
    params.push(name);
  }
  if (slug !== undefined) {
    updates.push('slug = ?');
    params.push(slug);
  }
  if (description !== undefined) {
    updates.push('description = ?');
    params.push(description);
  }
  if (displayOrder !== undefined) {
    updates.push('display_order = ?');
    params.push(displayOrder);
  }
  if (isActive !== undefined) {
    updates.push('is_active = ?');
    params.push(isActive ? 1 : 0);
  }

  params.push(categoryId);

  await pool.execute(
    `UPDATE categories SET ${updates.join(', ')} WHERE id = ?`,
    params,
  );

  const [rows] = await pool.execute('SELECT * FROM categories WHERE id = ?', [categoryId]);
  return rows[0];
};

const deleteCategory = async (categoryId) => {
  await pool.execute('DELETE FROM categories WHERE id = ?', [categoryId]);
  return { deleted: true };
};

// Reports
const getReports = async ({ status, limit = 50 }) => {
  const filters = [];
  const params = [];

  if (status) {
    filters.push('status = ?');
    params.push(status);
  }

  params.push(limit);

  const [rows] = await pool.execute(
    `SELECT r.*, u1.email as reporter_email, u2.email as reported_user_email, 
            l.title as reported_listing_title
       FROM reports r
       LEFT JOIN users u1 ON r.reporter_id = u1.id
       LEFT JOIN users u2 ON r.reported_user_id = u2.id
       LEFT JOIN listings l ON r.reported_listing_id = l.id
      ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''}
      ORDER BY r.created_at DESC
      LIMIT ?`,
    params,
  );

  return rows;
};

const updateReportStatus = async ({ reportId, status, resolvedBy, resolutionNotes }) => {
  const updates = ['status = ?'];
  const params = [status];

  if (status === 'resolved' || status === 'dismissed') {
    updates.push('resolved_at = NOW()');
    if (resolvedBy) {
      updates.push('resolved_by = ?');
      params.push(resolvedBy);
    }
    if (resolutionNotes) {
      updates.push('resolution_notes = ?');
      params.push(resolutionNotes);
    }
  }

  params.push(reportId);

  await pool.execute(
    `UPDATE reports SET ${updates.join(', ')} WHERE id = ?`,
    params,
  );

  const [rows] = await pool.execute('SELECT * FROM reports WHERE id = ?', [reportId]);
  return rows[0];
};

// Listings Management
const getListings = async ({ status, limit = 50 }) => {
  const filters = [];
  const params = [];

  if (status) {
    filters.push('l.status = ?');
    params.push(status);
  }

  params.push(limit);

  const [rows] = await pool.execute(
    `SELECT l.*, u.email as seller_email
       FROM listings l
       LEFT JOIN users u ON l.seller_id = u.id
      ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''}
      ORDER BY l.created_at DESC
      LIMIT ?`,
    params,
  );

  return rows;
};

const updateListingStatus = async ({ listingId, status }) => {
  await pool.execute(
    'UPDATE listings SET status = ? WHERE id = ?',
    [status, listingId],
  );

  const [rows] = await pool.execute('SELECT * FROM listings WHERE id = ?', [listingId]);
  return rows[0];
};

const deleteListing = async (listingId) => {
  await pool.execute('DELETE FROM listings WHERE id = ?', [listingId]);
  return { deleted: true };
};

// Notifications
const getNotifications = async ({ userId, limit = 50 }) => {
  const filters = [];
  const params = [];

  if (userId) {
    filters.push('user_id = ?');
    params.push(userId);
  }

  params.push(limit);

  const [rows] = await pool.execute(
    `SELECT * FROM notifications
      ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''}
      ORDER BY created_at DESC
      LIMIT ?`,
    params,
  );

  return rows;
};

const createNotification = async ({ userId, type, title, body, data = null }) => {
  const { v4: uuidv4 } = require('uuid');
  const id = uuidv4();

  await pool.execute(
    `INSERT INTO notifications (id, user_id, type, title, body, data)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [id, userId, type, title, body, data ? JSON.stringify(data) : null],
  );

  const [rows] = await pool.execute('SELECT * FROM notifications WHERE id = ?', [id]);
  return rows[0];
};

// Analytics
const getAnalytics = async ({ eventType, startDate, endDate, limit = 100 }) => {
  const filters = [];
  const params = [];

  if (eventType) {
    filters.push('event_type = ?');
    params.push(eventType);
  }
  if (startDate) {
    filters.push('created_at >= ?');
    params.push(startDate);
  }
  if (endDate) {
    filters.push('created_at <= ?');
    params.push(endDate);
  }

  params.push(limit);

  const [rows] = await pool.execute(
    `SELECT event_type, COUNT(*) as count, DATE(created_at) as date
       FROM analytics_events
      ${filters.length ? `WHERE ${filters.join(' AND ')}` : ''}
      GROUP BY event_type, DATE(created_at)
      ORDER BY created_at DESC
      LIMIT ?`,
    params,
  );

  return rows;
};

module.exports = {
  getDashboardSummary,
  getRecentUsers,
  searchUsers,
  getUserDetail,
  registerUser,
  getOrders,
  updateOrderStatus,
  confirmOrder,
  getDbMetrics,
  reseedDatabase,
  exportDatabaseSnapshot,
  // Categories
  getCategories,
  createCategory,
  updateCategory,
  deleteCategory,
  // Reports
  getReports,
  updateReportStatus,
  // Listings
  getListings,
  updateListingStatus,
  deleteListing,
  // Notifications
  getNotifications,
  createNotification,
  // Analytics
  getAnalytics,
};
