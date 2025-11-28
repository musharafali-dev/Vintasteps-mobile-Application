import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../cart/application/cart_notifier.dart';
import '../domain/models/listing.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.listing});

  final Listing? listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedListing = listing;
    if (resolvedListing == null) {
      return const _MissingListingView();
    }

    final cartItems = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final isInCart =
        cartItems.any((item) => item.listing.id == resolvedListing.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(listing: resolvedListing),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${resolvedListing.price.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: const Color(0xFF0F9D8D),
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Chip(label: Text(resolvedListing.status.toLowerCase())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Description',
                    body:
                        '${resolvedListing.title} is ready for a second life. Reach out if you need exact measurements or fit notes.',
                  ),
                  const SizedBox(height: 16),
                  const _SectionCard(
                    title: 'Meetup & Safety',
                    body:
                        'Coordinate a safe meetup spot after checkout. Payments are held securely in escrow until you confirm delivery.',
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Location',
                    body:
                        'Approximate coordinates: ${resolvedListing.location.latitude.toStringAsFixed(3)}, ${resolvedListing.location.longitude.toStringAsFixed(3)}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _DetailActions(
        isInCart: isInCart,
        onMessage: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Messaging coming soon.')),
        ),
        onAddToCart: isInCart
            ? null
            : () {
                cartNotifier.addToCart(resolvedListing);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart')),
                );
              },
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          listing.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _DetailHero(listing: listing),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final hasImages = listing.images.isNotEmpty;

    return PageView.builder(
      itemCount: hasImages ? listing.images.length : 1,
      itemBuilder: (context, index) {
        if (!hasImages) {
          return Container(
            color: Colors.blueGrey.shade100,
            child: const Icon(Icons.image, size: 96, color: Colors.white),
          );
        }

        return Image.network(
          listing.images[index],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.blueGrey.shade200,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.isInCart,
    required this.onMessage,
    required this.onAddToCart,
  });

  final bool isInCart;
  final VoidCallback onMessage;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 24, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMessage,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Message'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.shopping_bag),
              label: Text(isInCart ? 'In cart' : 'Add to cart'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingListingView extends StatelessWidget {
  const _MissingListingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Listing details unavailable.'),
        ),
      ),
    );
  }
}
