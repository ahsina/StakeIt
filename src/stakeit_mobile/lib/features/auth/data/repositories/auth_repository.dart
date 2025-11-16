import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/storage_service.dart';
import '../../../../core/config/app_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthRepository(dio, storage);
});

class AuthRepository {
  final Dio _dio;
  final StorageService _storage;

  AuthRepository(this._dio, this._storage);

  // Register a new user
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '${AppConfig.authEndpoint}/register',
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save tokens and user data
      await _saveAuthData(loginResponse);

      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Login user
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '${AppConfig.authEndpoint}/login',
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Save tokens and user data
      await _saveAuthData(loginResponse);

      return loginResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get current user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('${AppConfig.authEndpoint}/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  // Get stored user data
  Future<UserModel?> getStoredUser() async {
    final userData = await _storage.getUserData();
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }

  // Private helper to save auth data
  Future<void> _saveAuthData(LoginResponse response) async {
    await _storage.saveAccessToken(response.token);
    await _storage.saveRefreshToken(response.refreshToken);
    await _storage.saveUserData(response.user.toJson());
  }

  // Private helper to handle errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 'An error occurred';
      return Exception(message);
    } else {
      return Exception('Network error. Please check your connection.');
    }
  }
}
