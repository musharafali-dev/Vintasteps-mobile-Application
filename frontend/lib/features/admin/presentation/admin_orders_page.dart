import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import 'widgets/admin_app_bar.dart';
import 'widgets/admin_drawer.dart';

final adminOrdersProvider =
    FutureProvider.family<List<dynamic>, String?>((ref, status) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getOrders(status: status);
});

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String? _selectedStatus;

  final List<Map<String, String>> _statusOptions = [
    {'value': '', 'label': 'All Statuses'},
    {'value': 'pending_payment', 'label': 'Pending Payment'},
    {'value': 'pending_shipment', 'label': 'Pending Shipment'},
    {'value': 'shipped', 'label': 'Shipped'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      await repository.updateOrderStatus(orderId: orderId, status: newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated')),
        );
        ref.invalidate(adminOrdersProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider(
        _selectedStatus?.isEmpty == true ? null : _selectedStatus));

    return Scaffold(
      appBar: AdminAppBar(
        title: 'Order Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminOrdersProvider),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedStatus ?? '',
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _statusOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminOrdersProvider),
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderListItem(
                        order: order,
                        onUpdateStatus: (newStatus) {
                          _updateOrderStatus(order['id'], newStatus);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(String) onUpdateStatus;

  const _OrderListItem({
    required this.order,
    required this.onUpdateStatus,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'pending_shipment':
        return Colors.orange;
      case 'pending_payment':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'unknown';
    final totalAmount = order['total_amount'] ?? 0;
    final orderId = order['id'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          Icons.shopping_cart,
          color: _getStatusColor(status),
        ),
        title: Text('Order ${orderId.substring(0, 10)}...'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                status.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: _getStatusColor(status),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Buyer: ${order['buyer_email'] ?? order['buyer_id'] ?? 'N/A'}'),
                Text(
                    'Seller: ${order['seller_email'] ?? order['seller_id'] ?? 'N/A'}'),
                Text('Placed: ${order['placed_at'] ?? 'N/A'}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Update Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'pending_payment',
                        child: Text('Pending Payment')),
                    DropdownMenuItem(
                        value: 'pending_shipment',
                        child: Text('Pending Shipment')),
                    DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                    DropdownMenuItem(
                        value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(
                        value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onUpdateStatus(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
