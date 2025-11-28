import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_notifier.dart';
import '../../cart/application/cart_notifier.dart';
import 'home_notifier.dart';
import '../domain/models/listing.dart';

final listingsSearchQueryProvider = StateProvider<String>((_) => '');

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final cartCount = ref.watch(cartCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VintaStep',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              'Discover pieces nearby',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Browse',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => context.push('/products'),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Badge(
              backgroundColor: Colors.white,
              label: Text('$cartCount',
                  style: const TextStyle(color: Colors.black)),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          IconButton(
            tooltip: 'Orders',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.push('/orders/history'),
          ),
          IconButton(
            tooltip: 'Admin Panel',
            icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
            onPressed: () => context.push('/admin'),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF122A45), Color(0xFFF5F7FB)],
          ),
        ),
        child: SafeArea(
          child: listingsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
              message: error.toString(),
              onRetry: () => notifier.refresh(),
            ),
            data: (listings) {
              final query = ref.watch(listingsSearchQueryProvider);
              final filteredListings = _filterListings(listings, query);
              final hasListings = filteredListings.isNotEmpty;

              return RefreshIndicator(
                onRefresh: notifier.refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                        child: _HeroHeader(hasListings: hasListings)),
                    const SliverToBoxAdapter(child: _SearchBar()),
                    SliverToBoxAdapter(
                      child: _QuickActions(
                        onViewCart: () => context.push('/cart'),
                        onCreateListing: () => context.push('/create-listing'),
                        onOrders: () => context.push('/orders/history'),
                      ),
                    ),
                    if (hasListings)
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: 'Spotlight collections',
                          actionLabel: 'See all',
                          onTap: () => context.push('/products'),
                        ),
                      ),
                    if (hasListings)
                      SliverToBoxAdapter(
                        child: _FeaturedCarousel(
                          listings: filteredListings.take(6).toList(),
                        ),
                      ),
                    if (!hasListings && listings.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      )
                    else if (!hasListings)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NoSearchResults(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _ListingCard(listing: filteredListings[index]),
                            childCount: filteredListings.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _getCrossAxisCount(context),
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 18,
                            childAspectRatio: 0.85,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-listing'),
        icon: const Icon(Icons.add),
        label: const Text('New listing'),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.hasListings});

  final bool hasListings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.place_outlined, color: Color(0xFF1B2D45)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Near you',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        hasListings
                            ? 'Fresh finds are a walk away'
                            : 'No nearby drops yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => context.push('/orders/history'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Text('Orders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Curated vintage, modern silhouettes, verified sellers.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/listing/${listing.id}', extra: listing),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 20,
                offset: Offset(0, 12)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: listing.images.isNotEmpty
                    ? Image.network(
                        listing.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ListingPlaceholder(),
                      )
                    : const _ListingPlaceholder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              listing.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${listing.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0F9D8D),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                if (listing.distanceKm != null)
                  Chip(
                    label: Text('${listing.distanceKm!.toStringAsFixed(1)} km'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(listing.status.toLowerCase()),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onViewCart,
    required this.onCreateListing,
    required this.onOrders,
  });

  final VoidCallback onViewCart;
  final VoidCallback onCreateListing;
  final VoidCallback onOrders;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _ActionTile(
            title: 'Cart',
            subtitle: 'Review finds',
            icon: Icons.shopping_bag,
            onTap: onViewCart,
          ),
          const SizedBox(width: 12),
          _ActionTile(
            title: 'Sell',
            subtitle: 'Post a listing',
            icon: Icons.add_circle_outline,
            onTap: onCreateListing,
          ),
          const SizedBox(width: 12),
          _ActionTile(
            title: 'Orders',
            subtitle: 'Track shipments',
            icon: Icons.receipt_long,
            onTap: onOrders,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF0F9D8D)),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onTap});

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onTap ?? () {},
              child: Text(actionLabel!,
                  style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final listing = listings[index];
          return GestureDetector(
            onTap: () => context.push('/listing/${listing.id}', extra: listing),
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 20,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: listing.images.isNotEmpty
                          ? Image.network(
                              listing.images.first,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : const _ListingPlaceholder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${listing.price.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: const Color(0xFF0F9D8D),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ListingPlaceholder extends StatelessWidget {
  const _ListingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade100,
            Colors.blueGrey.shade200,
          ],
        ),
      ),
      child: const Icon(Icons.image, size: 56, color: Colors.white),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 16),
          Text('No listings nearby (yet)',
              style:
                  theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Pull to refresh after adding your first drop or broaden your radius.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResults extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(listingsSearchQueryProvider);
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 52, color: Colors.white70),
          const SizedBox(height: 12),
          Text(
            'No matches found',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Try refining "${query.trim()}" or clear the search box.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(listingsSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(listingsSearchQueryProvider);

    if (_controller.text != query) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _controller,
        onChanged: (value) =>
            ref.read(listingsSearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: () =>
                      ref.read(listingsSearchQueryProvider.notifier).state = '',
                  icon: const Icon(Icons.clear),
                )
              : null,
          hintText: 'Search sneakers, denim, accessories...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

List<Listing> _filterListings(List<Listing> listings, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) {
    return listings;
  }

  return listings.where((listing) {
    final haystack = [
      listing.title,
      listing.status,
      (listing.price.toStringAsFixed(0)),
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}
