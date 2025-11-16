import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../shared/services/api_client.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsRepository(dio);
});

class NotificationsRepository {
  final Dio _dio;

  NotificationsRepository(this._dio);

  // Get all notifications
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/api/notifications');
      final List<dynamic> data = response.data['notifications'] ?? [];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.patch('/api/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/api/notifications/read-all');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _dio.delete('/api/notifications/$notificationId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/notifications/unread-count');
      return response.data['count'] ?? 0;
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
