import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthNotifier(dioClient);
});

class AuthState {
  static const _sentinel = Object();

  final bool isAuthenticated;
  final bool isLoading;
  final String? userId;
  final String? errorMessage;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.userId,
    this.errorMessage,
  });

  factory AuthState.unauthenticated() =>
      const AuthState(isAuthenticated: false);

  factory AuthState.authenticated({String? userId}) =>
      AuthState(isAuthenticated: true, userId: userId);

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userId,
    Object? errorMessage = _sentinel,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final DioClient _dioClient;

  AuthNotifier(this._dioClient) : super(AuthState.unauthenticated()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final token = await _dioClient.readToken();
    if (token != null && token.isNotEmpty) {
      state = AuthState.authenticated();
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final payload = response.data;
      final token = payload?['token'] as String?;
      final user = payload?['data'] as Map<String, dynamic>?;

      if (token == null) {
        throw const FormatException('Missing token in response');
      }

      await _dioClient.saveToken(token);

      state = AuthState.authenticated(userId: user?['id'] as String?);
    } on DioException catch (error) {
      final message = error.response?.data is Map
          ? (error.response?.data['message'] as String?)
          : error.message;
      state = AuthState.unauthenticated()
          .copyWith(errorMessage: message ?? 'Unable to login');
      rethrow;
    } catch (error) {
      state =
          AuthState.unauthenticated().copyWith(errorMessage: error.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    await _dioClient.deleteToken();
    state = AuthState.unauthenticated();
  }
}
