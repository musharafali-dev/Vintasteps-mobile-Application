const path = require('path');
const adminService = require('../services/adminService');

const renderDashboard = (req, res) => {
  return res.sendFile(path.resolve(__dirname, '../public/admin-dashboard.html'));
};

const getDashboardSummary = async (req, res, next) => {
  try {
    const summary = await adminService.getDashboardSummary();
    return res.status(200).json({ data: summary });
  } catch (error) {
    return next(error);
  }
};

const listUsers = async (req, res, next) => {
  try {
    const users = await adminService.getRecentUsers();
    return res.status(200).json({ data: users });
  } catch (error) {
    return next(error);
  }
};

const searchUsers = async (req, res, next) => {
  try {
    const query = String(req.query.q || '').trim();
    if (!query) {
      return res.status(400).json({ message: 'q (query) is required' });
    }
    const users = await adminService.searchUsers(query);
    return res.status(200).json({ data: users });
  } catch (error) {
    return next(error);
  }
};

const getUserDetail = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const detail = await adminService.getUserDetail(userId);
    if (!detail) {
      return res.status(404).json({ message: 'User not found' });
    }
    return res.status(200).json({ data: detail });
  } catch (error) {
    return next(error);
  }
};

const createUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'email and password are required' });
    }

    const user = await adminService.registerUser({ email, password });
    return res.status(201).json({ data: user });
  } catch (error) {
    return next(error);
  }
};

const listOrders = async (req, res, next) => {
  try {
    const { status } = req.query;
    const orders = await adminService.getOrders({ status });
    return res.status(200).json({ data: orders });
  } catch (error) {
    return next(error);
  }
};

const updateOrderStatus = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ message: 'status is required' });
    }

    const order = await adminService.updateOrderStatus({ orderId, status });
    return res.status(200).json({ data: order });
  } catch (error) {
    return next(error);
  }
};

const confirmOrder = async (req, res, next) => {
  try {
    const { orderId } = req.params;
    const confirmation = await adminService.confirmOrder({ orderId });
    return res.status(200).json({ data: confirmation });
  } catch (error) {
    return next(error);
  }
};

const getDbMetrics = async (req, res, next) => {
  try {
    const metrics = await adminService.getDbMetrics();
    return res.status(200).json({ data: metrics });
  } catch (error) {
    return next(error);
  }
};

const reseedDatabase = async (req, res, next) => {
  try {
    const result = await adminService.reseedDatabase();
    return res.status(200).json({ data: result });
  } catch (error) {
    return next(error);
  }
};

const exportDatabase = async (req, res, next) => {
  try {
    const snapshot = await adminService.exportDatabaseSnapshot();
    return res.status(200).json({ data: snapshot });
  } catch (error) {
    return next(error);
  }
};

// Categories
const listCategories = async (req, res, next) => {
  try {
    const categories = await adminService.getCategories();
    return res.status(200).json({ data: categories });
  } catch (error) {
    return next(error);
  }
};

const createCategory = async (req, res, next) => {
  try {
    const { name, slug, description, displayOrder } = req.body;
    if (!name || !slug) {
      return res.status(400).json({ message: 'name and slug are required' });
    }
    const category = await adminService.createCategory({ name, slug, description, displayOrder });
    return res.status(201).json({ data: category });
  } catch (error) {
    return next(error);
  }
};

const updateCategory = async (req, res, next) => {
  try {
    const { categoryId } = req.params;
    const updates = req.body;
    const category = await adminService.updateCategory({ categoryId, ...updates });
    return res.status(200).json({ data: category });
  } catch (error) {
    return next(error);
  }
};

const deleteCategory = async (req, res, next) => {
  try {
    const { categoryId } = req.params;
    const result = await adminService.deleteCategory(categoryId);
    return res.status(200).json({ data: result });
  } catch (error) {
    return next(error);
  }
};

// Reports
const listReports = async (req, res, next) => {
  try {
    const { status, limit } = req.query;
    const reports = await adminService.getReports({ status, limit: limit ? parseInt(limit) : undefined });
    return res.status(200).json({ data: reports });
  } catch (error) {
    return next(error);
  }
};

const updateReport = async (req, res, next) => {
  try {
    const { reportId } = req.params;
    const { status, resolutionNotes } = req.body;
    const report = await adminService.updateReportStatus({
      reportId,
      status,
      resolvedBy: req.adminId, // Assuming middleware sets this
      resolutionNotes,
    });
    return res.status(200).json({ data: report });
  } catch (error) {
    return next(error);
  }
};

// Listings
const listListings = async (req, res, next) => {
  try {
    const { status, limit } = req.query;
    const listings = await adminService.getListings({ status, limit: limit ? parseInt(limit) : undefined });
    return res.status(200).json({ data: listings });
  } catch (error) {
    return next(error);
  }
};

const updateListing = async (req, res, next) => {
  try {
    const { listingId } = req.params;
    const { status } = req.body;
    const listing = await adminService.updateListingStatus({ listingId, status });
    return res.status(200).json({ data: listing });
  } catch (error) {
    return next(error);
  }
};

const deleteListing = async (req, res, next) => {
  try {
    const { listingId } = req.params;
    const result = await adminService.deleteListing(listingId);
    return res.status(200).json({ data: result });
  } catch (error) {
    return next(error);
  }
};

// Notifications
const listNotifications = async (req, res, next) => {
  try {
    const { userId, limit } = req.query;
    const notifications = await adminService.getNotifications({ userId, limit: limit ? parseInt(limit) : undefined });
    return res.status(200).json({ data: notifications });
  } catch (error) {
    return next(error);
  }
};

const sendNotification = async (req, res, next) => {
  try {
    const { userId, type, title, body, data } = req.body;
    if (!userId || !type || !title) {
      return res.status(400).json({ message: 'userId, type, and title are required' });
    }
    const notification = await adminService.createNotification({ userId, type, title, body, data });
    return res.status(201).json({ data: notification });
  } catch (error) {
    return next(error);
  }
};

// Analytics
const getAnalytics = async (req, res, next) => {
  try {
    const { eventType, startDate, endDate, limit } = req.query;
    const analytics = await adminService.getAnalytics({
      eventType,
      startDate,
      endDate,
      limit: limit ? parseInt(limit) : undefined,
    });
    return res.status(200).json({ data: analytics });
  } catch (error) {
    return next(error);
  }
};

module.exports = {
  renderDashboard,
  getDashboardSummary,
  listUsers,
  searchUsers,
  getUserDetail,
  createUser,
  listOrders,
  updateOrderStatus,
  confirmOrder,
  getDbMetrics,
  reseedDatabase,
  exportDatabase,
  // Categories
  listCategories,
  createCategory,
  updateCategory,
  deleteCategory,
  // Reports
  listReports,
  updateReport,
  // Listings
  listListings,
  updateListing,
  deleteListing,
  // Notifications
  listNotifications,
  sendNotification,
  // Analytics
  getAnalytics,
};
