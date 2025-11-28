-- VintaStep definitive schema
-- Run via npm run init-db (uses this script)

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS listings;
DROP TABLE IF EXISTS conversations;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS user_verification;
DROP TABLE IF EXISTS analytics_events;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS reports;
DROP TABLE IF EXISTS listing_categories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS admin_users;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(120) NULL,
  phone VARCHAR(20) NULL,
  is_phone_verified TINYINT(1) NOT NULL DEFAULT 0,
  stripe_connect_id VARCHAR(120) NULL,
  rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE listings (
  id CHAR(36) NOT NULL PRIMARY KEY,
  seller_id CHAR(36) NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT NULL,
  price DECIMAL(10,2) NOT NULL,
  condition_label VARCHAR(60) NULL,
  status ENUM('ACTIVE','RESERVED','SOLD') NOT NULL DEFAULT 'ACTIVE',
  location POINT NOT NULL,
  images JSON NOT NULL DEFAULT (JSON_ARRAY()),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL,
  CONSTRAINT fk_listings_seller FOREIGN KEY (seller_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE SPATIAL INDEX listings_location_idx ON listings (location);

CREATE TABLE orders (
  id CHAR(36) NOT NULL PRIMARY KEY,
  listing_id CHAR(36) NOT NULL,
  buyer_id CHAR(36) NOT NULL,
  seller_id CHAR(36) NOT NULL,
  status ENUM('pending_payment','pending_shipment','shipped','completed','cancelled') NOT NULL DEFAULT 'pending_payment',
  total_amount DECIMAL(10,2) NOT NULL,
  tracking_number VARCHAR(160) NULL,
  escrow_locked TINYINT(1) NOT NULL DEFAULT 0,
  funds_released_at TIMESTAMP NULL,
  shipped_at TIMESTAMP NULL,
  delivered_at TIMESTAMP NULL,
  placed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_listing FOREIGN KEY (listing_id) REFERENCES listings(id),
  CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_id) REFERENCES users(id),
  CONSTRAINT fk_orders_seller FOREIGN KEY (seller_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  order_id CHAR(36) NOT NULL,
  label VARCHAR(160) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE conversations (
  id CHAR(36) NOT NULL PRIMARY KEY,
  listing_id CHAR(36) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_conversations_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE messages (
  id CHAR(36) NOT NULL PRIMARY KEY,
  conversation_id CHAR(36) NOT NULL,
  sender_id CHAR(36) NOT NULL,
  body TEXT NOT NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reviews (
  id CHAR(36) NOT NULL PRIMARY KEY,
  order_id CHAR(36) NOT NULL,
  reviewer_id CHAR(36) NOT NULL,
  reviewee_id CHAR(36) NOT NULL,
  rating DECIMAL(2,1) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_review_per_order (order_id, reviewer_id),
  CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id),
  CONSTRAINT fk_reviews_reviewee FOREIGN KEY (reviewee_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed data for local development
INSERT INTO users (id, email, password_hash, full_name, phone, is_phone_verified)
VALUES
  ('user-1', 'buyer@example.com', '$2a$10$TNBvOrf5DMCd77sIm9.hAu9hIGHnoPA/63HTW1NGD1NrvKKmFnHhi', 'Ava Buyer', '+1234567890', 1),
  ('user-2', 'seller@example.com', '$2a$10$TNBvOrf5DMCd77sIm9.hAu9hIGHnoPA/63HTW1NGD1NrvKKmFnHhi', 'Noah Seller', '+1234567891', 1);

INSERT INTO listings (id, seller_id, title, description, price, condition_label, status, location, images)
VALUES
  (
    'listing-1',
    'user-2',
    'Vintage Denim Jacket',
    'Classic blue denim jacket in great condition.',
    120.00,
    'Excellent',
    'ACTIVE',
    POINT(-122.4194, 37.7749),
    JSON_ARRAY('https://images.unsplash.com/photo-1483985988355-763728e1935b')
  ),
  (
    'listing-2',
    'user-2',
    'Heritage Leather Boots',
    'Hand-burnished leather boots with a timeless silhouette.',
    185.00,
    'Excellent',
    'ACTIVE',
    POINT(-73.935242, 40.73061),
    JSON_ARRAY('https://images.unsplash.com/photo-1500904156668-758cff89dcff')
  ),
  (
    'listing-3',
    'user-2',
    'Retro Runner 95s',
    'Lightweight mesh upper with marshmallow outsole comfort.',
    90.00,
    'Great',
    'ACTIVE',
    POINT(-0.1276, 51.5072),
    JSON_ARRAY('https://images.unsplash.com/photo-1475180098004-ca77a66827be')
  ),
  (
    'listing-4',
    'user-2',
    'Sunset Suede Loafers',
    'Soft suede with hand-stitched apron and cushioned footbed.',
    110.00,
    'Excellent',
    'ACTIVE',
    POINT(-118.2437, 34.0522),
    JSON_ARRAY('https://images.unsplash.com/photo-1521572163474-6864f9cf17ab')
  ),
  (
    'listing-5',
    'user-2',
    'Nordic Trail Hikers',
    'Vibram outsole and weatherproof nubuck built for winter.',
    150.00,
    'Good',
    'ACTIVE',
    POINT(10.7522, 59.9139),
    JSON_ARRAY('https://images.unsplash.com/photo-1441986300917-64674bd600d8')
  ),
  (
    'listing-6',
    'user-2',
    'Celeste Studio Heels',
    'Sculpted heel with satin upper and memory foam insole.',
    135.00,
    'Excellent',
    'ACTIVE',
    POINT(2.3522, 48.8566),
    JSON_ARRAY('https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb')
  );

INSERT INTO orders (id, listing_id, buyer_id, seller_id, status, total_amount, tracking_number, escrow_locked, shipped_at)
VALUES ('order-1', 'listing-1', 'user-1', 'user-2', 'shipped', 120.00, 'TRACK123', 1, NOW());

INSERT INTO order_items (order_id, label, price, quantity)
VALUES ('order-1', 'Vintage Denim Jacket', 120.00, 1);

-- Additional tables for enhanced admin functionality

CREATE TABLE admin_users (
  id CHAR(36) NOT NULL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(120) NULL,
  role ENUM('super_admin','admin','moderator') NOT NULL DEFAULT 'admin',
  permissions JSON NOT NULL DEFAULT (JSON_ARRAY()),
  last_login_at TIMESTAMP NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categories (
  id CHAR(36) NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NULL,
  parent_id CHAR(36) NULL,
  icon_url VARCHAR(255) NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE listing_categories (
  listing_id CHAR(36) NOT NULL,
  category_id CHAR(36) NOT NULL,
  PRIMARY KEY (listing_id, category_id),
  CONSTRAINT fk_listing_categories_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE,
  CONSTRAINT fk_listing_categories_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reports (
  id CHAR(36) NOT NULL PRIMARY KEY,
  reporter_id CHAR(36) NOT NULL,
  reported_user_id CHAR(36) NULL,
  reported_listing_id CHAR(36) NULL,
  reason ENUM('spam','inappropriate','fraud','counterfeit','other') NOT NULL,
  description TEXT NULL,
  status ENUM('pending','reviewing','resolved','dismissed') NOT NULL DEFAULT 'pending',
  resolved_by CHAR(36) NULL,
  resolved_at TIMESTAMP NULL,
  resolution_notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_reports_reporter FOREIGN KEY (reporter_id) REFERENCES users(id),
  CONSTRAINT fk_reports_reported_user FOREIGN KEY (reported_user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_reports_reported_listing FOREIGN KEY (reported_listing_id) REFERENCES listings(id) ON DELETE SET NULL,
  CONSTRAINT fk_reports_resolved_by FOREIGN KEY (resolved_by) REFERENCES admin_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notifications (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  type ENUM('order','message','review','system','promotion') NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NULL,
  data JSON NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE analytics_events (
  id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  user_id CHAR(36) NULL,
  listing_id CHAR(36) NULL,
  metadata JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(500) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_analytics_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_analytics_listing FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE SET NULL,
  INDEX idx_event_type (event_type),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_verification (
  id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL UNIQUE,
  identity_verified TINYINT(1) NOT NULL DEFAULT 0,
  identity_document_url VARCHAR(255) NULL,
  verification_status ENUM('not_submitted','pending','approved','rejected') NOT NULL DEFAULT 'not_submitted',
  verified_at TIMESTAMP NULL,
  verified_by CHAR(36) NULL,
  rejection_reason TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_verification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_verification_admin FOREIGN KEY (verified_by) REFERENCES admin_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed data for new tables
INSERT INTO admin_users (id, email, password_hash, full_name, role, permissions)
VALUES ('admin-1', 'admin@vintastep.com', '$2a$10$TNBvOrf5DMCd77sIm9.hAu9hIGHnoPA/63HTW1NGD1NrvKKmFnHhi', 'Super Admin', 'super_admin', JSON_ARRAY('all'));

INSERT INTO categories (id, name, slug, description, display_order)
VALUES
  ('cat-1', 'Footwear', 'footwear', 'Shoes, boots, sneakers, and more', 1),
  ('cat-2', 'Clothing', 'clothing', 'Jackets, shirts, pants, and accessories', 2),
  ('cat-3', 'Accessories', 'accessories', 'Bags, belts, hats, and jewelry', 3),
  ('cat-4', 'Vintage', 'vintage', 'Authentic vintage and retro items', 4);

INSERT INTO listing_categories (listing_id, category_id)
VALUES
  ('listing-1', 'cat-2'),
  ('listing-1', 'cat-4'),
  ('listing-2', 'cat-1'),
  ('listing-3', 'cat-1'),
  ('listing-4', 'cat-1'),
  ('listing-5', 'cat-1'),
  ('listing-6', 'cat-1');
