import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/order.dart';

class OrderRepository {
  OrderRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<Order>> fetchOrderHistory() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/orders',
    );

    final data = response.data;
    final items = data?['data'] as List<dynamic>? ?? const [];

    return items
        .map((item) => Order.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Order> completeOrderAndReleaseFunds(String orderId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v1/orders/$orderId/complete',
    );

    final body = response.data;
    if (body == null || body['data'] == null) {
      throw const FormatException('Invalid response when completing order');
    }

    return Order.fromMap(body['data'] as Map<String, dynamic>);
  }

  Future<List<Order>> checkoutCart(List<Map<String, dynamic>> items) async {
    if (items.isEmpty) {
      return const [];
    }

    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v1/orders/checkout',
      data: {'items': items},
    );

    final payload = response.data;
    final rawOrders = payload?['data'] as List<dynamic>? ?? const [];

    return rawOrders
        .map((order) => Order.fromMap(order as Map<String, dynamic>))
        .toList();
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OrderRepository(dioClient);
});
