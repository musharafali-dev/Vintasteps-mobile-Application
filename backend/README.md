# VintaSteps Backend (Node.js/Express)

RESTful API backend for the VintaSteps marketplace, handling authentication, listings, orders, chat, and admin operations.

## Tech Stack
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MySQL 8.0+
- **Auth:** JWT (JSON Web Tokens)
- **Password Hash:** bcryptjs
- **Security:** Helmet, CORS
- **Validation:** express-validator
- **Logger:** Morgan

## Project Structure

```
src/
├── server.js                  # Express app setup
├── app.js                     # Express middleware configuration
├── config/                    # Configuration files
│   └── db.js                  # MySQL connection pool
├── controllers/               # Request handlers
│   ├── adminController.js     # Admin operations
│   ├── authController.js      # Authentication
│   ├── listingsController.js  # Product management
│   └── orderController.js     # Order handling
├── routes/                    # Route definitions
│   ├── adminRoutes.js         # Admin endpoints
│   ├── authRoutes.js          # Auth endpoints
│   ├── listingsRoutes.js      # Listings endpoints
│   └── orderRoutes.js         # Order endpoints
├── services/                  # Business logic
│   ├── adminService.js        # Admin operations
│   ├── authService.js         # Auth logic
│   ├── listingsService.js     # Listings operations
│   └── orderService.js        # Order operations
├── middlewares/               # Custom middleware
│   ├── adminAuthMiddleware.js # Admin auth check
│   ├── authMiddleware.js      # JWT verification
│   └── validateRequest.js     # Request validation
├── public/                    # Static files
│   ├── admin-dashboard.html   # Admin UI
│   └── admin-dashboard-v2.html
├── utils/                     # Helper functions
```

## Getting Started

### Prerequisites
- Node.js ≥ 16.x
- MySQL ≥ 8.0
- npm or yarn

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   Create `.env` file in the backend directory:
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

3. **Initialize database:**
   ```bash
   npm run init-db
   ```
   This runs the schema from `../database/schema.sql`.

4. **Start the server:**
   ```bash
   # Development (with hot reload via nodemon)
   npm run dev
   
   # Production
   npm start
   ```

   Server runs at `http://localhost:5000`

## API Endpoints

### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - User login (returns JWT token)
- `POST /verify-phone` - Verify phone number
- `POST /logout` - User logout

### Listings (`/api/listings`)
- `GET /` - Get all listings (with filters)
- `GET /:id` - Get listing details
- `POST /` - Create listing (requires auth)
- `PUT /:id` - Update listing (owner only)
- `DELETE /:id` - Delete listing (owner only)
- `GET /search/nearby` - Find listings by location

### Orders (`/api/orders`)
- `GET /` - Get user's orders
- `GET /:id` - Get order details
- `POST /` - Create order
- `PUT /:id/status` - Update order status
- `DELETE /:id` - Cancel order

### Admin (`/api/admin`)
- `GET /dashboard` - Dashboard stats
- `GET /users` - List all users
- `GET /listings/pending` - Pending listings
- `PUT /listings/:id/approve` - Approve listing
- `DELETE /listings/:id/reject` - Reject listing
- `GET /orders/summary` - Order analytics

## Database

Database schema is located in `../database/schema.sql`. Key tables:

- **users** - User accounts (buyer/seller)
- **listings** - Product listings with geospatial location
- **orders** - Purchase orders
- **order_items** - Order line items
- **messages** - Chat messages
- **conversations** - Chat conversations
- **reviews** - Product & seller reviews
- **admin_users** - Admin accounts
- **analytics_events** - Activity tracking

### Geospatial Queries

The listings table uses MySQL's POINT type for location-based search:

```javascript
// Example: Find listings near user
SELECT * FROM listings 
WHERE ST_Distance_Sphere(location, POINT(lat, lng)) < 5000  -- 5km radius
```

## Authentication Flow

1. User registers with email/password → hashed via bcryptjs
2. Login returns JWT token with user ID & role
3. Token sent in `Authorization: Bearer <token>` header
4. Middleware validates token on protected routes
5. Token expiry: 7 days (configurable in `.env`)

## Running Tests

```bash
npm test
```

(Test setup pending – add your test framework)

## Development Commands

```bash
# Start development server with auto-reload
npm run dev

# Database initialization (schema + seed data)
npm run init-db

# Run production build
npm start
```

## Error Handling

All errors follow a consistent format:

```json
{
  "error": "Error message",
  "statusCode": 400,
  "timestamp": "2025-12-09T10:30:00Z"
}
```

Common status codes:
- `200` - Success
- `400` - Bad request / validation error
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not found
- `409` - Conflict (e.g., email already registered)
- `500` - Server error

## Security Considerations

- ✅ JWT-based authentication
- ✅ Password hashing with bcryptjs
- ✅ Input validation with express-validator
- ✅ CORS enabled for frontend origin
- ✅ Helmet headers for security
- ⚠️ TODO: Rate limiting
- ⚠️ TODO: SQL injection prevention (use parameterized queries)
- ⚠️ TODO: Request logging & monitoring

## Deployment

### Using PM2 (Production Process Manager)

```bash
npm install -g pm2

# Start with PM2
pm2 start src/server.js --name "vintastep-backend"

# View logs
pm2 logs

# Restart on boot
pm2 startup
pm2 save
```

### Using Docker (Optional)

Create a `Dockerfile`:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY src ./src
EXPOSE 5000
CMD ["npm", "start"]
```

Build & run:

```bash
docker build -t vintastep-backend .
docker run -p 5000:5000 --env-file .env vintastep-backend
```

## Contributing

1. Create a feature branch from `main`
2. Follow Express.js best practices
3. Test API endpoints before committing
4. Update this README for new features
5. Run linting: `npx eslint .`

## Troubleshooting

### MySQL Connection Error
```bash
# Check MySQL is running
mysql -u root -p

# Verify .env database credentials
# Ensure database exists: CREATE DATABASE vintastep_db;
```

### Port Already in Use
```bash
# Change PORT in .env or
# Kill process on port 5000 (Linux/Mac)
lsof -i :5000 | grep LISTEN | awk '{print $2}' | xargs kill -9
```

### JWT Token Errors
- Token expired: User must login again
- Invalid signature: Check JWT_SECRET in .env
- Missing token: Include in `Authorization: Bearer <token>` header

## License

Internal project – license terms pending.

## Support

For issues, check `ADMIN_UPGRADE_GUIDE.md` or backend logs for debugging.
