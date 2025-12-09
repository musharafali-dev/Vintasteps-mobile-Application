# 🚀 Quick Reference Guide

A handy reference for navigating and developing the VintaSteps project.

## Directory Navigation

```bash
# Frontend
cd frontend/          # Flutter app
ls lib/              # Source code
ls web/              # Web assets

# Backend
cd backend/          # Node.js server
ls src/              # Source code
cat .env             # Configuration

# Database
cd database/         # MySQL schema
cat schema.sql       # Database definition
```

## Essential Commands

### Setup (First Time)

```bash
# Frontend
cd frontend
flutter pub get

# Backend
cd backend
npm install
npm run init-db

# Then verify MySQL is running
mysql -u root -p
```

### Development (Daily)

```bash
# Terminal 1: Frontend
cd frontend && flutter run -d chrome

# Terminal 2: Backend
cd backend && npm run dev

# Terminal 3: MySQL
mysql -u root -p
```

### Code Quality

```bash
# Frontend
cd frontend
dart format lib/           # Auto-format
flutter analyze            # Lint check
flutter test               # Run tests

# Backend
cd backend
npx eslint .               # Check syntax
npm test                   # Run tests
```

### Building & Deployment

```bash
# Frontend - Mobile
cd frontend
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build aar --release      # Android library

# Frontend - Web
flutter build web --release

# Backend - Production
cd backend
npm start                   # Start server (uses .env)
```

## File Locations

### Configuration Files
| File | Location | Purpose |
|------|----------|---------|
| Environment vars | `backend/.env` | Database & server config |
| Backend config | `backend/src/config/db.js` | MySQL connection |
| Frontend routes | `frontend/lib/core/router/` | Navigation setup |
| API base URL | `frontend/lib/core/network/` | HTTP client |

### Documentation Files
| File | Location | Purpose |
|------|----------|---------|
| Main docs | `README.md` | Project overview |
| Frontend guide | `frontend/README.md` | Flutter development |
| Backend guide | `backend/README.md` | API documentation |
| Database guide | `database/README.md` | Schema reference |
| This guide | `QUICK_REFERENCE.md` | Quick lookup |
| Project structure | `PROJECT_STRUCTURE.md` | Detailed breakdown |

### Source Code Organization

```
frontend/lib/
├── main.dart ..................... App entry point
├── core/
│   ├── network/dio_client.dart ... HTTP client setup
│   ├── router/app_router.dart .... Navigation routes
│   └── storage/secure_storage.dart Local data
└── features/
    ├── admin/ .................... Admin dashboard
    ├── auth/ ..................... Login/Register
    ├── cart/ ..................... Shopping cart
    ├── chat/ ..................... Messaging
    ├── home/ ..................... Home screen
    ├── listings/ ................. Products
    ├── orders/ ................... Order tracking
    └── reviews/ .................. Reviews

backend/src/
├── server.js ..................... Server startup
├── app.js ........................ Middleware
├── config/db.js .................. Database setup
├── controllers/ .................. Request handlers
├── routes/ ....................... Endpoints
├── services/ ..................... Business logic
├── middlewares/ .................. Authentication
├── public/ ....................... Admin UI
└── utils/ ........................ Helpers

database/
├── schema.sql .................... Database tables
└── initDb.js ..................... Initialization
```

## API Endpoints (Quick Reference)

### Authentication
```
POST   /api/auth/register       ........... New user signup
POST   /api/auth/login          ........... User login
POST   /api/auth/logout         ........... User logout
POST   /api/auth/verify-phone   ........... Phone verification
```

### Listings (Products)
```
GET    /api/listings            ........... Browse all
GET    /api/listings/:id        ........... Product detail
POST   /api/listings            ........... Create (auth required)
PUT    /api/listings/:id        ........... Update (owner only)
DELETE /api/listings/:id        ........... Delete (owner only)
GET    /api/listings/search/nearby  ...... Location search
```

### Orders
```
GET    /api/orders              ........... User orders
GET    /api/orders/:id          ........... Order detail
POST   /api/orders              ........... Create order
PUT    /api/orders/:id/status   ........... Update status
DELETE /api/orders/:id          ........... Cancel order
```

### Admin
```
GET    /api/admin/dashboard     ........... Stats
GET    /api/admin/users         ........... All users
GET    /api/admin/listings/pending  ..... Pending listings
PUT    /api/admin/listings/:id/approve .. Approve
DELETE /api/admin/listings/:id/reject ... Reject
GET    /api/admin/orders/summary   ....... Analytics
```

## Environment Setup

### `.env` Template (backend)
```env
PORT=5000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=vintastep_db
JWT_SECRET=your-secret-key
JWT_EXPIRY=7d
NODE_ENV=development
```

