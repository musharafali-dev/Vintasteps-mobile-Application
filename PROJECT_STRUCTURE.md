# 📊 VintaSteps Project Structure

This document provides a detailed breakdown of the project organization after restructuring into Frontend, Backend, and Database components.

## 🏗️ Root Architecture

```
vintastep/
│
├─── frontend/                    ⭐ Flutter Mobile & Web Client
│    ├── lib/
│    │   ├── main.dart            # App entry point
│    │   ├── core/                # Shared utilities & config
│    │   │   ├── network/         # Dio HTTP client setup
│    │   │   ├── router/          # GoRouter navigation
│    │   │   └── storage/         # Secure storage
│    │   └── features/            # Feature modules (Clean Arch)
│    │       ├── admin/           # Admin dashboard
│    │       ├── auth/            # Login/Register
│    │       ├── cart/            # Shopping cart logic
│    │       ├── chat/            # Messaging system
│    │       ├── home/            # Home screen
│    │       ├── listings/        # Product browsing
│    │       ├── orders/          # Order tracking
│    │       └── reviews/         # Ratings & reviews
│    ├── web/                     # Web-specific assets & config
│    ├── pubspec.yaml             # Flutter dependencies
│    ├── pubspec.lock             # Dependency lock file
│    ├── analysis_options.yaml    # Lint rules
│    └── README.md                # Frontend documentation
│
├─── backend/                      ⭐ Node.js/Express REST API
│    ├── src/
│    │   ├── server.js            # Express app server
│    │   ├── app.js               # Middleware config
│    │   ├── config/
│    │   │   └── db.js            # MySQL connection pool
│    │   ├── controllers/         # Request handlers
│    │   │   ├── authController.js
│    │   │   ├── listingsController.js
│    │   │   ├── orderController.js
│    │   │   └── adminController.js
│    │   ├── routes/              # API endpoint definitions
│    │   │   ├── authRoutes.js
│    │   │   ├── listingsRoutes.js
│    │   │   ├── orderRoutes.js
│    │   │   └── adminRoutes.js
│    │   ├── services/            # Business logic
│    │   │   ├── authService.js
│    │   │   ├── listingsService.js
│    │   │   ├── orderService.js
│    │   │   └── adminService.js
│    │   ├── middlewares/         # Custom middleware
│    │   │   ├── authMiddleware.js
│    │   │   ├── adminAuthMiddleware.js
│    │   │   └── validateRequest.js
│    │   ├── public/              # Static files
│    │   │   ├── admin-dashboard.html
│    │   │   └── admin-dashboard-v2.html
│    │   └── utils/               # Helper functions
│    ├── package.json             # npm dependencies
│    ├── package-lock.json        # Dependency lock file
│    ├── .env                     # Environment variables
│    └── README.md                # Backend documentation
│
├─── database/                     ⭐ MySQL Schema & Scripts
│    ├── schema.sql               # Complete database definition
│    │   ├── users               # User accounts (buyer/seller)
│    │   ├── listings            # Products with geospatial
│    │   ├── orders              # Purchase orders
│    │   ├── order_items         # Order line items
│    │   ├── conversations       # Chat conversations
│    │   ├── messages            # Chat messages
│    │   ├── reviews             # Product reviews
│    │   ├── categories          # Product categories
│    │   ├── admin_users         # Admin accounts
│    │   ├── notifications       # User notifications
│    │   ├── analytics_events    # Event tracking
│    │   ├── reports             # Moderation reports
│    │   └── user_verification   # KYC verification
│    ├── initDb.js               # Node.js initialization script
│    └── README.md               # Database documentation
│
├─── build/                        📦 Build Output (auto-generated)
├─── node_modules/                 📦 npm packages (auto-generated)
├─── .dart_tool/                   📦 Flutter build cache (auto-generated)
├─── .git/                         🔐 Git history
├─── .vscode/                      ⚙️  VS Code settings
├─── ADMIN_ACCESS_GUIDE.md         📖 Admin setup guide
├─── ADMIN_UPGRADE_GUIDE.md        📖 Upgrade instructions
├─── README.md                     📖 Main documentation
└─── .gitignore                    🚫 Git ignore rules
```

## 📂 Detailed Breakdown

### Frontend (`/frontend`)

**Purpose:** Flutter application for iOS, Android, and Web

**Tech Stack:**
- Dart 3.3.0+
- Flutter 3.3.0+
- Riverpod (state management)
- GoRouter (navigation)
- Dio (HTTP)
- Material Design

**Key Directories:**
- `lib/core/` - Shared code, networking, routing, storage
- `lib/features/` - Feature-based modules (admin, auth, cart, chat, home, listings, orders, reviews)
- `web/` - Web-specific assets and configuration

**Development:**
```bash
cd frontend
flutter pub get      # Install dependencies
flutter run          # Run app
dart format lib/     # Format code
flutter analyze      # Check for issues
```

### Backend (`/backend`)

**Purpose:** REST API server for mobile app and admin dashboard

**Tech Stack:**
- Node.js 16+
- Express.js
- MySQL (via mysql2)
- JWT authentication
- bcryptjs (password hashing)
- Helmet (security headers)
- CORS (cross-origin requests)

