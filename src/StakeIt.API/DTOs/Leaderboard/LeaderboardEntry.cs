namespace StakeIt.API.DTOs.Leaderboard;

public class LeaderboardEntry
{
    public int Rank { get; set; }
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public int Level { get; set; }
    public int TotalXP { get; set; }
    public int CurrentStreak { get; set; }
    public int TotalStakesCompleted { get; set; }
    public decimal TotalMoneySaved { get; set; }
    public decimal SuccessRate { get; set; }
    public int BadgesCount { get; set; }
    public bool IsCurrentUser { get; set; }
    public bool IsPremium { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }
}