### Update API URL (frontend)
File: `frontend/lib/core/network/dio_client.dart`
```dart
const String baseUrl = 'http://localhost:5000/api';
```

## Useful Commands Cheatsheet

```bash
# Database
mysql -u root -p                           # Connect
CREATE DATABASE vintastep_db CHARACTER SET utf8mb4;
USE vintastep_db;
SOURCE path/to/schema.sql;
SHOW TABLES;                               # List tables
DESC listings;                             # Table structure

# Git
git status                                 # Check changes
git add .                                  # Stage all
git commit -m "message"                    # Commit
git push origin main                       # Push

# Node
node --version                             # Check version
npm list                                   # List packages
npm outdated                               # Check updates
npm audit                                  # Security check

# Flutter
flutter doctor                             # Diagnose issues
flutter clean                              # Clean cache
flutter upgrade                            # Update SDK
flutter devices                            # List devices
```

## Common Issues & Solutions

| Problem | Solution |
|---------|----------|
| `flutter: command not found` | Add Flutter to PATH or use full path |
| `pubspec.yaml not found` | Make sure you're in `frontend/` directory |
| `package.json not found` | Make sure you're in `backend/` directory |
| `MySQL connection error` | Check `.env` credentials and MySQL service |
| `Port 5000 already in use` | Kill process: `lsof -i :5000` then `kill -9 <PID>` |
| `App won't build` | Run `flutter clean && flutter pub get` |
| `Can't connect to API` | Check backend is running and URL is correct |
| `JWT token expired` | User needs to login again |

## Performance Tips

### Frontend
- Use `flutter run -d chrome --web-port 7860` for web dev
- Enable hot reload: `r` to reload, `R` to restart
- Check performance with DevTools: `flutter pub global run devtools`

### Backend
- Monitor with `npm run dev` (uses nodemon)
- Check logs: `tail -f logs/*.log` (if logging enabled)
- Use connection pooling (already configured)

### Database
- Enable query logging for debugging
- Use indexes on frequently queried columns
- Run `ANALYZE TABLE` for optimization

## File Extensions & Tools

| Extension | Tool | Usage |
|-----------|------|-------|
| `.dart` | Flutter/Dart | Frontend code |
| `.js` | Node.js | Backend code |
| `.sql` | MySQL | Database |
| `.yaml` | Pubspec | Flutter config |
| `.json` | npm | Backend config |
| `.env` | Text editor | Environment vars |
| `.md` | Markdown | Documentation |

## Project Statistics

```
Frontend:
├── Language: Dart
├── Lines of Code: ~5,000+
├── Packages: ~15
└── Features: 8 modules

Backend:
├── Language: JavaScript
├── Lines of Code: ~3,000+
├── Packages: ~12
└── Routes: 20+ endpoints

Database:
├── Language: SQL
├── Tables: 15
├── Relationships: Foreign keys
└── Spatial Features: Yes
```

## Feature Checklist

### Frontend ✅
- [x] Authentication (login/register)
- [x] Product browsing
- [x] Shopping cart
- [x] Order management
- [x] Messaging system
- [x] Reviews & ratings
- [x] Admin dashboard
- [ ] Payment integration (planned)

### Backend ✅
- [x] User authentication
- [x] Product CRUD
- [x] Order processing
- [x] Messaging API
- [x] Review system
- [x] Admin operations
- [x] Geospatial search
- [ ] Payment processing (planned)

### Database ✅
- [x] User tables
- [x] Listings with location
- [x] Order tracking
- [x] Messaging
- [x] Reviews
- [x] Admin accounts
- [x] Analytics
- [ ] Advanced reporting (planned)

## Release Checklist

Before deploying to production:

- [ ] Test all endpoints with `npm test`
- [ ] Run Flutter tests: `flutter test`
- [ ] Update version numbers
- [ ] Review `.env` for production values
- [ ] Build release APK/AAB: `flutter build apk --release`
- [ ] Update database backups
- [ ] Clear cache: `flutter clean`
- [ ] Review Git logs: `git log --oneline -10`
- [ ] Create Git tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
- [ ] Push everything: `git push origin main --tags`

## Support Resources

- Flutter Docs: https://docs.flutter.dev
- Express Guide: https://expressjs.com/
- MySQL Docs: https://dev.mysql.com/doc
- Dart Language: https://dart.dev/guides
- Node.js Docs: https://nodejs.org/docs

---

**Quick Links:**
- 🏠 [Main README](README.md)
- 📦 [Project Structure](PROJECT_STRUCTURE.md)
- 🎨 [Frontend Guide](frontend/README.md)
- 🔌 [Backend Guide](backend/README.md)
- 🗄️ [Database Guide](database/README.md)

**Last Updated:** December 9, 2025
