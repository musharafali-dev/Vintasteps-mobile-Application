# VintaSteps Frontend (Flutter)

Cross-platform mobile and web client for the VintaSteps marketplace application.

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Networking:** Dio
- **Storage:** Flutter Secure Storage
- **UI:** Material Design

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── core/                      # Core utilities
│   ├── network/               # Dio HTTP client configuration
│   ├── router/                # GoRouter setup
│   └── storage/               # Secure storage utilities
└── features/                  # Feature modules (Clean Architecture)
    ├── admin/                 # Admin dashboard
    ├── auth/                  # Authentication
    ├── cart/                  # Shopping cart
    ├── chat/                  # Messaging
    ├── home/                  # Home screen
    ├── listings/              # Product listings
    ├── orders/                # Order management
    └── reviews/               # Reviews & ratings
```

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.3.0
- Dart ≥ 3.3.0
- Android/iOS development environment (if testing on device)

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code (if using build_runner):**
   ```bash
   flutter pub run build_runner build
   ```

3. **Run the app:**
   ```bash
   # For Android/iOS (physical device or emulator)
   flutter run
   
   # For Web
   flutter run -d chrome
   
   # Release build for Android
   flutter build apk --release
   
   # Release build for iOS
   flutter build ios --release
   ```

## Configuration

Update the backend API URL in `lib/core/network/dio_client.dart`:

```dart
// Example
const String baseUrl = 'http://your-backend-api.com/api';
```

## Architecture

This project follows **Clean Architecture** with modular feature folders:

- **Presentation Layer:** UI widgets & screens
- **Application Layer:** State management (Riverpod)
- **Domain Layer:** Business logic & entities
- **Data Layer:** API calls & local storage

## Key Features

- **Authentication:** Buyer/Seller role-based login
- **Product Browsing:** Search, filter by category & location
- **Cart Management:** Add to cart, checkout flow
- **Chat:** Direct seller communication
- **Orders:** Track purchases, delivery status
- **Reviews:** Rate sellers & products
- **Admin Panel:** Manage listings, orders, users

## Available Commands

```bash
# Check for lint issues
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Watch mode for hot reload during development
flutter run -d chrome --web-port 7860
```

## Dependencies

See `pubspec.yaml` for complete dependency list. Key packages:

- `flutter_riverpod`: State management
- `go_router`: Routing & navigation
- `dio`: HTTP client
- `flutter_secure_storage`: Encrypted local storage
- `image_picker`: Camera & gallery image selection

## Troubleshooting

### Issue: App won't start
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Build cache errors
```bash
flutter pub clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Emulator not recognized
```bash
flutter emulators
flutter emulators launch <emulator_name>
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth_test.dart
```

## Building for Production

### Android
```bash
flutter build apk --release        # Single APK
flutter build appbundle --release  # For Google Play
```

### iOS
```bash
flutter build ios --release
# Then open in Xcode for signing and distribution
```

### Web
```bash
flutter build web --release
# Output in build/web/
```

## API Integration

The app communicates with the backend via REST API at `/api` endpoints. See backend README for available endpoints.

## Contributing

1. Create a feature branch from `main`
2. Follow Dart style guide & naming conventions
3. Test thoroughly before submitting PR
4. Update this README if adding new features

## License

Internal project – license terms pending.

## Support

For issues or questions, refer to `ADMIN_ACCESS_GUIDE.md` for development setup.