**Key Directories:**
- `src/controllers/` - Handle HTTP requests
- `src/routes/` - Define API endpoints
- `src/services/` - Business logic and database operations
- `src/middlewares/` - Authentication, validation, error handling
- `src/config/` - Database connection setup
- `src/public/` - Admin dashboard UI files

**API Endpoints:**
- `/api/auth/*` - Authentication
- `/api/listings/*` - Product listings
- `/api/orders/*` - Order management
- `/api/admin/*` - Admin operations

**Development:**
```bash
cd backend
npm install          # Install dependencies
npm run init-db      # Initialize database
npm run dev          # Start with hot reload
npm start            # Production start
```

### Database (`/database`)

**Purpose:** MySQL database schema and initialization

**Contents:**
- `schema.sql` - 306-line SQL file defining all tables
- `initDb.js` - Node.js script to execute schema

**Key Tables:**
- `users` - 15 columns for user profiles
- `listings` - Products with POINT geospatial type
- `orders` - Purchase orders with status tracking
- `messages` - Chat system
- `reviews` - Rating & feedback system
- `admin_users` - Admin account management
- `categories` - Product categorization
- Plus tables for analytics, notifications, moderation

**Features:**
- Foreign key constraints
- InnoDB engine for transactions
- utf8mb4 charset (international support)
- Spatial indexing for location queries
- Timestamps for audit trails

**Setup:**
```bash
# From backend directory
npm run init-db

# Or manually
mysql -u root -p
CREATE DATABASE vintastep_db CHARACTER SET utf8mb4;
SOURCE path/to/schema.sql;
```

## 🔄 Data Flow

```
┌─────────────┐
│   Flutter   │ (Frontend)
│ Mobile/Web  │
└──────┬──────┘
       │ HTTP REST API
       │ (Dio client)
       ↓
┌──────────────┐
│   Express    │ (Backend)
│   Server     │
└──────┬───────┘
       │ SQL Queries
       │ (mysql2 pool)
       ↓
┌─────────────┐
│   MySQL     │ (Database)
│  Database   │
└─────────────┘
```

## 🔐 Environment Variables

### Backend `.env` (required)

```env
PORT=5000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=password
DB_NAME=vintastep_db
JWT_SECRET=your-secret-key
JWT_EXPIRY=7d
NODE_ENV=development
```

### Frontend Configuration

Update in `lib/core/network/dio_client.dart`:
```dart
const String baseUrl = 'http://localhost:5000/api';
```

## 📊 Technology Matrix

| Layer    | Language   | Framework      | Key Library        | Purpose            |
|----------|------------|----------------|--------------------|-------------------|
| Frontend | Dart       | Flutter        | Riverpod           | UI/UX              |
| Backend  | JavaScript | Express        | jwt, bcryptjs      | API Logic          |
| Database | SQL        | MySQL 8.0      | InnoDB, Spatial    | Data Storage       |

## 🚀 Development Workflow

### Start All Services

**Terminal 1 - Frontend:**
```bash
cd frontend
flutter run -d chrome
```

**Terminal 2 - Backend:**
```bash
cd backend
npm run dev
```

**Terminal 3 - MySQL (if not running as service):**
```bash
mysql -u root -p
```

### Common Tasks

| Task | Command | Location |
|------|---------|----------|
| Format code | `dart format lib/` | frontend/ |
| Lint check | `flutter analyze` | frontend/ |
| Run tests | `flutter test` | frontend/ |
| API dev | `npm run dev` | backend/ |
| DB init | `npm run init-db` | backend/ |
| Build APK | `flutter build apk --release` | frontend/ |

## 📈 Scalability Considerations

### Frontend
- Feature-based modular structure allows independent development
- Riverpod enables efficient state reuse & testing
- Easy to add new features without affecting existing code

### Backend
- Route-based organization separates concerns
- Service layer abstracts business logic
- Middleware pattern allows auth/validation reuse
- Connection pooling handles concurrent requests

### Database
- Foreign keys maintain referential integrity
- Spatial indexes optimize geospatial queries
- JSON columns provide flexible data storage
- Multiple tables with proper normalization

## 🔗 Integration Points

### Frontend → Backend
- Dio client intercepts requests with JWT tokens
- Base URL configurable per environment
- Error handling & retry logic built-in

### Backend → Database
- Connection pool manages MySQL connections
- Prepared statements prevent SQL injection
- Transactions ensure data consistency

## 📝 Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Main project overview |
| `frontend/README.md` | Flutter development guide |
| `backend/README.md` | API documentation & setup |
| `database/README.md` | Schema details & queries |
| `ADMIN_ACCESS_GUIDE.md` | Admin user setup |
| `ADMIN_UPGRADE_GUIDE.md` | Version upgrade steps |
| `PROJECT_STRUCTURE.md` | This file |

## ✅ Verification Checklist

After reorganization:
- [x] Frontend at `/frontend` with `pubspec.yaml`
- [x] Backend at `/backend` with `package.json`
- [x] Database at `/database` with `schema.sql`
- [x] All documentation updated
- [x] Git history preserved (in `.git/`)
- [x] No breaking changes to functionality

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| `lib/` not found in pubspec.yaml | Run `cd frontend` first |
| `package.json` not found | Run `cd backend` first |
| DB connection error | Check `.env` credentials in backend |
| Build cache issues | Run `flutter clean` in frontend |

---

**Last Updated:** December 9, 2025
**Status:** ✅ Project structure reorganized and documented
