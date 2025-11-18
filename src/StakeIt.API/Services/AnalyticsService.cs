using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.Analytics;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class AnalyticsService : IAnalyticsService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<AnalyticsService> _logger;

    public AnalyticsService(StakeItDbContext context, ILogger<AnalyticsService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<UserAnalyticsSummary> GetUserAnalyticsSummaryAsync(int userId, int days = 30)
    {
        var startDate = DateTime.UtcNow.AddDays(-days);

        var stakes = await _context.Stakes
            .Where(s => s.UserId == userId && s.CreatedAt >= startDate)
            .ToListAsync();

        var proofs = await _context.StakeProofs
            .Where(p => p.Stake.UserId == userId && p.CreatedAt >= startDate)
            .CountAsync();

        var user = await _context.Users
            .Include(u => u.Badges)
            .FirstOrDefaultAsync(u => u.Id == userId);

        var totalStakes = stakes.Count;
        var completedStakes = stakes.Count(s => s.Status == StakeStatus.Completed);
        var failedStakes = stakes.Count(s => s.Status == StakeStatus.Failed);
        var activeStakes = stakes.Count(s => s.Status == StakeStatus.Active);

        var badgesByCategory = user?.Badges
            .GroupBy(b => b.Category)
            .ToDictionary(g => g.Key, g => g.Count()) ?? new Dictionary<string, int>();

        return new UserAnalyticsSummary
        {
            TotalStakes = totalStakes,
            CompletedStakes = completedStakes,
            FailedStakes = failedStakes,
            ActiveStakes = activeStakes,
            SuccessRate = totalStakes > 0 ? (decimal)completedStakes / totalStakes * 100 : 0,
            TotalMoneyAtRisk = stakes.Where(s => s.Status == StakeStatus.Active).Sum(s => s.AmountEUR),
            TotalMoneySaved = stakes.Where(s => s.Status == StakeStatus.Completed).Sum(s => s.AmountEUR),
            TotalMoneyLost = stakes.Where(s => s.Status == StakeStatus.Failed).Sum(s => s.AmountEUR),
            TotalProofsSubmitted = proofs,
            CurrentStreak = user?.CurrentStreak ?? 0,
            LongestStreak = user?.LongestStreak ?? 0,
            TotalXP = user?.TotalXP ?? 0,
            CurrentLevel = user?.CurrentLevel ?? 1,
            ChallengesCompleted = 0, // Would need to query challenges
            BadgesByCategory = badgesByCategory
        };
    }

    public async Task<CategoryPerformance> GetCategoryPerformanceAsync(int userId, int days = 30)
    {
        var startDate = DateTime.UtcNow.AddDays(-days);

        var stakes = await _context.Stakes
            .Where(s => s.UserId == userId && s.CreatedAt >= startDate)
            .ToListAsync();

        var categoryStats = stakes
            .GroupBy(s => s.Category)
            .Select(g => new CategoryStats
            {
                Category = g.Key,
                TotalStakes = g.Count(),
                CompletedStakes = g.Count(s => s.Status == StakeStatus.Completed),
                FailedStakes = g.Count(s => s.Status == StakeStatus.Failed),
                SuccessRate = g.Count() > 0 ? (decimal)g.Count(s => s.Status == StakeStatus.Completed) / g.Count() * 100 : 0,
                AverageStakeAmount = g.Average(s => s.AmountEUR),
                TotalMoneySaved = g.Where(s => s.Status == StakeStatus.Completed).Sum(s => s.AmountEUR),
                TotalMoneyLost = g.Where(s => s.Status == StakeStatus.Failed).Sum(s => s.AmountEUR)
            })
            .OrderByDescending(cs => cs.TotalStakes)
            .ToList();

        return new CategoryPerformance
        {
            Categories = categoryStats
        };
    }

    public async Task<StreakAnalytics> GetStreakAnalyticsAsync(int userId)
    {
        var user = await _context.Users.FindAsync(userId);

        var last30Days = DateTime.UtcNow.AddDays(-30);
        var activeDates = await _context.StakeProofs
            .Where(p => p.Stake.UserId == userId && p.CreatedAt >= last30Days)
            .Select(p => p.CreatedAt.Date)
            .Distinct()
            .OrderBy(d => d)
            .ToListAsync();

        var totalDaysActive = await _context.StakeProofs
            .Where(p => p.Stake.UserId == userId)
            .Select(p => p.CreatedAt.Date)
            .Distinct()
            .CountAsync();

        return new StreakAnalytics
        {
            CurrentStreak = user?.CurrentStreak ?? 0,
            LongestStreak = user?.LongestStreak ?? 0,
            StreakStartDate = activeDates.Any() ? activeDates.First() : null,
            TotalDaysActive = totalDaysActive,
            ActiveDates = activeDates,
            StreakConsistency = activeDates.Count > 0 ? (decimal)activeDates.Count / 30 * 100 : 0
        };
    }

    public async Task<FinancialAnalytics> GetFinancialAnalyticsAsync(int userId, int days = 30)
    {
        var startDate = DateTime.UtcNow.AddDays(-days);

        var stakes = await _context.Stakes
            .Where(s => s.UserId == userId && s.CreatedAt >= startDate)
            .ToListAsync();

        var totalMoneySaved = stakes.Where(s => s.Status == StakeStatus.Completed).Sum(s => s.AmountEUR);
        var totalMoneyLost = stakes.Where(s => s.Status == StakeStatus.Failed).Sum(s => s.AmountEUR);
        var totalMoneyAtRisk = stakes.Where(s => s.Status == StakeStatus.Active).Sum(s => s.AmountEUR);

        var dailyBreakdown = stakes
            .Where(s => s.Status == StakeStatus.Completed || s.Status == StakeStatus.Failed)
            .GroupBy(s => s.SettledAt!.Value.Date)
            .Select(g => new DailyFinancialSummary
            {
                Date = g.Key,
                MoneySaved = g.Where(s => s.Status == StakeStatus.Completed).Sum(s => s.AmountEUR),
                MoneyLost = g.Where(s => s.Status == StakeStatus.Failed).Sum(s => s.AmountEUR),
                NetChange = g.Where(s => s.Status == StakeStatus.Completed).Sum(s => s.AmountEUR) -
                           g.Where(s => s.Status == StakeStatus.Failed).Sum(s => s.AmountEUR)
            })
            .OrderBy(d => d.Date)
            .ToList();

        var totalPotentialLoss = stakes.Sum(s => s.AmountEUR);
        var roi = totalPotentialLoss > 0 ? (totalMoneySaved / totalPotentialLoss) * 100 : 0;

        return new FinancialAnalytics
        {
            TotalMoneyAtRisk = totalMoneyAtRisk,
            TotalMoneySaved = totalMoneySaved,
            TotalMoneyLost = totalMoneyLost,
            NetSavings = totalMoneySaved - totalMoneyLost,
            AverageStakeAmount = stakes.Any() ? stakes.Average(s => s.AmountEUR) : 0,
            LargestStake = stakes.Any() ? stakes.Max(s => s.AmountEUR) : 0,
            SmallestStake = stakes.Any() ? stakes.Min(s => s.AmountEUR) : 0,
            TotalPlatformCommissionPaid = totalMoneyLost * 0.10m, // 10% commission
            ROI = roi,
            DailyBreakdown = dailyBreakdown
        };
    }

    public async Task<TimeAnalytics> GetTimeAnalyticsAsync(int userId, int days = 30)
    {
        var startDate = DateTime.UtcNow.AddDays(-days);

        var stakes = await _context.Stakes
            .Where(s => s.UserId == userId && s.CreatedAt >= startDate)
            .ToListAsync();

        var stakesByHour = stakes
            .GroupBy(s => s.CreatedAt.Hour)
            .ToDictionary(g => g.Key, g => g.Count());

        var stakesByDayOfWeek = stakes
            .GroupBy(s => (int)s.CreatedAt.DayOfWeek)
            .ToDictionary(g => g.Key, g => g.Count());

        var mostProductiveHour = stakesByHour.Any()
            ? stakesByHour.OrderByDescending(kvp => kvp.Value).First().Key
            : 0;

        var mostProductiveDayOfWeek = stakesByDayOfWeek.Any()
            ? stakesByDayOfWeek.OrderByDescending(kvp => kvp.Value).First().Key
            : 0;

        var completedStakes = stakes.Where(s => s.Status == StakeStatus.Completed && s.SettledAt.HasValue);
        var avgCompletionTime = completedStakes.Any()
            ? completedStakes.Average(s => (s.SettledAt!.Value - s.StartDate).TotalHours)
            : 0;

        var hourlyPerformance = stakes
            .GroupBy(s => s.CreatedAt.Hour)
            .Select(g => new HourlySuccessRate
            {
                Hour = g.Key,
                TotalStakes = g.Count(),
                CompletedStakes = g.Count(s => s.Status == StakeStatus.Completed),
                SuccessRate = g.Count() > 0 ? (decimal)g.Count(s => s.Status == StakeStatus.Completed) / g.Count() * 100 : 0
            })
            .OrderBy(h => h.Hour)
            .ToList();

        return new TimeAnalytics
        {
            StakesByHourOfDay = stakesByHour,
            StakesByDayOfWeek = stakesByDayOfWeek,
            MostProductiveHour = mostProductiveHour,
            MostProductiveDayOfWeek = mostProductiveDayOfWeek,
            AverageCompletionTimeHours = (decimal)avgCompletionTime,
            HourlyPerformance = hourlyPerformance
        };
    }

    public async Task<List<PerformanceTrend>> GetPerformanceTrendsAsync(int userId, int days = 90)
    {
        var startDate = DateTime.UtcNow.AddDays(-days);

        var stakes = await _context.Stakes
            .Where(s => s.UserId == userId && s.CreatedAt >= startDate)
            .ToListAsync();

        var proofsByDate = await _context.StakeProofs
            .Where(p => p.Stake.UserId == userId && p.CreatedAt >= startDate)
            .GroupBy(p => p.CreatedAt.Date)
            .ToDictionaryAsync(g => g.Key, g => g.Count());

        var trends = Enumerable.Range(0, days)
            .Select(i => DateTime.UtcNow.Date.AddDays(-i))
            .OrderBy(d => d)
            .Select(date =>
            {
                var dayStakes = stakes.Where(s => s.CreatedAt.Date == date).ToList();
                var completed = dayStakes.Count(s => s.Status == StakeStatus.Completed && s.SettledAt?.Date == date);
                var failed = dayStakes.Count(s => s.Status == StakeStatus.Failed && s.SettledAt?.Date == date);
                var total = completed + failed;

                return new PerformanceTrend
                {
                    Date = date,
                    StakesCreated = dayStakes.Count,
                    StakesCompleted = completed,
                    StakesFailed = failed,
                    SuccessRate = total > 0 ? (decimal)completed / total * 100 : 0,
                    ProofsSubmitted = proofsByDate.ContainsKey(date) ? proofsByDate[date] : 0,
                    XPGained = 0 // Would need to track XP changes
                };
            })
            .ToList();

        return trends;
    }
}
