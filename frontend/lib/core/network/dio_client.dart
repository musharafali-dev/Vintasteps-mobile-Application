import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Configure this constant to your development environment.
/// For Android emulator use: http://10.0.2.2:3000
/// For iOS simulator or desktop, replace with your machine IP: http://192.168.x.x:3000
const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
);

class DioClient {
  final Dio dio;
  final FlutterSecureStorage _secureStorage;

  static const _authTokenKey = 'jwt_token';

  DioClient._(this.dio, this._secureStorage);

  factory DioClient({FlutterSecureStorage? secureStorage}) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 40),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(options);
    final storage = secureStorage ?? const FlutterSecureStorage();

    final client = DioClient._(dio, storage);
    client._initializeInterceptors();
    return client;
  }

  void _initializeInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final path = options.path;

            // Add admin token for admin endpoints
            if (path.contains('/admin')) {
              options.headers['x-admin-token'] = 'vintastep-admin';
              return handler.next(options);
            }

            // Don't attach token for auth endpoints
            if (path.endsWith('/auth/login') ||
                path.endsWith('/auth/register')) {
              return handler.next(options);
            }

            final token = await _secureStorage.read(key: _authTokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            return handler.next(options);
          } catch (e, st) {
            return handler.reject(
              DioException(requestOptions: options, error: e, stackTrace: st),
            );
          }
        },
        onError: (err, handler) {
          // Optionally handle 401 here and trigger logout flow
          return handler.next(err);
        },
      ),
    );
  }

  /// Convenience wrappers
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path, {dynamic data}) =>
      dio.delete<T>(path, data: data);

  /// Expose secure storage operations for higher-level code
  Future<void> saveToken(String token) =>
      _secureStorage.write(key: _authTokenKey, value: token);
  Future<String?> readToken() => _secureStorage.read(key: _authTokenKey);
  Future<void> deleteToken() => _secureStorage.delete(key: _authTokenKey);
}

final dioClientProvider = Provider<DioClient>((ref) => DioClient());
