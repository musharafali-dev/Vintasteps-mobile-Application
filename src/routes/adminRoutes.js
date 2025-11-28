const express = require('express');
const adminController = require('../controllers/adminController');
const { requireAdminToken } = require('../middlewares/adminAuthMiddleware');

const router = express.Router();

// Serve the new admin dashboard
router.get('/admin', adminController.renderDashboard);
router.get('/admin/v2', (req, res) => {
  return res.sendFile(require('path').resolve(__dirname, '../public/admin-dashboard-v2.html'));
});

// Protect all admin API routes
router.use('/api/v1/admin', requireAdminToken);

// Dashboard & Users
router.get('/api/v1/admin/dashboard', adminController.getDashboardSummary);
router.get('/api/v1/admin/users', adminController.listUsers);
router.get('/api/v1/admin/users/search', adminController.searchUsers);
router.get('/api/v1/admin/users/:userId', adminController.getUserDetail);
router.post('/api/v1/admin/users', adminController.createUser);

// Orders
router.get('/api/v1/admin/orders', adminController.listOrders);
router.post('/api/v1/admin/orders/:orderId/status', adminController.updateOrderStatus);
router.post('/api/v1/admin/orders/:orderId/confirm', adminController.confirmOrder);

// Categories
router.get('/api/v1/admin/categories', adminController.listCategories);
router.post('/api/v1/admin/categories', adminController.createCategory);
router.put('/api/v1/admin/categories/:categoryId', adminController.updateCategory);
router.delete('/api/v1/admin/categories/:categoryId', adminController.deleteCategory);

// Reports
router.get('/api/v1/admin/reports', adminController.listReports);
router.put('/api/v1/admin/reports/:reportId', adminController.updateReport);

// Listings
router.get('/api/v1/admin/listings', adminController.listListings);
router.put('/api/v1/admin/listings/:listingId', adminController.updateListing);
router.delete('/api/v1/admin/listings/:listingId', adminController.deleteListing);

// Notifications
router.get('/api/v1/admin/notifications', adminController.listNotifications);
router.post('/api/v1/admin/notifications', adminController.sendNotification);

// Analytics
router.get('/api/v1/admin/analytics', adminController.getAnalytics);

// Database
router.get('/api/v1/admin/db/metrics', adminController.getDbMetrics);
router.post('/api/v1/admin/db/reseed', adminController.reseedDatabase);
router.get('/api/v1/admin/db/export', adminController.exportDatabase);

module.exports = router;
