import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    required String type,
    required String title,
    required String body,
    required bool isRead,
    required DateTime createdAt,
    Map<String, dynamic>? data,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

enum NotificationFilter {
  all,
  unread,
  stakes,
  challenges,
  payments,
  achievements,
}

extension NotificationFilterX on NotificationFilter {
  String get label {
    switch (this) {
      case NotificationFilter.all:
        return 'Toutes';
      case NotificationFilter.unread:
        return 'Non lues';
      case NotificationFilter.stakes:
        return 'Stakes';
      case NotificationFilter.challenges:
        return 'Challenges';
      case NotificationFilter.payments:
        return 'Paiements';
      case NotificationFilter.achievements:
        return 'Succès';
    }
  }

  bool matches(String notificationType) {
    switch (this) {
      case NotificationFilter.all:
        return true;
      case NotificationFilter.unread:
        return true; // Handled separately by isRead
      case NotificationFilter.stakes:
        return notificationType.contains('stake');
      case NotificationFilter.challenges:
        return notificationType.contains('challenge');
      case NotificationFilter.payments:
        return notificationType.contains('payment') ||
            notificationType.contains('payout');
      case NotificationFilter.achievements:
        return notificationType.contains('badge') ||
            notificationType.contains('level');
    }
  }
}
