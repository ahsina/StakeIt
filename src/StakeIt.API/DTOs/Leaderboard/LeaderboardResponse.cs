namespace StakeIt.API.DTOs.Leaderboard;

public class LeaderboardResponse
{
    public string LeaderboardType { get; set; } = string.Empty;
    public DateTime GeneratedAt { get; set; }
    public int TotalEntries { get; set; }
    public LeaderboardEntry? CurrentUserEntry { get; set; }
    public List<LeaderboardEntry> TopEntries { get; set; } = new();
    public List<LeaderboardEntry> NearbyEntries { get; set; } = new();
}
