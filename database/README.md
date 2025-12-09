# VintaSteps Database (MySQL)

Database schema and initialization scripts for the VintaSteps marketplace.

## Overview

This directory contains all database-related files:

- `schema.sql` - MySQL database schema definition
- `initDb.js` - Node.js script to initialize the database
- `README.md` - This file

## Tech Stack
- **Database:** MySQL 8.0+
- **Engine:** InnoDB
- **Charset:** utf8mb4 (supports emojis & international characters)

## Database Schema

### Core Tables

#### Users
Stores buyer and seller user accounts.

```sql
CREATE TABLE users (
  id CHAR(36) NOT NULL PRIMARY KEY,           -- UUID
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(120) NULL,
  phone VARCHAR(20) NULL,
  is_phone_verified TINYINT(1) DEFAULT 0,
  stripe_connect_id VARCHAR(120) NULL,
  rating DECIMAL(3,2) DEFAULT 0,              -- Average rating (0-5)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

#### Listings
Product listings with geospatial location support.

```sql
CREATE TABLE listings (
  id CHAR(36) NOT NULL PRIMARY KEY,
  seller_id CHAR(36) NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT NULL,
  price DECIMAL(10,2) NOT NULL,
  condition_label VARCHAR(60) NULL,           -- e.g., "Like New", "Good", "Fair"
  status ENUM('ACTIVE','RESERVED','SOLD'),
  location POINT NOT NULL,                    -- Geospatial: (latitude, longitude)
  images JSON NOT NULL,                       -- Array of image URLs
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,
  CONSTRAINT fk_listings_seller FOREIGN KEY (seller_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- Spatial index for location-based queries
CREATE SPATIAL INDEX listings_location_idx ON listings (location);
```

#### Orders
Purchase orders containing multiple items.

```sql
CREATE TABLE orders (
  id CHAR(36) NOT NULL PRIMARY KEY,
  buyer_id CHAR(36) NOT NULL,
  seller_id CHAR(36) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status ENUM('PENDING','CONFIRMED','SHIPPED','DELIVERED','CANCELLED'),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,
  CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_id) REFERENCES users(id),
  CONSTRAINT fk_orders_seller FOREIGN KEY (seller_id) REFERENCES users(id)
) ENGINE=InnoDB;
```

#### Order Items
Line items in an order.

```sql
CREATE TABLE order_items (
  id CHAR(36) NOT NULL PRIMARY KEY,
  order_id CHAR(36) NOT NULL,
  listing_id CHAR(36) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  price_at_purchase DECIMAL(10,2) NOT NULL,  -- Price snapshot at order time
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id),
  CONSTRAINT fk_order_items_listing FOREIGN KEY (listing_id) REFERENCES listings(id)
) ENGINE=InnoDB;
```

#### Conversations & Messages
Chat between buyers and sellers.

```sql
CREATE TABLE conversations (
  id CHAR(36) NOT NULL PRIMARY KEY,
  listing_id CHAR(36) NOT NULL,
  buyer_id CHAR(36) NOT NULL,
  seller_id CHAR(36) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversations_listing FOREIGN KEY (listing_id) REFERENCES listings(id),
  CONSTRAINT fk_conversations_buyer FOREIGN KEY (buyer_id) REFERENCES users(id),
  CONSTRAINT fk_conversations_seller FOREIGN KEY (seller_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE messages (
  id CHAR(36) NOT NULL PRIMARY KEY,
  conversation_id CHAR(36) NOT NULL,
  sender_id CHAR(36) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id),
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id)
) ENGINE=InnoDB;
```

#### Reviews
Product and seller reviews.

```sql
CREATE TABLE reviews (
  id CHAR(36) NOT NULL PRIMARY KEY,
  listing_id CHAR(36) NOT NULL,
  reviewer_id CHAR(36) NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reviews_listing FOREIGN KEY (listing_id) REFERENCES listings(id),
  CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id)
) ENGINE=InnoDB;
```

#### Admin Users
Admin account management.

```sql
CREATE TABLE admin_users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('SUPER_ADMIN','MODERATOR','SUPPORT') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
```

#### Categories
Product categories for listings.

```sql
CREATE TABLE categories (
  id CHAR(36) NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE listing_categories (
  listing_id CHAR(36) NOT NULL,
  category_id CHAR(36) NOT NULL,
  PRIMARY KEY (listing_id, category_id),
  CONSTRAINT fk_listing_categories_listing FOREIGN KEY (listing_id) REFERENCES listings(id),
  CONSTRAINT fk_listing_categories_category FOREIGN KEY (category_id) REFERENCES categories(id)
) ENGINE=InnoDB;
```

#### Analytics & Monitoring
Tracking and notifications.

```sql
CREATE TABLE analytics_events (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NULL,
  event_type VARCHAR(50) NOT NULL,              -- e.g., 'listing_viewed', 'purchase'
  event_data JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_analytics_events_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE notifications (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  type VARCHAR(50) NOT NULL,                    -- e.g., 'order_status', 'message'
  content TEXT NOT NULL,
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;
```

#### Moderation & Reporting
User and content reporting system.

```sql
CREATE TABLE reports (
  id CHAR(36) NOT NULL PRIMARY KEY,
  reported_by CHAR(36) NOT NULL,
  reported_user_id CHAR(36) NULL,
  listing_id CHAR(36) NULL,
  reason VARCHAR(100) NOT NULL,
  description TEXT NULL,
  status ENUM('OPEN','INVESTIGATING','RESOLVED','DISMISSED') DEFAULT 'OPEN',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reports_reported_by FOREIGN KEY (reported_by) REFERENCES users(id),
  CONSTRAINT fk_reports_reported_user FOREIGN KEY (reported_user_id) REFERENCES users(id),
  CONSTRAINT fk_reports_listing FOREIGN KEY (listing_id) REFERENCES listings(id)
) ENGINE=InnoDB;

CREATE TABLE user_verification (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL UNIQUE,
  id_document_url VARCHAR(255) NULL,
  verification_status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_verification_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;
```

## Initialization

### Via Node.js Script

Run the initialization from the **backend** directory:

```bash
cd ../backend
npm run init-db
```

This executes `initDb.js` which:
1. Reads `../database/schema.sql`
2. Drops existing tables (if any)
3. Creates all tables with proper foreign keys & indexes
4. Seeds demo data (optional)

### Manual MySQL Setup

If running directly in MySQL:

```bash
# 1. Create database
mysql -u root -p
CREATE DATABASE vintastep_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vintastep_db;

# 2. Import schema
SOURCE /path/to/schema.sql;

# 3. Verify tables
SHOW TABLES;
```

## Geospatial Queries

The `listings` table uses MySQL's spatial support for location-based searches.

### Find Listings Near User

```sql
-- Find all listings within 5km radius
SELECT * FROM listings 
WHERE ST_Distance_Sphere(
  location, 
  ST_PointFromText(CONCAT('POINT(', ?, ' ', ?, ')'))
) < 5000;  -- Distance in meters
```

### Index Optimization

```sql
-- Check spatial index
SHOW INDEX FROM listings;

-- Rebuild if needed
OPTIMIZE TABLE listings;
```

## Backup & Restore

### Backup Database

```bash
mysqldump -u root -p vintastep_db > backup.sql
```

### Restore Database

```bash
mysql -u root -p vintastep_db < backup.sql
```

## Common Operations

### Reset Database (Development Only)

```bash
# From backend directory
npm run init-db

# Or manually
DROP DATABASE vintastep_db;
CREATE DATABASE vintastep_db CHARACTER SET utf8mb4;
USE vintastep_db;
SOURCE ../database/schema.sql;
```

### Add User (Test)

```sql
INSERT INTO users (id, email, password_hash, full_name, phone, is_phone_verified, rating)
VALUES (
  UUID(),
  'buyer@example.com',
  '$2a$12$...',  -- bcrypt hash
  'John Buyer',
  '+1234567890',
  1,
  4.5
);
```

### Query Listings by Category

```sql
SELECT DISTINCT l.* FROM listings l
JOIN listing_categories lc ON l.id = lc.listing_id
JOIN categories c ON lc.category_id = c.id
WHERE c.name = 'Clothing';
```

## Performance Tuning

### Key Indexes

Ensure these indexes exist (created in schema):

```sql
-- Listing location (geospatial)
CREATE SPATIAL INDEX listings_location_idx ON listings (location);

-- User lookups
CREATE INDEX idx_users_email ON users(email);

-- Order queries
CREATE INDEX idx_orders_buyer_id ON orders(buyer_id);
CREATE INDEX idx_orders_seller_id ON orders(seller_id);

-- Message queries
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
```

### Connection Pooling

Backend uses connection pooling (in `../backend/src/config/db.js`) for optimal performance.

## Security

- ✅ Foreign key constraints
- ✅ Data types prevent overflow attacks
- ✅ InnoDB for transaction support
- ⚠️ Implement SQL parameterized queries in backend (prevent injection)
- ⚠️ Encrypt sensitive fields if needed (e.g., stripe_connect_id)

## Monitoring

### Check Table Sizes

```sql
SELECT TABLE_NAME, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS "Size (MB)"
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'vintastep_db'
ORDER BY (data_length + index_length) DESC;
```

### Slow Queries

Enable slow query log to identify performance issues:

```bash
# In mysql config (my.cnf / my.ini)
[mysqld]
slow_query_log = 1
long_query_time = 2
slow_query_log_file = /var/log/mysql/slow-query.log
```

## Migration Scripts

For schema changes in production, create migration files:

```javascript
// migrations/001_add_field.js
module.exports = {
  up: async (connection) => {
    await connection.query('ALTER TABLE users ADD COLUMN new_field VARCHAR(255)');
  },
  down: async (connection) => {
    await connection.query('ALTER TABLE users DROP COLUMN new_field');
  }
};
```

## License

Internal project – license terms pending.

## Support

For database issues, check backend logs in `../backend/`.
