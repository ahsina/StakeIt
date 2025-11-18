using StakeIt.API.DTOs.Leaderboard;

namespace StakeIt.API.Services;

public interface ILeaderboardService
{
    Task<LeaderboardResponse> GetGlobalLeaderboardAsync(int userId, int limit = 100);
    Task<LeaderboardResponse> GetMonthlyLeaderboardAsync(int userId, int limit = 100);
    Task<LeaderboardResponse> GetLocalLeaderboardAsync(int userId, string? city, int limit = 100);
    Task<LeaderboardResponse> GetFriendsLeaderboardAsync(int userId, int limit = 100);
    Task<LeaderboardResponse> GetCategoryLeaderboardAsync(int userId, string category, int limit = 100);
    Task<int?> GetUserGlobalRankAsync(int userId);
    Task RefreshLeaderboardCacheAsync();
}
