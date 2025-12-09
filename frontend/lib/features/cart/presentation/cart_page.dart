import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../listings/domain/models/listing.dart';
import '../../orders/data/order_repository.dart';
import '../application/cart_notifier.dart';
import '../domain/cart_item.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(cartNotifierProvider.notifier).clearCart(),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const _CartEmptyView()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _CartItemTile(item: item);
                    },
                  ),
                ),
                _CartSummary(items: cartItems, total: total),
              ],
            ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final listing = item.listing;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _ListingThumb(listing: listing),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('\$${listing.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF0F9D8D),
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: () => notifier.decreaseQuantity(listing.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: () => notifier.addToCart(listing),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => notifier.removeFromCart(listing.id),
          ),
        ],
      ),
    );
  }
}

class _ListingThumb extends StatelessWidget {
  const _ListingThumb({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 80,
        child: listing.images.isNotEmpty
            ? Image.network(listing.images.first, fit: BoxFit.cover)
            : Container(
                color: Colors.blueGrey.shade100,
                child: const Icon(Icons.image, color: Colors.white),
              ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 18),
    );
  }
}

class _CartSummary extends ConsumerStatefulWidget {
  const _CartSummary({required this.items, required this.total});

  final List<CartItem> items;
  final double total;

  @override
  ConsumerState<_CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends ConsumerState<_CartSummary> {
  bool _isProcessing = false;

  Future<void> _handleCheckout() async {
    if (_isProcessing || widget.total <= 0 || widget.items.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);
    final repository = ref.read(orderRepositoryProvider);
    final payload = widget.items
        .map((item) => {
              'listingId': item.listing.id,
              'quantity': item.quantity,
            })
        .toList();

    try {
      final orders = await repository.checkoutCart(payload);
      ref.read(cartNotifierProvider.notifier).clearCart();

      if (!mounted) return;
      final message = orders.length <= 1
          ? 'Order placed. Escrow funded.'
          : '${orders.length} orders placed. Escrow funded.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      context.push('/orders/history');
    } on DioException catch (error) {
      final data = error.response?.data;
      var message = 'Unable to process checkout.';
      if (data is Map<String, dynamic>) {
        final serverMessage = data['message'] as String?;
        if (serverMessage != null && serverMessage.isNotEmpty) {
          message = serverMessage;
        }
      } else if (error.message != null) {
        message = error.message!;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to checkout: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 24, offset: Offset(0, -4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: Theme.of(context).textTheme.titleMedium),
              Text('\$${widget.total.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed:
                widget.total == 0 || widget.items.isEmpty || _isProcessing
                    ? null
                    : _handleCheckout,
            icon: _isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_outline),
            label: Text(_isProcessing ? 'Processing...' : 'Secure Checkout'),
          ),
        ],
      ),
    );
  }
}

class _CartEmptyView extends StatelessWidget {
  const _CartEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse the home feed and tap "Add to cart" when a piece catches your eye.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
