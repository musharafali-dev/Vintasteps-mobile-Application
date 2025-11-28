import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../listings/domain/models/listing.dart';
import '../domain/cart_item.dart';

final cartNotifierProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold(0, (sum, item) => sum + item.total);
});

final cartCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartNotifierProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  void addToCart(Listing listing) {
    final existingIndex =
        state.indexWhere((item) => item.listing.id == listing.id);
    if (existingIndex >= 0) {
      final updated = [...state];
      final current = updated[existingIndex];
      updated[existingIndex] = current.copyWith(quantity: current.quantity + 1);
      state = updated;
    } else {
      state = [...state, CartItem(listing: listing)];
    }
  }

  void removeFromCart(String listingId) {
    state = state.where((item) => item.listing.id != listingId).toList();
  }

  void decreaseQuantity(String listingId) {
    final updated = state
        .map((item) {
          if (item.listing.id == listingId) {
            if (item.quantity <= 1) {
              return null;
            }
            return item.copyWith(quantity: item.quantity - 1);
          }
          return item;
        })
        .whereType<CartItem>()
        .toList();

    state = updated;
  }

  void clearCart() {
    state = const [];
  }

  bool isInCart(String listingId) {
    return state.any((item) => item.listing.id == listingId);
  }
}
