# VintaSteps Marketplace

A comprehensive thrift marketplace platform promoting affordability and sustainability. Users can browse and purchase quality pre-owned items with direct seller communication for streamlined, trust-based transactions.

## 🏗️ Architecture Overview

This monorepo separates concerns into three independent directories for better organization and scalability:

```
vintastep/
├── frontend/                  # Flutter mobile & web client
│   ├── lib/                   # Dart source code
│   ├── web/                   # Web-specific assets
│   ├── pubspec.yaml           # Flutter dependencies
│   └── README.md              # Frontend documentation
├── backend/                   # Node.js/Express API server
│   ├── src/                   # JavaScript source code
│   ├── package.json           # npm dependencies
│   ├── .env                   # Environment configuration
│   └── README.md              # Backend documentation
├── database/                  # MySQL schema & initialization
│   ├── schema.sql             # Database definition
│   ├── initDb.js              # DB initialization script
│   └── README.md              # Database documentation
└── README.md                  # This file
```

## 🎯 Tech Stack

### Frontend (Flutter)
- **Framework:** Flutter 3.3.0+
- **Language:** Dart
- **State Management:** Riverpod
- **Routing:** GoRouter
- **HTTP Client:** Dio
- **Security:** Flutter Secure Storage
- **UI:** Material Design 3

### Backend (Node.js)
- **Runtime:** Node.js 16+
- **Framework:** Express.js
- **Authentication:** JWT (JSON Web Tokens)
- **Database:** MySQL 8.0+
- **Security:** bcryptjs, Helmet, CORS

### Database (MySQL)
- **Engine:** InnoDB
- **Charset:** utf8mb4
- **Geospatial:** Location-based queries (POINT, ST_Distance_Sphere)
- **Features:** Foreign keys, indexes, transactions

## 🚀 Quick Start

### Prerequisites
- Flutter SDK ≥ 3.3.0
- Node.js ≥ 16.x
- MySQL ≥ 8.0
- Git

### Setup Steps

**1. Clone & Navigate**
```bash
git clone https://github.com/musharafali-dev/Vintasteps-mobile-Application.git
cd Vintasteps-mobile-Application
```

**2. Frontend Setup**
```bash
cd frontend
flutter pub get
flutter run
```

**3. Backend Setup**
```bash
cd ../backend
npm install
npm run init-db        # Initialize MySQL database
npm run dev            # Start development server
```

**4. Database**
- Schema automatically created by `npm run init-db`
- See `database/README.md` for manual setup

---

## 📁 Directory Guide

### Frontend (`/frontend`)
- **Build Target:** iOS, Android, Web
- **Architecture:** Clean Architecture with modular features
- **State:** Riverpod providers for global state
- **Routing:** GoRouter for declarative navigation
- **See:** `frontend/README.md` for detailed setup

**Key Features:**
- User authentication (buyer/seller roles)
- Product browsing & search
- Shopping cart & checkout
- Order tracking
- In-app messaging
- Reviews & ratings
- Admin dashboard

### Backend (`/backend`)
- **API:** REST endpoints at `/api/*`
- **Auth:** JWT-based with role access control
- **Database:** MySQL connection pooling
- **See:** `backend/README.md` for API documentation

**Key Features:**
- User registration & authentication
- Product listing CRUD
- Order management
- Real-time chat
- Review system
- Admin operations
- Geospatial search (5km radius by default)

### Database (`/database`)
- **Schema:** Complete table definitions
- **Initialization:** Automatic via Node.js script
- **See:** `database/README.md` for schema details & queries

**Key Tables:**
- `users` - User accounts
- `listings` - Products with location (POINT type)
- `orders` - Purchase orders
- `messages` - Chat messages
- `reviews` - Product reviews
- `admin_users` - Admin accounts

---

## 🔌 API Integration

Frontend communicates with backend via HTTP REST API.

### Example Flow
1. User registers → `POST /api/auth/register`
2. Login returns JWT → `POST /api/auth/login`
3. Browse listings → `GET /api/listings?category=clothing&lat=40&lng=-74`
4. Create order → `POST /api/orders`
5. Send message → `POST /api/messages`

