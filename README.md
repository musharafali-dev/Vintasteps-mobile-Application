# Vintasteps Mobile Application

VintaSteps is a mobile thrift marketplace promoting affordability and sustainability. Users can browse and purchase quality pre-owned items and communicate directly with sellers (e.g. via WhatsApp) for streamlined, trust-based transactions.

## Overview
This repository contains the Flutter mobile application plus a backend (Node.js) under `src/`. The Flutter app is the client for browsing listings, managing carts/orders, chatting, reviews, and admin operations.

## Tech Stack
- Flutter (Dart) for cross-platform mobile & web build
- Node.js/Express backend (see `src/`) with routing & services
- Secure storage utilities, Dio for networking, and modular feature folders under `lib/features`

## Getting Started (Flutter)
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Fetch dependencies:
	```
	flutter pub get
	```
3. Run the app (choose platform):
	```
	flutter run
	```

Helpful Flutter resources:
- First app codelab: https://docs.flutter.dev/get-started/codelab
- Cookbook samples: https://docs.flutter.dev/cookbook

## Backend (Node.js)
Navigate to `src/` for server code. Typical setup:
```powershell
cd src
npm install
npm start
```

## Authentication Demo Accounts (if configured)
You may have seeded demo accounts such as buyer / seller roles. Check any seed scripts under `src/scripts/` or environment docs.

## Contributing
1. Create a feature branch.
2. Commit focused changes.
3. Open a PR describing the context & testing.

## License
Internal project – license terms pending (add when decided).

## Roadmap (High-Level)
- Enhanced chat experience & notifications
- Listing promotion & featured slots
- Review moderation tools
- Analytics dashboard for admins

---
Feel free to refine this README further as features evolve.
