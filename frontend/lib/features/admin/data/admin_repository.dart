import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AdminRepository(dioClient);
});

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  // Dashboard
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/dashboard',
    );
    return response.data?['data'] ?? {};
  }

  // Users
  Future<List<dynamic>> getUsers() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/users',
    );
    return response.data?['data'] ?? [];
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/users/search',
      queryParameters: {'q': query},
    );
    return response.data?['data'] ?? [];
  }

  Future<Map<String, dynamic>> getUserDetail(String userId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/users/$userId',
    );
    return response.data?['data'] ?? {};
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v1/admin/users',
      data: {'email': email, 'password': password},
    );
    return response.data?['data'] ?? {};
  }

  // Orders
  Future<List<dynamic>> getOrders({String? status}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/orders',
      queryParameters: status != null ? {'status': status} : null,
    );
    return response.data?['data'] ?? [];
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v1/admin/orders/$orderId/status',
      data: {'status': status},
    );
    return response.data?['data'] ?? {};
  }

  // Categories
  Future<List<dynamic>> getCategories() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/categories',
    );
    return response.data?['data'] ?? [];
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String slug,
    String? description,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '/api/v1/admin/categories',
      data: {
        'name': name,
        'slug': slug,
        if (description != null) 'description': description,
      },
    );
    return response.data?['data'] ?? {};
  }

  Future<Map<String, dynamic>> updateCategory({
    required String categoryId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '/api/v1/admin/categories/$categoryId',
      data: updates,
    );
    return response.data?['data'] ?? {};
  }

  Future<void> deleteCategory(String categoryId) async {
    await _dioClient.delete('/api/v1/admin/categories/$categoryId');
  }

  // Reports
  Future<List<dynamic>> getReports({String? status}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/reports',
      queryParameters: status != null ? {'status': status} : null,
    );
    return response.data?['data'] ?? [];
  }

  Future<Map<String, dynamic>> updateReport({
    required String reportId,
    required String status,
    String? resolutionNotes,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '/api/v1/admin/reports/$reportId',
      data: {
        'status': status,
        if (resolutionNotes != null) 'resolutionNotes': resolutionNotes,
      },
    );
    return response.data?['data'] ?? {};
  }

  // Listings
  Future<List<dynamic>> getListings({String? status}) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/listings',
      queryParameters: status != null ? {'status': status} : null,
    );
    return response.data?['data'] ?? [];
  }

  Future<Map<String, dynamic>> updateListing({
    required String listingId,
    required String status,
  }) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      '/api/v1/admin/listings/$listingId',
      data: {'status': status},
    );
    return response.data?['data'] ?? {};
  }

  Future<void> deleteListing(String listingId) async {
    await _dioClient.delete('/api/v1/admin/listings/$listingId');
  }

  // Database
  Future<Map<String, dynamic>> getDbMetrics() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/db/metrics',
    );
    return response.data?['data'] ?? {};
  }

  Future<void> reseedDatabase() async {
    await _dioClient.post('/api/v1/admin/db/reseed');
  }

  Future<Map<String, dynamic>> exportDatabase() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      '/api/v1/admin/db/export',
    );
    return response.data?['data'] ?? {};
  }
}
