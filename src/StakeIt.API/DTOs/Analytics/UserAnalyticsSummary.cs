namespace StakeIt.API.DTOs.Analytics;

public class UserAnalyticsSummary
{
    public int TotalStakes { get; set; }
    public int CompletedStakes { get; set; }
    public int FailedStakes { get; set; }
    public int ActiveStakes { get; set; }
    public decimal SuccessRate { get; set; }
    public decimal TotalMoneyAtRisk { get; set; }
    public decimal TotalMoneySaved { get; set; }
    public decimal TotalMoneyLost { get; set; }
    public int TotalProofsSubmitted { get; set; }
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public int TotalXP { get; set; }
    public int CurrentLevel { get; set; }
    public int ChallengesCompleted { get; set; }
    public Dictionary<string, int> BadgesByCategory { get; set; } = new();
}
