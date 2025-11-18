namespace StakeIt.API.DTOs.Analytics;

public class FinancialAnalytics
{
    public decimal TotalMoneyAtRisk { get; set; }
    public decimal TotalMoneySaved { get; set; }
    public decimal TotalMoneyLost { get; set; }
    public decimal NetSavings { get; set; } // Saved - Lost
    public decimal AverageStakeAmount { get; set; }
    public decimal LargestStake { get; set; }
    public decimal SmallestStake { get; set; }
    public decimal TotalPlatformCommissionPaid { get; set; }
    public decimal ROI { get; set; } // Return on investment (money saved vs potential loss)
    public List<DailyFinancialSummary> DailyBreakdown { get; set; } = new();
}

public class DailyFinancialSummary
{
    public DateTime Date { get; set; }
    public decimal MoneySaved { get; set; }
    public decimal MoneyLost { get; set; }
    public decimal NetChange { get; set; }
}
