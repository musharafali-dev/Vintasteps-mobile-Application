# Project Directory Tree

Complete visual representation of the organized VintaSteps project structure.

```
vintastep/                                    # Root project directory
│
├── 📱 frontend/                              # Flutter Mobile & Web Application
│   ├── .dart_tool/                           # Dart build cache
│   ├── lib/
│   │   ├── main.dart                         # App entry point
│   │   ├── core/                             # Core infrastructure & utilities
│   │   │   ├── network/
│   │   │   │   └── dio_client.dart          # HTTP client configuration
│   │   │   ├── router/
│   │   │   │   └── app_router.dart          # Navigation & routing setup
│   │   │   └── storage/
│   │   │       └── secure_storage.dart      # Secure credential storage
│   │   └── features/                         # Feature modules (Clean Architecture)
│   │       ├── admin/                        # Admin dashboard & management
│   │       │   ├── data/
│   │       │   │   └── admin_repository.dart
│   │       │   └── presentation/
│   │       │       ├── admin_dashboard_page.dart
│   │       │       ├── admin_orders_page.dart
│   │       │       └── admin_categories_page.dart
│   │       ├── auth/                         # Authentication & login
│   │       │   ├── application/
│   │       │   │   └── auth_notifier.dart
│   │       │   └── presentation/
│   │       ├── cart/                         # Shopping cart management
│   │       │   ├── application/
│   │       │   ├── domain/
│   │       │   └── presentation/
│   │       ├── chat/                         # Messaging & communication
│   │       │   ├── data/
│   │       │   ├── domain/
│   │       │   └── presentation/
│   │       ├── home/                         # Home screen
│   │       │   └── presentation/
│   │       ├── listings/                     # Browse & manage listings
│   │       │   ├── data/
│   │       │   ├── domain/
│   │       │   └── presentation/
│   │       ├── orders/                       # Order management
│   │       │   ├── data/
│   │       │   ├── domain/
│   │       │   └── presentation/
│   │       └── reviews/                      # Reviews & ratings
│   │           ├── data/
│   │           ├── domain/
│   │           └── presentation/
│   ├── web/                                  # Web build assets
│   │   ├── index.html
│   │   ├── manifest.json
│   │   └── icons/
│   ├── .flutter-plugins-dependencies
│   ├── .metadata
│   ├── analysis_options.yaml                 # Dart linter configuration
│   ├── pubspec.yaml                          # Flutter & Dart dependencies
│   ├── pubspec.lock                          # Locked dependency versions
│   └── README.md                             # Frontend documentation
│
├── 🔧 backend/                               # Node.js/Express REST API
│   ├── src/
│   │   ├── server.js                         # Server startup & configuration
│   │   ├── app.js                            # Express app setup & middleware
│   │   ├── config/
│   │   │   └── db.js                         # MySQL database connection
│   │   ├── controllers/                      # Request handlers
│   │   │   ├── adminController.js
│   │   │   ├── authController.js
│   │   │   ├── listingsController.js
│   │   │   └── orderController.js
│   │   ├── services/                         # Business logic layer
│   │   │   ├── adminService.js
│   │   │   ├── authService.js
│   │   │   ├── listingsService.js
│   │   │   └── orderService.js
│   │   ├── routes/                           # API endpoint definitions
│   │   │   ├── adminRoutes.js
│   │   │   ├── authRoutes.js
│   │   │   ├── listingsRoutes.js
│   │   │   └── orderRoutes.js
│   │   ├── middlewares/                      # Custom middleware
│   │   │   ├── adminAuthMiddleware.js        # Admin authentication
│   │   │   ├── authMiddleware.js             # JWT verification
│   │   │   └── validateRequest.js            # Request validation
│   │   ├── scripts/                          # Database & utility scripts
│   │   │   ├── initDb.js                     # Database initialization
│   │   │   └── (schema.sql located in database/)
│   │   ├── public/                           # Static files & admin dashboards
│   │   │   ├── admin-dashboard-v2.html
│   │   │   └── admin-dashboard.html
│   │   └── utils/                            # Helper functions
│   ├── .env                                  # Environment variables
│   ├── package.json                          # npm dependencies & scripts
│   ├── package-lock.json                     # Locked dependency versions
│   └── README.md                             # Backend documentation
│
├── 🗄️ database/                              # MySQL Database Schema
│   ├── scripts/
│   │   └── schema.sql                        # Complete database schema
│   │       ├── users table
│   │       ├── listings table
│   │       ├── orders table
│   │       ├── order_items table
│   │       ├── messages table
│   │       ├── conversations table
│   │       ├── reviews table
│   │       ├── admin_users table
│   │       ├── analytics_events table
│   │       ├── notifications table
│   │       ├── reports table
│   │       ├── categories table
│   │       └── user_verification table
│   └── README.md                             # Database documentation
│
├── 📚 Documentation Files (Root)
│   ├── README.md                             # Main project overview & architecture
│   ├── SETUP_GUIDE.md                        # Complete setup & installation guide
│   ├── STRUCTURE_OVERVIEW.md                 # Visual structure & component overview
│   ├── PROJECT_STRUCTURE.md                  # Detailed structure explanation
│   ├── QUICK_REFERENCE.md                    # Quick command reference
│   ├── DOCUMENTATION_INDEX.md                # Links to all documentation
│   ├── REORGANIZATION_COMPLETE.md            # Reorganization summary
│   ├── ADMIN_ACCESS_GUIDE.md                 # Admin access setup
│   └── ADMIN_UPGRADE_GUIDE.md                # Admin upgrade procedures
│
├── 🔧 Configuration & Build
│   ├── .git/                                 # Version control repository
│   ├── .gitignore                            # Git ignore rules
│   ├── .vscode/                              # VS Code workspace settings
│   ├── build/                                # Flutter build output
│   │   ├── web/                              # Web build artifacts
│   │   └── (platform-specific builds)
│   └── node_modules/                         # npm dependencies (backend)
│       └── (node packages)
│
└── 📋 Development Files
    ├── flutter_01.log                        # Flutter build log
    └── .env                                  # Root environment (if needed)
```

