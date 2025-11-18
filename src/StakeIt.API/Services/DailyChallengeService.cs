using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class DailyChallengeService : IDailyChallengeService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<DailyChallengeService> _logger;

    public DailyChallengeService(StakeItDbContext context, ILogger<DailyChallengeService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<DailyChallenge>> GetTodaysChallengesAsync()
    {
        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        return await _context.DailyChallenges
            .Where(c => c.IsActive && c.StartDate <= DateTime.UtcNow && c.EndDate >= DateTime.UtcNow)
            .OrderBy(c => c.Difficulty)
            .ThenBy(c => c.Rarity)
            .ToListAsync();
    }

    public async Task<List<UserDailyChallengeProgress>> GetUserProgressAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        return await _context.UserDailyChallengeProgress
            .Include(p => p.DailyChallenge)
            .Where(p => p.UserId == userId &&
                        p.CreatedAt >= today &&
                        p.CreatedAt < tomorrow)
            .ToListAsync();
    }

    public async Task<(bool Success, string? ErrorMessage)> UpdateProgressAsync(int userId, int challengeId, int incrementBy = 1)
    {
        var challenge = await _context.DailyChallenges.FindAsync(challengeId);
        if (challenge == null || !challenge.IsActive)
        {
            return (false, "Challenge not found or inactive");
        }

        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        // Find or create progress
        var progress = await _context.UserDailyChallengeProgress
            .FirstOrDefaultAsync(p => p.UserId == userId &&
                                     p.DailyChallengeId == challengeId &&
                                     p.CreatedAt >= today &&
                                     p.CreatedAt < tomorrow);

        if (progress == null)
        {
            progress = new UserDailyChallengeProgress
            {
                UserId = userId,
                DailyChallengeId = challengeId,
                CurrentCount = 0,
                IsCompleted = false,
                RewardsClaimed = false,
                CreatedAt = DateTime.UtcNow
            };
            _context.UserDailyChallengeProgress.Add(progress);
        }

        // Update progress
        progress.CurrentCount += incrementBy;

        // Check if completed
        if (progress.CurrentCount >= challenge.RequiredCount && !progress.IsCompleted)
        {
            progress.IsCompleted = true;
            progress.CompletedAt = DateTime.UtcNow;
            _logger.LogInformation("User {UserId} completed daily challenge {ChallengeId}", userId, challengeId);
        }

        await _context.SaveChangesAsync();

        return (true, null);
    }

    public async Task<(bool Success, string? ErrorMessage, int XPGained, decimal? BonusEarned)> ClaimRewardsAsync(int userId, int challengeId)
    {
        var today = DateTime.UtcNow.Date;
        var tomorrow = today.AddDays(1);

        var progress = await _context.UserDailyChallengeProgress
            .Include(p => p.DailyChallenge)
            .FirstOrDefaultAsync(p => p.UserId == userId &&
                                     p.DailyChallengeId == challengeId &&
                                     p.CreatedAt >= today &&
                                     p.CreatedAt < tomorrow);

        if (progress == null)
        {
            return (false, "Progress not found", 0, null);
        }

        if (!progress.IsCompleted)
        {
            return (false, "Challenge not completed yet", 0, null);
        }

        if (progress.RewardsClaimed)
        {
            return (false, "Rewards already claimed", 0, null);
        }

        // Mark rewards as claimed
        progress.RewardsClaimed = true;
        progress.RewardsClaimedAt = DateTime.UtcNow;

        // Grant XP to user
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return (false, "User not found", 0, null);
        }

        var xpGained = progress.DailyChallenge.XPReward;
        var bonusEarned = progress.DailyChallenge.BonusEUR;

        user.TotalXP += xpGained;

        // Level up logic (simple: every 1000 XP = 1 level)
        var newLevel = (user.TotalXP / 1000) + 1;
        if (newLevel > user.CurrentLevel)
        {
            user.CurrentLevel = newLevel;
            _logger.LogInformation("User {UserId} leveled up to level {Level}", userId, newLevel);
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} claimed rewards for challenge {ChallengeId}: {XP} XP, {Bonus} EUR",
            userId, challengeId, xpGained, bonusEarned);

        return (true, null, xpGained, bonusEarned);
    }

    public async Task GenerateDailyChallengesAsync(DateTime date)
    {
        var startDate = date.Date;
        var endDate = startDate.AddDays(1).AddSeconds(-1);

        // Check if challenges already exist for this date
        var existingChallenges = await _context.DailyChallenges
            .Where(c => c.StartDate.Date == startDate)
            .ToListAsync();

        if (existingChallenges.Any())
        {
            _logger.LogInformation("Daily challenges already exist for {Date}", startDate);
            return;
        }

        var challenges = new List<DailyChallenge>();

        // Generate 3-5 challenges for the day with varying difficulty
        var challengeTemplates = new[]
        {
            new {
                Title = "Early Bird",
                Description = "Create a new stake before noon",
                Type = DailyChallengeType.CreateStake,
                Category = StakeCategory.Productivity,
                Icon = "🌅",
                RequiredCount = 1,
                DurationMinutes = 10,
                XPReward = 50,
                BonusEUR = (decimal?)null,
                Difficulty = ChallengeDifficulty.Easy,
                Rarity = ChallengeRarity.Common
            },
            new {
                Title = "Proof Master",
                Description = "Submit 3 proofs for your active stakes",
                Type = DailyChallengeType.CompleteProof,
                Category = StakeCategory.Personal_Development,
                Icon = "📸",
                RequiredCount = 3,
                DurationMinutes = 30,
                XPReward = 100,
                BonusEUR = (decimal?)null,
                Difficulty = ChallengeDifficulty.Medium,
                Rarity = ChallengeRarity.Common
            },
            new {
                Title = "High Roller",
                Description = "Create a stake worth at least 50€",
                Type = DailyChallengeType.CreateHighValueStake,
                Category = StakeCategory.Finance,
                Icon = "💰",
                RequiredCount = 1,
                DurationMinutes = 15,
                XPReward = 150,
                BonusEUR = 2.5m,
                Difficulty = ChallengeDifficulty.Hard,
                Rarity = ChallengeRarity.Uncommon
            },
            new {
                Title = "Social Butterfly",
                Description = "Invite a friend to join StakeIt",
                Type = DailyChallengeType.InviteFriend,
                Category = StakeCategory.Social,
                Icon = "🦋",
                RequiredCount = 1,
                DurationMinutes = 5,
                XPReward = 200,
                BonusEUR = 5.0m,
                Difficulty = ChallengeDifficulty.Medium,
                Rarity = ChallengeRarity.Rare
            },
            new {
                Title = "Fitness Fanatic",
                Description = "Submit a GPS proof at a gym or fitness location",
                Type = DailyChallengeType.UseGPSProof,
                Category = StakeCategory.Fitness,
                Icon = "💪",
                RequiredCount = 1,
                DurationMinutes = 60,
                XPReward = 120,
                BonusEUR = (decimal?)null,
                Difficulty = ChallengeDifficulty.Hard,
                Rarity = ChallengeRarity.Common
            }
        };

        // Select 3 random challenges
        var random = new Random(startDate.GetHashCode()); // Use date as seed for consistency
        var selectedTemplates = challengeTemplates
            .OrderBy(x => random.Next())
            .Take(3)
            .ToList();

        foreach (var template in selectedTemplates)
        {
            challenges.Add(new DailyChallenge
            {
                Title = template.Title,
                Description = template.Description,
                Category = template.Category,
                Icon = template.Icon,
                Type = template.Type,
                RequiredCount = template.RequiredCount,
                DurationMinutes = template.DurationMinutes,
                XPReward = template.XPReward,
                BonusEUR = template.BonusEUR,
                Difficulty = template.Difficulty,
                Rarity = template.Rarity,
                StartDate = startDate,
                EndDate = endDate,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            });
        }

        _context.DailyChallenges.AddRange(challenges);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Generated {Count} daily challenges for {Date}", challenges.Count, startDate);
    }
}
