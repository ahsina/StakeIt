import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_constants.dart';
import '../../../shared/models/notification_model.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/utils/utils.dart';
import '../../../shared/services/navigation_service.dart';
import '../data/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(filteredNotificationsProvider(_selectedFilter));
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Unread count badge
          unreadCount.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: Text(
                          count.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await ref.read(notificationsProvider.notifier).markAllAsRead();
              ref.invalidate(unreadCountProvider);
            },
            tooltip: 'Tout marquer comme lu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: NotificationFilter.values.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.paddingS),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Notifications list
          Expanded(
            child: notificationsState.when(
              loading: () => const LoadingIndicator(
                message: 'Chargement des notifications...',
              ),
              error: (error, _) => ErrorDisplay(
                message: ErrorMapper.mapError(error),
                onRetry: () {
                  ref.read(notificationsProvider.notifier).refresh();
                },
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return EmptyState(
                    icon: Icons.notifications_none,
                    title: _selectedFilter == NotificationFilter.all
                        ? 'Aucune notification'
                        : 'Aucune notification ${_selectedFilter.label.toLowerCase()}',
                    subtitle: _selectedFilter == NotificationFilter.all
                        ? 'Vous êtes à jour !'
                        : 'Essayez un autre filtre',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(notificationsProvider.notifier).refresh();
                    ref.invalidate(unreadCountProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSizes.paddingS),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                        onDelete: () async {
                          await ref
                              .read(notificationsProvider.notifier)
                              .deleteNotification(notification.id);
                          ref.invalidate(unreadCountProvider);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
      ref.invalidate(unreadCountProvider);
    }

    // Navigate based on notification data
    if (notification.data != null) {
      NavigationService.handleNotificationNavigation(notification.data!);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.paddingM),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.surface
                : AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: AppSizes.iconM,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      DateFormatter.formatRelativeTime(notification.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    if (type.contains('stake')) return Icons.flag;
    if (type.contains('challenge')) return Icons.emoji_events;
    if (type.contains('payment') || type.contains('payout')) {
      return Icons.account_balance_wallet;
    }
    if (type.contains('badge') || type.contains('level')) {
      return Icons.military_tech;
    }
    return Icons.notifications;
  }

  Color _getNotificationColor(String type) {
    if (type.contains('stake')) return AppColors.categoryHealth;
    if (type.contains('challenge')) return AppColors.categoryProductivity;
    if (type.contains('payment') || type.contains('payout')) {
      return AppColors.success;
    }
    if (type.contains('badge') || type.contains('level')) {
      return AppColors.medalGold;
    }
    return AppColors.primary;
  }
}