---

## 📊 File Count Summary

| Directory | Type | Count | Purpose |
|-----------|------|-------|---------|
| frontend/lib | Dart | ~20+ | Flutter UI & business logic |
| backend/src | JavaScript | ~20+ | API endpoints & services |
| database/scripts | SQL | 1 | Complete schema definition |
| Documentation | Markdown | 9 | Setup & reference guides |

---

## 🔍 Key Files Quick Reference

### Frontend Entry Points
- **`frontend/lib/main.dart`** - Application initialization
- **`frontend/lib/core/router/app_router.dart`** - Route definitions
- **`frontend/lib/core/network/dio_client.dart`** - API client config

### Backend Entry Points
- **`backend/src/server.js`** - Server startup
- **`backend/src/app.js`** - Express configuration
- **`backend/src/routes/`** - All API endpoints

### Database Definition
- **`database/scripts/schema.sql`** - Complete schema with all tables

### Configuration
- **`backend/.env`** - Backend environment variables
- **`frontend/pubspec.yaml`** - Flutter dependencies
- **`backend/package.json`** - npm dependencies

---

## 📁 Directory Purpose Summary

```
┌─────────────────────────────────────┐
│  Frontend (/frontend)               │
│  ├─ User Interface (Flutter)        │
│  ├─ Navigation & Routing            │
│  ├─ State Management (Riverpod)     │
│  └─ HTTP Client Integration         │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Backend (/backend)                 │
│  ├─ REST API Endpoints              │
│  ├─ Business Logic (Services)       │
│  ├─ User Authentication (JWT)       │
│  ├─ Database Integration            │
│  └─ Request Validation              │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Database (/database)               │
│  ├─ Schema Definition               │
│  ├─ Table Relationships             │
│  ├─ Geospatial Features             │
│  └─ Initialization Scripts          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Documentation (Root)               │
│  ├─ Setup Instructions              │
│  ├─ Architecture Overview           │
│  ├─ Component Guides                │
│  └─ Quick References                │
└─────────────────────────────────────┘
```

---

## 🚀 Typical Development Workflow

1. **Start Backend:** `cd backend && npm run dev`
2. **Start Frontend:** `cd frontend && flutter run`
3. **Access API:** `http://localhost:3000/api/`
4. **View App:** On device/emulator running Flutter

---

## 💾 Important Locations

| What | Location |
|------|----------|
| Flutter Main | `frontend/lib/main.dart` |
| Express Server | `backend/src/server.js` |
| API Routes | `backend/src/routes/` |
| DB Schema | `database/scripts/schema.sql` |
| DB Config | `backend/src/config/db.js` |
| JWT Auth | `backend/src/middlewares/authMiddleware.js` |
| Features | `frontend/lib/features/` |
| Services | `backend/src/services/` |

---

**Last Updated:** December 9, 2025
