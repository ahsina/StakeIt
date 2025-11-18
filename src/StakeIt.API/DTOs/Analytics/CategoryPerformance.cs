using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Analytics;

public class CategoryPerformance
{
    public List<CategoryStats> Categories { get; set; } = new();
}

public class CategoryStats
{
    public StakeCategory Category { get; set; }
    public int TotalStakes { get; set; }
    public int CompletedStakes { get; set; }
    public int FailedStakes { get; set; }
    public decimal SuccessRate { get; set; }
    public decimal AverageStakeAmount { get; set; }
    public decimal TotalMoneySaved { get; set; }
    public decimal TotalMoneyLost { get; set; }
}
