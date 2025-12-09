# VintaSteps Complete Setup Guide

Complete instructions to set up and run the entire VintaSteps marketplace application.

## 📁 Project Structure

```
vintastep/
├── frontend/              # Flutter mobile & web application
├── backend/               # Node.js Express REST API
├── database/              # MySQL database schema
└── README.md              # Main documentation
```

## 🚀 Quick Start (5 minutes)

### Prerequisites
- **Node.js** 16+ and npm
- **Flutter** 3.3.0+ and Dart
- **MySQL** 8.0+

### One-Time Setup

```powershell
# 1. Install backend dependencies
cd backend
npm install

# 2. Install frontend dependencies
cd ../frontend
flutter pub get

# 3. Initialize database
cd ../backend
npm run init-db
```

### Start Development

**Terminal 1 - Backend:**
```powershell
cd backend
npm run dev
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
flutter run
```

---

## 📱 Frontend Setup

### Installation

```powershell
cd frontend
flutter pub get
```

### Run on Device/Emulator

```bash
# Show available devices
flutter devices

# Run app
flutter run

# Run on specific device
flutter run -d emulator-5554
```

### Run on Web

```bash
flutter run -d chrome
```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS App:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

**Details:** See `frontend/README.md`

---

## 🔧 Backend Setup

### Installation

```powershell
cd backend
npm install
```

### Environment Configuration

Create `backend/.env`:

```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=vintastep
JWT_SECRET=your_very_secret_jwt_key_change_this
NODE_ENV=development
```

### Initialize Database

```powershell
npm run init-db
```

This will:
- Drop existing tables (development only!)
- Create fresh schema from `database/scripts/schema.sql`
- Seed initial data if configured

### Run Server

**Development (with auto-reload):**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server runs on `http://localhost:3000`

**Details:** See `backend/README.md`

---

## 🗄️ Database Setup

### Initialize

The database is automatically created by `npm run init-db` in the backend.

### Manual MySQL Setup

```bash
# Connect to MySQL
mysql -u root -p

# Create database
CREATE DATABASE vintastep CHARACTER SET utf8mb4;

# Run schema
source database/scripts/schema.sql;
```

### Verify Installation

```sql
-- In MySQL CLI
USE vintastep;
SHOW TABLES;  -- Should show: users, listings, orders, etc.
```

### Reset Database

```powershell
# From backend directory
npm run init-db
```

**⚠️ WARNING:** This drops all existing data!

**Details:** See `database/README.md`

---

## 🔌 API Integration

### Backend URL Configuration

**Frontend (`lib/core/network/dio_client.dart`):**
```dart
const String baseUrl = 'http://localhost:3000/api';
```

### Key Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/auth/register` | User signup |
| POST | `/auth/login` | User login |
| GET | `/listings` | Browse listings |
| POST | `/listings` | Create listing |
| POST | `/orders` | Place order |
| GET | `/orders` | User orders |

**Full API docs:** See `backend/README.md`

---

## 🧪 Testing

### Backend Tests
```powershell
cd backend
npm test
```

### Frontend Tests
```powershell
cd frontend
flutter test
```

---

## 📋 Common Tasks

### Add Flutter Package
```powershell
cd frontend
flutter pub add package_name
```

### Add NPM Package
```powershell
cd backend
npm install package_name
```

### Format Code
```powershell
# Flutter
cd frontend
dart format .

# Backend
cd backend
npm run format  # if configured
```

### Check for Issues
```powershell
# Flutter Analysis
cd frontend
dart analyze

# Backend Linting
cd backend
npm run lint  # if configured
```

### Database Backup
```bash
mysqldump -u root -p vintastep > database/backup.sql
```

### Database Restore
```bash
mysql -u root -p vintastep < database/backup.sql
```

---

## 🐛 Troubleshooting

### Frontend: Dependency Issues
```powershell
cd frontend
flutter clean
flutter pub get
```

### Backend: Module Not Found
```powershell
cd backend
rm -r node_modules package-lock.json
npm install
```

### Database: Connection Refused
- Check MySQL is running: `mysql -u root -p`
- Verify `.env` DB credentials
- Ensure database exists: `SHOW DATABASES;`

### Port Already in Use
```powershell
# Find process using port 3000
netstat -ano | findstr :3000

# Kill process (Windows)
taskkill /PID <PID> /F
```

---

## 📚 Documentation

- **Frontend Docs:** `frontend/README.md`
- **Backend Docs:** `backend/README.md`
- **Database Docs:** `database/README.md`
- **Main Docs:** `README.md`

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] Backend runs: `npm run dev` → Server on port 3000
- [ ] Frontend builds: `flutter run` → App opens
- [ ] Database initialized: `mysql: SHOW TABLES;` → 15+ tables
- [ ] API responds: `curl http://localhost:3000/api/listings`
- [ ] Frontend connects to backend without errors

---

## 🚀 Next Steps

1. **Configure Environment:** Update `.env` files with your settings
2. **Start Backend:** Run `npm run dev` in `backend/`
3. **Start Frontend:** Run `flutter run` in `frontend/`
4. **Test Features:** Login, create listing, browse, order
5. **Customize:** Modify as needed for your deployment

---

**Last Updated:** December 2025
