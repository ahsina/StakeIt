namespace StakeIt.Core.Enums;

public enum NotificationPriority
{
    Low,        // Can wait, shown in feed
    Normal,     // Standard notification
    High,       // Important, should show badge
    Urgent      // Critical, requires immediate attention
}
