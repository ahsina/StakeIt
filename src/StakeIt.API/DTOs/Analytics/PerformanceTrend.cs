namespace StakeIt.API.DTOs.Analytics;

public class PerformanceTrend
{
    public DateTime Date { get; set; }
    public int StakesCreated { get; set; }
    public int StakesCompleted { get; set; }
    public int StakesFailed { get; set; }
    public decimal SuccessRate { get; set; }
    public int ProofsSubmitted { get; set; }
    public int XPGained { get; set; }
}
