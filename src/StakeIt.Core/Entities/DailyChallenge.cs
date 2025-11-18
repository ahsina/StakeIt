using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

/// <summary>
/// Represents a daily challenge that users can complete for rewards
/// </summary>
public class DailyChallenge : BaseEntity
{
    public required string Title { get; set; }
    public required string Description { get; set; }
    public StakeCategory Category { get; set; }
    public required string Icon { get; set; } // Emoji or icon name

    // Requirements
    public DailyChallengeType Type { get; set; }
    public int RequiredCount { get; set; } // Number of times to complete
    public int DurationMinutes { get; set; } // How long the activity should take

    // Rewards
    public int XPReward { get; set; }
    public decimal? BonusEUR { get; set; } // Optional cash bonus

    // Difficulty and rarity
    public ChallengeDifficulty Difficulty { get; set; }
    public ChallengeRarity Rarity { get; set; }

    // Availability
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsActive { get; set; }

    // Navigation properties
    public ICollection<UserDailyChallengeProgress> UserProgress { get; set; } = new List<UserDailyChallengeProgress>();
}
