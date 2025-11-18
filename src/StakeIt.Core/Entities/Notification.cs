using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

/// <summary>
/// In-app notification for users
/// </summary>
public class Notification : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public required string Title { get; set; }
    public required string Message { get; set; }
    public NotificationType Type { get; set; }
    public NotificationPriority Priority { get; set; }

    // Related entities
    public int? StakeId { get; set; }
    public Stake? Stake { get; set; }

    public int? ChallengeId { get; set; }
    public Challenge? Challenge { get; set; }

    // Status
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }

    // Action
    public string? ActionUrl { get; set; } // Deep link to specific screen
    public string? ActionData { get; set; } // JSON data for action

    // Delivery
    public bool SentViaPush { get; set; }
    public bool SentViaEmail { get; set; }
    public DateTime? ExpiresAt { get; set; }
}
