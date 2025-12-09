const app = require('./app');
const { pool } = require('./config/db');

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    const connection = await pool.getConnection();
    connection.release();
    console.log('✅ Database connection successful.');

    app.listen(PORT, () => {
      console.log(`🚀 VintaStep API running securely on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('❌ Failed to connect to DB or start server:', error.message);
    process.exit(1);
  }
};

startServer();
