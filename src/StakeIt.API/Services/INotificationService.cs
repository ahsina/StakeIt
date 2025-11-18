using StakeIt.Core.Entities;
using StakeIt.Core.Enums;

namespace StakeIt.API.Services;

public interface INotificationService
{
    Task<Notification> CreateNotificationAsync(
        int userId,
        string title,
        string message,
        NotificationType type,
        NotificationPriority priority = NotificationPriority.Normal,
        int? stakeId = null,
        int? challengeId = null,
        string? actionUrl = null,
        string? actionData = null);

    Task<List<Notification>> GetUserNotificationsAsync(int userId, bool unreadOnly = false, int limit = 50);
    Task<int> GetUnreadCountAsync(int userId);
    Task<bool> MarkAsReadAsync(int notificationId, int userId);
    Task<bool> MarkAllAsReadAsync(int userId);
    Task<bool> DeleteNotificationAsync(int notificationId, int userId);
    Task DeleteExpiredNotificationsAsync();

    // Bulk notifications
    Task SendStakeExpiringNotificationsAsync();
    Task SendDailyChallengeRemindersAsync();
}
