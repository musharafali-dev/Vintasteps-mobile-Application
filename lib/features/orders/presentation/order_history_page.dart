import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_notifier.dart';
import '../data/order_repository.dart';
import '../domain/models/order.dart';
import 'review_submission_page.dart';

final orderHistoryProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final repository = ref.watch(orderRepositoryProvider);
  return repository.fetchOrderHistory();
});

class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  String? _processingOrderId;

  Future<void> _refreshOrders() async {
    final future = ref.refresh(orderHistoryProvider.future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderHistoryProvider);
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: error.toString(),
          onRetry: _refreshOrders,
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No orders yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final isProcessing = _processingOrderId == order.id;
                final canConfirmDelivery = order.needsDeliveryConfirmation &&
                    currentUserId != null &&
                    order.buyerId == currentUserId;

                return _OrderCard(
                  order: order,
                  isProcessing: isProcessing,
                  onConfirmDelivery: canConfirmDelivery
                      ? () => _handleConfirmDelivery(order)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleConfirmDelivery(Order order) async {
    setState(() => _processingOrderId = order.id);
    final repository = ref.read(orderRepositoryProvider);

    try {
      await repository.completeOrderAndReleaseFunds(order.id);
      await _refreshOrders();

      if (!mounted) return;
      final reviewerId = ref.read(authNotifierProvider).userId ?? '';
      context.push(
        '/orders/review',
        extra: ReviewSubmissionArgs(
          orderId: order.id,
          reviewerId: reviewerId,
          revieweeId: order.sellerId,
          listingTitle: order.listingTitle,
        ),
      );
    } on DioException catch (error) {
      final responseData = error.response?.data;
      String message = 'Unable to complete order.';
      if (responseData is Map<String, dynamic>) {
        final serverMessage = responseData['message'] as String?;
        if (serverMessage != null && serverMessage.isNotEmpty) {
          message = serverMessage;
        }
      } else if (error.message != null) {
        message = error.message!;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to complete order: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _processingOrderId = null);
      }
    }
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isProcessing,
    this.onConfirmDelivery,
  });

  final Order order;
  final bool isProcessing;
  final VoidCallback? onConfirmDelivery;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(url: order.thumbnailUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.listingTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Order #${order.id}'),
                      const SizedBox(height: 8),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.teal),
                      ),
                      Text('Status: ${order.status}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (onConfirmDelivery != null)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : onConfirmDelivery,
                  icon: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Confirm Delivery & Release Funds'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
