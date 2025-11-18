using StakeIt.API.DTOs.Analytics;

namespace StakeIt.API.Services;

public interface IAnalyticsService
{
    Task<UserAnalyticsSummary> GetUserAnalyticsSummaryAsync(int userId, int days = 30);
    Task<CategoryPerformance> GetCategoryPerformanceAsync(int userId, int days = 30);
    Task<StreakAnalytics> GetStreakAnalyticsAsync(int userId);
    Task<FinancialAnalytics> GetFinancialAnalyticsAsync(int userId, int days = 30);
    Task<TimeAnalytics> GetTimeAnalyticsAsync(int userId, int days = 30);
    Task<List<PerformanceTrend>> GetPerformanceTrendsAsync(int userId, int days = 90);
}
