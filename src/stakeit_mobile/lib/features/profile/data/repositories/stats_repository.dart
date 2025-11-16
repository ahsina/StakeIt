import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../shared/models/badge_model.dart';

// Provider for stats repository
final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return StatsRepository(dio);
});

class StatsRepository {
  final Dio _dio;

  StatsRepository(this._dio);

  /// Get user statistics
  Future<UserStatsModel> getUserStats() async {
    try {
      final response = await _dio.get('${AppConfig.usersEndpoint}/stats');
      return UserStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all badges (earned and unearned)
  Future<List<BadgeModel>> getBadges() async {
    try {
      final response = await _dio.get('${AppConfig.usersEndpoint}/badges');
      return (response.data as List)
          .map((badge) => BadgeModel.fromJson(badge))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
      return 'Erreur: ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Timeout de connexion';
    }
    if (e.type == DioExceptionType.unknown) {
      return 'Erreur de connexion au serveur';
    }
    return 'Une erreur est survenue';
  }
}
