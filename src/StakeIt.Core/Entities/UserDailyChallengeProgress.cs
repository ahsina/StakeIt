namespace StakeIt.Core.Entities;

/// <summary>
/// Tracks user progress on daily challenges
/// </summary>
public class UserDailyChallengeProgress : BaseEntity
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int DailyChallengeId { get; set; }
    public DailyChallenge DailyChallenge { get; set; } = null!;

    // Progress
    public int CurrentCount { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }

    // Rewards claimed
    public bool RewardsClaimed { get; set; }
    public DateTime? RewardsClaimedAt { get; set; }
}
