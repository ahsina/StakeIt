using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class NotificationService : INotificationService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(StakeItDbContext context, ILogger<NotificationService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<Notification> CreateNotificationAsync(
        int userId,
        string title,
        string message,
        NotificationType type,
        NotificationPriority priority = NotificationPriority.Normal,
        int? stakeId = null,
        int? challengeId = null,
        string? actionUrl = null,
        string? actionData = null)
    {
        var notification = new Notification
        {
            UserId = userId,
            Title = title,
            Message = message,
            Type = type,
            Priority = priority,
            StakeId = stakeId,
            ChallengeId = challengeId,
            ActionUrl = actionUrl,
            ActionData = actionData,
            IsRead = false,
            SentViaPush = false,
            SentViaEmail = false,
            ExpiresAt = DateTime.UtcNow.AddDays(30), // Expire after 30 days
            CreatedAt = DateTime.UtcNow
        };

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Notification created for user {UserId}: {Title}", userId, title);

        return notification;
    }

    public async Task<List<Notification>> GetUserNotificationsAsync(int userId, bool unreadOnly = false, int limit = 50)
    {
        var query = _context.Notifications
            .Where(n => n.UserId == userId &&
                       (n.ExpiresAt == null || n.ExpiresAt > DateTime.UtcNow));

        if (unreadOnly)
        {
            query = query.Where(n => !n.IsRead);
        }

        return await query
            .OrderByDescending(n => n.Priority)
            .ThenByDescending(n => n.CreatedAt)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<int> GetUnreadCountAsync(int userId)
    {
        return await _context.Notifications
            .CountAsync(n => n.UserId == userId &&
                           !n.IsRead &&
                           (n.ExpiresAt == null || n.ExpiresAt > DateTime.UtcNow));
    }

    public async Task<bool> MarkAsReadAsync(int notificationId, int userId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);

        if (notification == null)
        {
            return false;
        }

        notification.IsRead = true;
        notification.ReadAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return true;
    }

    public async Task<bool> MarkAllAsReadAsync(int userId)
    {
        var notifications = await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync();

        foreach (var notification in notifications)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("Marked {Count} notifications as read for user {UserId}",
            notifications.Count, userId);

        return true;
    }

    public async Task<bool> DeleteNotificationAsync(int notificationId, int userId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);

        if (notification == null)
        {
            return false;
        }

        _context.Notifications.Remove(notification);
        await _context.SaveChangesAsync();

        return true;
    }

    public async Task DeleteExpiredNotificationsAsync()
    {
        var expiredNotifications = await _context.Notifications
            .Where(n => n.ExpiresAt != null && n.ExpiresAt < DateTime.UtcNow)
            .ToListAsync();

        if (expiredNotifications.Any())
        {
            _context.Notifications.RemoveRange(expiredNotifications);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Deleted {Count} expired notifications", expiredNotifications.Count);
        }
    }

    public async Task SendStakeExpiringNotificationsAsync()
    {
        var tomorrow = DateTime.UtcNow.AddDays(1);
        var expiringStakes = await _context.Stakes
            .Where(s => s.Status == StakeStatus.Active &&
                       s.EndDate <= tomorrow &&
                       s.EndDate > DateTime.UtcNow)
            .ToListAsync();

        foreach (var stake in expiringStakes)
        {
            var hoursLeft = (stake.EndDate - DateTime.UtcNow).TotalHours;
            var message = hoursLeft < 1
                ? $"Your stake '{stake.Title}' expires in less than 1 hour!"
                : $"Your stake '{stake.Title}' expires in {Math.Round(hoursLeft)} hours!";

            await CreateNotificationAsync(
                stake.UserId,
                "Stake Expiring Soon",
                message,
                NotificationType.StakeExpiringSoon,
                NotificationPriority.High,
                stakeId: stake.Id,
                actionUrl: $"/stakes/{stake.Id}");
        }

        _logger.LogInformation("Sent {Count} stake expiring notifications", expiringStakes.Count);
    }

    public async Task SendDailyChallengeRemindersAsync()
    {
        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        // Find users who haven't completed today's challenges
        var activeUsers = await _context.Users
            .Where(u => u.AccountStatus == "Active" && u.LastLoginAt >= DateTime.UtcNow.AddDays(-7))
            .ToListAsync();

        var challengesCount = await _context.DailyChallenges
            .CountAsync(c => c.IsActive && c.StartDate.Date == today);

        if (challengesCount == 0)
        {
            return;
        }

        foreach (var user in activeUsers)
        {
            var completedCount = await _context.UserDailyChallengeProgress
                .CountAsync(p => p.UserId == user.Id &&
                               p.IsCompleted &&
                               p.CreatedAt >= today &&
                               p.CreatedAt < tomorrow);

            if (completedCount < challengesCount)
            {
                var remaining = challengesCount - completedCount;
                await CreateNotificationAsync(
                    user.Id,
                    "Daily Challenges Available",
                    $"You have {remaining} daily challenge{(remaining > 1 ? "s" : "")} left to complete!",
                    NotificationType.DailyChallengeExpiring,
                    NotificationPriority.Normal,
                    actionUrl: "/daily-challenges");
            }
        }

        _logger.LogInformation("Sent daily challenge reminders to active users");
    }
}
