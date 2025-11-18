using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.Leaderboard;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class LeaderboardService : ILeaderboardService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<LeaderboardService> _logger;

    public LeaderboardService(StakeItDbContext context, ILogger<LeaderboardService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<LeaderboardResponse> GetGlobalLeaderboardAsync(int userId, int limit = 100)
    {
        var users = await GetRankedUsersAsync();
        var currentUserRank = users.FirstOrDefault(u => u.UserId == userId);

        var topEntries = users.Take(limit).ToList();
        var nearbyEntries = GetNearbyEntries(users, userId, 5);

        return new LeaderboardResponse
        {
            LeaderboardType = "Global",
            GeneratedAt = DateTime.UtcNow,
            TotalEntries = users.Count,
            CurrentUserEntry = currentUserRank,
            TopEntries = topEntries,
            NearbyEntries = nearbyEntries
        };
    }

    public async Task<LeaderboardResponse> GetMonthlyLeaderboardAsync(int userId, int limit = 100)
    {
        var startOfMonth = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
        var users = await GetRankedUsersAsync(startDate: startOfMonth);
        var currentUserRank = users.FirstOrDefault(u => u.UserId == userId);

        var topEntries = users.Take(limit).ToList();
        var nearbyEntries = GetNearbyEntries(users, userId, 5);

        return new LeaderboardResponse
        {
            LeaderboardType = "Monthly",
            GeneratedAt = DateTime.UtcNow,
            TotalEntries = users.Count,
            CurrentUserEntry = currentUserRank,
            TopEntries = topEntries,
            NearbyEntries = nearbyEntries
        };
    }

    public async Task<LeaderboardResponse> GetLocalLeaderboardAsync(int userId, string? city, int limit = 100)
    {
        var users = await GetRankedUsersAsync(city: city);
        var currentUserRank = users.FirstOrDefault(u => u.UserId == userId);

        var topEntries = users.Take(limit).ToList();
        var nearbyEntries = GetNearbyEntries(users, userId, 5);

        return new LeaderboardResponse
        {
            LeaderboardType = $"Local - {city ?? "Unknown"}",
            GeneratedAt = DateTime.UtcNow,
            TotalEntries = users.Count,
            CurrentUserEntry = currentUserRank,
            TopEntries = topEntries,
            NearbyEntries = nearbyEntries
        };
    }

    public async Task<LeaderboardResponse> GetFriendsLeaderboardAsync(int userId, int limit = 100)
    {
        // Get user's friends
        var friendIds = await _context.Friendships
            .Where(f => (f.UserId == userId || f.FriendId == userId) &&
                       f.Status == FriendshipStatus.Accepted)
            .Select(f => f.UserId == userId ? f.FriendId : f.UserId)
            .ToListAsync();

        friendIds.Add(userId); // Include current user

        var users = await GetRankedUsersAsync(userIds: friendIds);
        var currentUserRank = users.FirstOrDefault(u => u.UserId == userId);

        var topEntries = users.Take(limit).ToList();

        return new LeaderboardResponse
        {
            LeaderboardType = "Friends",
            GeneratedAt = DateTime.UtcNow,
            TotalEntries = users.Count,
            CurrentUserEntry = currentUserRank,
            TopEntries = topEntries,
            NearbyEntries = new List<LeaderboardEntry>() // No nearby for friends
        };
    }

    public async Task<LeaderboardResponse> GetCategoryLeaderboardAsync(int userId, string category, int limit = 100)
    {
        if (!Enum.TryParse<StakeCategory>(category, out var stakeCategory))
        {
            throw new ArgumentException($"Invalid category: {category}");
        }

        var users = await GetRankedUsersAsync(category: stakeCategory);
        var currentUserRank = users.FirstOrDefault(u => u.UserId == userId);

        var topEntries = users.Take(limit).ToList();
        var nearbyEntries = GetNearbyEntries(users, userId, 5);

        return new LeaderboardResponse
        {
            LeaderboardType = $"Category - {category}",
            GeneratedAt = DateTime.UtcNow,
            TotalEntries = users.Count,
            CurrentUserEntry = currentUserRank,
            TopEntries = topEntries,
            NearbyEntries = nearbyEntries
        };
    }

    public async Task<int?> GetUserGlobalRankAsync(int userId)
    {
        var users = await GetRankedUsersAsync();
        var userEntry = users.FirstOrDefault(u => u.UserId == userId);
        return userEntry?.Rank;
    }

    public async Task RefreshLeaderboardCacheAsync()
    {
        // This would typically refresh a Redis cache or similar
        // For now, just log that we would refresh
        _logger.LogInformation("Leaderboard cache refresh triggered at {Time}", DateTime.UtcNow);
        await Task.CompletedTask;
    }

    private async Task<List<LeaderboardEntry>> GetRankedUsersAsync(
        DateTime? startDate = null,
        string? city = null,
        List<int>? userIds = null,
        StakeCategory? category = null)
    {
        var usersQuery = _context.Users
            .Include(u => u.Stakes)
            .Include(u => u.Badges)
            .Where(u => u.AccountStatus == "Active");

        if (city != null)
        {
            usersQuery = usersQuery.Where(u => u.City == city);
        }

        if (userIds != null && userIds.Any())
        {
            usersQuery = usersQuery.Where(u => userIds.Contains(u.Id));
        }

        var users = await usersQuery.ToListAsync();

        var leaderboardEntries = users.Select(user =>
        {
            var stakes = user.Stakes.AsQueryable();

            if (startDate.HasValue)
            {
                stakes = stakes.Where(s => s.CreatedAt >= startDate.Value);
            }

            if (category.HasValue)
            {
                stakes = stakes.Where(s => s.Category == category.Value);
            }

            var stakesList = stakes.ToList();
            var completedStakes = stakesList.Count(s => s.Status == StakeStatus.Completed);
            var totalStakes = stakesList.Count;
            var successRate = totalStakes > 0 ? (decimal)completedStakes / totalStakes * 100 : 0;

            return new LeaderboardEntry
            {
                Rank = 0, // Will be set later
                UserId = user.Id,
                UserName = string.IsNullOrEmpty(user.FirstName)
                    ? user.Email.Split('@')[0]
                    : $"{user.FirstName} {user.LastName}".Trim(),
                AvatarUrl = user.AvatarUrl,
                Level = user.CurrentLevel,
                TotalXP = user.TotalXP,
                CurrentStreak = user.CurrentStreak,
                TotalStakesCompleted = completedStakes,
                TotalMoneySaved = stakesList
                    .Where(s => s.Status == StakeStatus.Completed)
                    .Sum(s => s.AmountEUR),
                SuccessRate = successRate,
                BadgesCount = user.Badges.Count,
                IsCurrentUser = false,
                IsPremium = user.IsPremium,
                City = user.City,
                Country = user.Country
            };
        })
        .OrderByDescending(e => e.TotalXP)
        .ThenByDescending(e => e.CurrentStreak)
        .ThenByDescending(e => e.SuccessRate)
        .ToList();

        // Assign ranks
        for (int i = 0; i < leaderboardEntries.Count; i++)
        {
            leaderboardEntries[i].Rank = i + 1;
        }

        return leaderboardEntries;
    }

    private List<LeaderboardEntry> GetNearbyEntries(List<LeaderboardEntry> allEntries, int userId, int range)
    {
        var userEntry = allEntries.FirstOrDefault(e => e.UserId == userId);
        if (userEntry == null)
        {
            return new List<LeaderboardEntry>();
        }

        var userRank = userEntry.Rank;
        var startRank = Math.Max(1, userRank - range);
        var endRank = Math.Min(allEntries.Count, userRank + range);

        return allEntries
            .Where(e => e.Rank >= startRank && e.Rank <= endRank)
            .Select(e =>
            {
                e.IsCurrentUser = e.UserId == userId;
                return e;
            })
            .ToList();
    }
}
