namespace StakeIt.API.DTOs.Analytics;

public class StreakAnalytics
{
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public DateTime? StreakStartDate { get; set; }
    public int TotalDaysActive { get; set; }
    public List<DateTime> ActiveDates { get; set; } = new();
    public decimal StreakConsistency { get; set; } // Percentage of days active in last 30 days
}
