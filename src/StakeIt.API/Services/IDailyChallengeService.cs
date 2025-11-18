using StakeIt.Core.Entities;

namespace StakeIt.API.Services;

public interface IDailyChallengeService
{
    Task<List<DailyChallenge>> GetTodaysChallengesAsync();
    Task<List<UserDailyChallengeProgress>> GetUserProgressAsync(int userId);
    Task<(bool Success, string? ErrorMessage)> UpdateProgressAsync(int userId, int challengeId, int incrementBy = 1);
    Task<(bool Success, string? ErrorMessage, int XPGained, decimal? BonusEarned)> ClaimRewardsAsync(int userId, int challengeId);
    Task GenerateDailyChallengesAsync(DateTime date);
}
