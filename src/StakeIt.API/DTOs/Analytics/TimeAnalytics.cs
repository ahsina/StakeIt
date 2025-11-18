namespace StakeIt.API.DTOs.Analytics;

public class TimeAnalytics
{
    public Dictionary<int, int> StakesByHourOfDay { get; set; } = new(); // 0-23
    public Dictionary<int, int> StakesByDayOfWeek { get; set; } = new(); // 0-6 (Sunday-Saturday)
    public int MostProductiveHour { get; set; }
    public int MostProductiveDayOfWeek { get; set; }
    public decimal AverageCompletionTimeHours { get; set; }
    public List<HourlySuccessRate> HourlyPerformance { get; set; } = new();
}

public class HourlySuccessRate
{
    public int Hour { get; set; }
    public int TotalStakes { get; set; }
    public int CompletedStakes { get; set; }
    public decimal SuccessRate { get; set; }
}
