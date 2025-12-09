import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/listing.dart';
import '../domain/sample_listings.dart';

class ProductShowcasePage extends StatelessWidget {
  const ProductShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Showcase')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleListings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final listing = sampleListings[index];
          return _ProductCard(
            listing: listing,
            onTap: () => context.push('/listing/${listing.id}', extra: listing),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 12)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _CardPlaceholder(),
                      )
                    : const _CardPlaceholder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              listing.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${listing.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0F9D8D),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Chip(
              label: Text(listing.status.toLowerCase()),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade100,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white, size: 48),
    );
  }
}
