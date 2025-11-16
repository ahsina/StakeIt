import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/stats_model.dart';
import '../../../../shared/services/api_client.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StatsRepository(dio);
});

class StatsRepository {
  final Dio _dio;

  StatsRepository(this._dio);

  // Get user stats
  Future<UserStatsModel> getUserStats() async {
    try {
      final response = await _dio.get('/api/stats');
      return UserStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get category stats
  Future<List<CategoryStatsModel>> getCategoryStats() async {
    try {
      final response = await _dio.get('/api/stats/categories');
      final List<dynamic> data = response.data['categories'] ?? [];
      return data.map((json) => CategoryStatsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get activity for date range
  Future<List<DailyActivityModel>> getActivityStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/api/stats/activity',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
      final List<dynamic> data = response.data['activity'] ?? [];
      return data.map((json) => DailyActivityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
