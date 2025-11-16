import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/notification_model.dart';
import '../repositories/notifications_repository.dart';

// Notifications list provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>(
  (ref) {
    final repository = ref.watch(notificationsRepositoryProvider);
    return NotificationsNotifier(repository);
  },
);

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationsRepository _repository;

  NotificationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  // Load notifications
  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      // Update local state
      state.whenData((notifications) {
        final updated = notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // Silently fail - not critical
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Update local state
      state.whenData((notifications) {
        final updated = notifications
            .map((notification) => notification.copyWith(isRead: true))
            .toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // Silently fail - not critical
    }
  }

  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);

      // Update local state
      state.whenData((notifications) {
        final updated = notifications
            .where((notification) => notification.id != notificationId)
            .toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // Silently fail - not critical
    }
  }

  // Refresh notifications
  Future<void> refresh() => loadNotifications();
}

// Unread count provider
final unreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.getUnreadCount();
});

// Filtered notifications provider
final filteredNotificationsProvider = Provider.family<
    AsyncValue<List<NotificationModel>>, NotificationFilter>(
  (ref, filter) {
    final notificationsState = ref.watch(notificationsProvider);

    return notificationsState.whenData((notifications) {
      if (filter == NotificationFilter.all) {
        return notifications;
      }

      if (filter == NotificationFilter.unread) {
        return notifications.where((n) => !n.isRead).toList();
      }

      return notifications.where((n) => filter.matches(n.type)).toList();
    });
  },
);
