import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_notifier.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/listings/domain/models/listing.dart';
import '../../features/listings/presentation/home_page.dart';
import '../../features/listings/presentation/create_listing_page.dart';
import '../../features/listings/presentation/product_detail_page.dart';
import '../../features/listings/presentation/product_showcase_page.dart';
import '../../features/orders/presentation/order_history_page.dart';
import '../../features/orders/presentation/review_submission_page.dart';
import '../../features/admin/presentation/admin_dashboard_page.dart';
import '../../features/admin/presentation/admin_users_page.dart';
import '../../features/admin/presentation/admin_orders_page.dart';
import '../../features/admin/presentation/admin_categories_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  bool isLoggedIn() => authState.isAuthenticated;

  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'products',
        path: '/products',
        builder: (context, state) => const ProductShowcasePage(),
      ),
      GoRoute(
        name: 'product-detail',
        path: '/listing/:id',
        builder: (context, state) {
          final listing = state.extra;
          if (listing is! Listing) {
            return const Scaffold(
              body: Center(child: Text('Listing unavailable.')),
            );
          }
          return ProductDetailPage(listing: listing);
        },
      ),
      GoRoute(
        name: 'cart',
        path: '/cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        name: 'create-listing',
        path: '/create-listing',
        builder: (context, state) => const CreateListingPage(),
      ),
      GoRoute(
        name: 'orders-history',
        path: '/orders/history',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        name: 'submit-review',
        path: '/orders/review',
        builder: (context, state) {
          final args = state.extra;
          if (args is! ReviewSubmissionArgs) {
            return const Scaffold(
              body: Center(child: Text('Missing review details.')),
            );
          }
          return ReviewSubmissionPage(args: args);
        },
      ),
      // Admin routes
      GoRoute(
        name: 'admin-dashboard',
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        name: 'admin-users',
        path: '/admin/users',
        builder: (context, state) => const AdminUsersPage(),
      ),
      GoRoute(
        name: 'admin-orders',
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersPage(),
      ),
      GoRoute(
        name: 'admin-categories',
        path: '/admin/categories',
        builder: (context, state) => const AdminCategoriesPage(),
      ),
    ],
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn() && !loggingIn) {
        // If the user is not logged in, they need to login
        return '/login';
      }

      if (isLoggedIn() && loggingIn) {
        // If the user is logged in and tries to go to login, send to home
        return '/home';
      }

      return null;
    },
    debugLogDiagnostics: true,
  );
});
