# 📋 VintaSteps - Essential Files & Commands Index

## 🚀 Getting Started (5 Minutes)

### One-Time Setup
```powershell
# Install all dependencies
cd backend && npm install
cd ../frontend && flutter pub get

# Initialize database
cd ../backend && npm run init-db
```

### Start Development (2 terminals)
```powershell
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Frontend  
cd frontend
flutter run
```

---

## 📁 Project Directories

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| **frontend/** | Flutter Mobile/Web App | `lib/main.dart`, `pubspec.yaml` |
| **backend/** | Node.js REST API | `src/server.js`, `package.json` |
| **database/** | MySQL Schema | `scripts/schema.sql` |

---

## 📚 Documentation Files (Read These First)

| File | Read For |
|------|----------|
| **README.md** | Project overview & architecture |
| **SETUP_GUIDE.md** | Step-by-step setup & troubleshooting |
| **STRUCTURE_OVERVIEW.md** | Visual structure & components |
| **DIRECTORY_TREE.md** | Complete file tree |
| **QUICK_REFERENCE.md** | Common commands & examples |

---

## 🔧 Frontend Commands

```powershell
cd frontend

# Setup
flutter pub get              # Install dependencies
flutter clean                # Clean build files

# Run
flutter run                  # Run on device/emulator
flutter run -d chrome        # Run on web browser

# Build
flutter build apk --release  # Build Android APK
flutter build ios --release  # Build iOS app
flutter build web --release  # Build for web

# Code Quality
dart format .                # Format all Dart files
dart analyze                 # Check for issues
flutter test                 # Run tests
```

---

## 🔧 Backend Commands

```powershell
cd backend

# Setup
npm install                  # Install dependencies
npm run init-db              # Initialize database

# Run
npm run dev                  # Development (auto-reload)
npm start                    # Production

# Code Quality
npm test                     # Run tests
npm run lint                 # Run linter (if configured)
```

---

## 🗄️ Database Commands

```powershell
# Initialize from backend
cd backend
npm run init-db

# Manual MySQL (if needed)
mysql -u root -p
mysql> source database/scripts/schema.sql;
```

---

## 🔌 API Endpoints

Base URL: `http://localhost:3000/api`

### Auth
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout

### Listings
- `GET /listings` - Get all listings
- `POST /listings` - Create listing
- `GET /listings/:id` - Get listing details
- `PUT /listings/:id` - Update listing
- `DELETE /listings/:id` - Delete listing

### Orders
- `GET /orders` - Get user orders
- `POST /orders` - Create order
- `GET /orders/:id` - Get order details

### Admin
- `GET /admin/dashboard` - Dashboard (admin only)
- `GET /admin/users` - Manage users
- `GET /admin/orders` - Manage orders

---

## ⚙️ Configuration

### Backend (.env)
```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=vintastep
JWT_SECRET=your_jwt_secret
NODE_ENV=development
```

### Frontend (hardcoded in code)
Edit in `lib/core/network/dio_client.dart`:
```dart
const String baseUrl = 'http://localhost:3000/api';
```

---

## 🧪 Testing

```powershell
# Backend
cd backend && npm test

# Frontend
cd frontend && flutter test
```

---

## 📱 Frontend File Locations

| What | Location |
|------|----------|
| Main Entry | `frontend/lib/main.dart` |
| Router | `frontend/lib/core/router/app_router.dart` |
| API Client | `frontend/lib/core/network/dio_client.dart` |
| Auth | `frontend/lib/features/auth/` |
| Listings | `frontend/lib/features/listings/` |
| Cart | `frontend/lib/features/cart/` |
| Orders | `frontend/lib/features/orders/` |
| Admin | `frontend/lib/features/admin/` |

---

## 🔧 Backend File Locations

| What | Location |
|------|----------|
| Server | `backend/src/server.js` |
| Express App | `backend/src/app.js` |
| DB Config | `backend/src/config/db.js` |
| Auth Controller | `backend/src/controllers/authController.js` |
| Auth Routes | `backend/src/routes/authRoutes.js` |
| Auth Service | `backend/src/services/authService.js` |
| Auth Middleware | `backend/src/middlewares/authMiddleware.js` |
| Listings | `backend/src/routes/listingsRoutes.js` |
| Orders | `backend/src/routes/orderRoutes.js` |
| Admin | `backend/src/routes/adminRoutes.js` |

---

## 💾 Database Tables

| Table | Purpose |
|-------|---------|
| `users` | User accounts & profiles |
| `listings` | Product listings |
| `orders` | Customer orders |
| `order_items` | Items in each order |
| `messages` | Chat messages |
| `conversations` | Chat threads |
| `reviews` | Product reviews |
| `admin_users` | Admin accounts |

---

## 🐛 Troubleshooting

### Issue: Backend won't start
```powershell
cd backend
npm install                # Reinstall packages
npm run init-db            # Reinit database
npm run dev                # Try again
```

### Issue: Frontend won't run
```powershell
cd frontend
flutter clean              # Clean build
flutter pub get            # Reinstall packages
flutter run                # Try again
```

### Issue: Database error
- Verify MySQL is running
- Check `.env` credentials
- Run `npm run init-db`

### Issue: API connection error
- Verify backend is running on port 3000
- Check frontend API URL in `lib/core/network/dio_client.dart`
- Check CORS settings in `backend/src/app.js`

---

## 📞 Need Help?

1. **Setup Issues?** → Read `SETUP_GUIDE.md`
2. **Frontend?** → Read `frontend/README.md`
3. **Backend?** → Read `backend/README.md`
4. **Database?** → Read `database/README.md`
5. **Commands?** → Read `QUICK_REFERENCE.md`

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Backend runs: `npm run dev` → "Server running on port 3000"
- [ ] Frontend builds: `flutter run` → App opens
- [ ] Database initialized: `npm run init-db` → Tables created
- [ ] API responds: `curl http://localhost:3000/api/listings`
- [ ] Frontend connects: No API errors in console

---

## 🎯 Development Workflow

1. **Edit Code** - Make changes in your editor
2. **Save** - VS Code auto-save or manual save
3. **Backend Hot Reload** - `npm run dev` watches for changes
4. **Frontend Hot Reload** - `flutter run` watches for changes
5. **Test** - Try the app
6. **Commit** - `git add . && git commit -m "message"`
7. **Push** - `git push`

---

## 🚀 Next Steps

1. ✅ Read `SETUP_GUIDE.md` for complete setup
2. ✅ Start backend with `npm run dev`
3. ✅ Start frontend with `flutter run`
4. ✅ Test a feature (login, browse listings, etc.)
5. ✅ Start coding your changes
6. ✅ Commit regularly
7. ✅ Push to GitHub

---

## 📊 Tech Stack Summary

- **Frontend:** Flutter/Dart, Riverpod, GoRouter
- **Backend:** Node.js, Express, JWT
- **Database:** MySQL, InnoDB, Geospatial
- **Version Control:** Git/GitHub

---

**All Essential Commands & Files in One Place** ⚡  
**Last Updated:** December 9, 2025