**Base URL:** `http://localhost:5000/api` (development)

See `backend/README.md` for complete endpoint documentation.

---

## 🔐 Authentication

### User Roles
- **Buyer** - Can browse, purchase, review
- **Seller** - Can list products, receive orders
- **Admin** - Can moderate, manage users, view analytics

### Token Flow
```
1. User provides credentials
2. Backend hashes password (bcryptjs)
3. Returns JWT token (7-day expiry)
4. Frontend stores in secure storage
5. Token sent in Authorization header for protected endpoints
```

### Demo Accounts (if seeded)
- Buyer: `buyer@example.com` / `Password123!`
- Seller: `seller@example.com` / `Password123!`

---

## 📦 Project Commands

### Frontend
```bash
cd frontend

# Install dependencies
flutter pub get

# Run app (choose platform)
flutter run              # Android/iOS emulator
flutter run -d chrome    # Web browser

# Code formatting & linting
dart format lib/
flutter analyze

# Build release
flutter build apk --release    # Android
flutter build ios --release    # iOS
flutter build web --release    # Web
```

### Backend
```bash
cd backend

# Install dependencies
npm install

# Initialize database
npm run init-db

# Development
npm run dev

# Production
npm start

# Check for issues
npx eslint .
```

### Database
```bash
# Manual schema import
mysql -u root -p vintastep_db < ../database/schema.sql

# Backup
mysqldump -u root -p vintastep_db > backup.sql

# Restore
mysql -u root -p vintastep_db < backup.sql
```

---

## 🌍 Environment Configuration

### Backend `.env`
```env
PORT=5000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=vintastep_db
JWT_SECRET=your_secret_key
JWT_EXPIRY=7d
NODE_ENV=development
```

### Frontend Configuration
Update API base URL in `frontend/lib/core/network/dio_client.dart`:
```dart
const String baseUrl = 'http://localhost:5000/api';
```

---

## 🧪 Testing

### Frontend Tests
```bash
cd frontend
flutter test
```

### Backend Tests
```bash
cd backend
npm test
```

---

## 📊 Project Status

### Completed ✅
- User authentication & JWT
- Product listing system with geospatial search
- Shopping cart & order management
- Messaging system
- Review & rating system
- Admin dashboard (basic)
- Database schema with foreign keys

### In Progress 🔄
- Payment integration (Stripe)
- Push notifications
- Enhanced admin analytics
- Image optimization

### Planned 📋
- Social features (wishlists, recommendations)
- Advanced search filters
- Seller verification KYC
- Performance monitoring
- Mobile app signing & distribution

---

## 🤝 Contributing

1. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Make changes & test:**
   - Follow code style guidelines
   - Test thoroughly before commit
   - Update documentation if needed

3. **Commit & push:**
   ```bash
   git add .
   git commit -m "feat: add your feature"
   git push origin feature/your-feature
   ```

4. **Open pull request** with description

---

## 📚 Additional Resources

- **Admin Guide:** See `ADMIN_ACCESS_GUIDE.md`
- **Admin Upgrade:** See `ADMIN_UPGRADE_GUIDE.md`
- **Flutter Docs:** https://docs.flutter.dev
- **Express.js Guide:** https://expressjs.com
- **MySQL Docs:** https://dev.mysql.com/doc

---

## 🐛 Troubleshooting

### Flutter App Won't Start
```bash
flutter clean
flutter pub get
flutter run
```

### Backend Connection Error
```bash
# Check MySQL is running
# Verify .env credentials
# Ensure database exists: CREATE DATABASE vintastep_db;
npm run init-db
```

### Port Already in Use
```powershell
# Find & kill process on port 5000
Get-Process | Where-Object {$_.Handles -like '*5000*'} | Stop-Process -Force
```

---

## 📝 License

Internal project – license terms pending.

---

## 👤 Support

For issues or questions:
1. Check relevant README in `/frontend`, `/backend`, or `/database`
2. Review `ADMIN_ACCESS_GUIDE.md` for development setup
3. Check Git logs for recent changes

**Last Updated:** December 9, 2025