using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.User;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;
using System.Security.Cryptography;
using System.Text;

namespace StakeIt.API.Services;

public class UserProfileService : IUserProfileService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<UserProfileService> _logger;

    public UserProfileService(StakeItDbContext context, ILogger<UserProfileService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<UserProfileResponse?> GetUserProfileAsync(int userId)
    {
        var user = await _context.Users
            .Include(u => u.Stakes)
            .Include(u => u.Badges)
            .Include(u => u.FriendshipsInitiated)
            .Include(u => u.FriendshipsReceived)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            return null;
        }

        var completedStakes = user.Stakes.Count(s => s.Status == StakeStatus.Completed);
        var totalStakes = user.Stakes.Count;
        var successRate = totalStakes > 0 ? (decimal)completedStakes / totalStakes * 100 : 0;

        var friendsCount = await _context.Friendships
            .CountAsync(f => (f.UserId == userId || f.FriendId == userId) &&
                           f.Status == FriendshipStatus.Accepted);

        return new UserProfileResponse
        {
            Id = user.Id,
            Email = user.Email,
            EmailVerified = user.EmailVerified,
            FirstName = user.FirstName,
            LastName = user.LastName,
            DateOfBirth = user.DateOfBirth,
            PhoneNumber = user.PhoneNumber,
            AvatarUrl = user.AvatarUrl,
            Country = user.Country,
            City = user.City,
            IsPremium = user.IsPremium,
            PremiumExpiryDate = user.PremiumExpiryDate,
            TotalXP = user.TotalXP,
            CurrentLevel = user.CurrentLevel,
            CurrentStreak = user.CurrentStreak,
            LongestStreak = user.LongestStreak,
            AccountStatus = user.AccountStatus,
            CreatedAt = user.CreatedAt,
            LastLoginAt = user.LastLoginAt,
            TotalStakes = totalStakes,
            CompletedStakes = completedStakes,
            SuccessRate = successRate,
            BadgesCount = user.Badges.Count,
            FriendsCount = friendsCount
        };
    }

    public async Task<(bool Success, string? ErrorMessage)> UpdateProfileAsync(int userId, UpdateProfileRequest request)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return (false, "User not found");
        }

        if (!string.IsNullOrEmpty(request.FirstName))
        {
            user.FirstName = request.FirstName;
        }

        if (!string.IsNullOrEmpty(request.LastName))
        {
            user.LastName = request.LastName;
        }

        if (request.PhoneNumber != null)
        {
            user.PhoneNumber = request.PhoneNumber;
        }

        if (request.Country != null)
        {
            user.Country = request.Country;
        }

        if (request.City != null)
        {
            user.City = request.City;
        }

        if (request.AvatarUrl != null)
        {
            user.AvatarUrl = request.AvatarUrl;
        }

        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} updated profile", userId);

        return (true, null);
    }

    public async Task<(bool Success, string? ErrorMessage)> ChangePasswordAsync(int userId, string currentPassword, string newPassword)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return (false, "User not found");
        }

        // Verify current password
        if (!VerifyPassword(currentPassword, user.PasswordHash))
        {
            return (false, "Current password is incorrect");
        }

        // Validate new password
        if (newPassword.Length < 8)
        {
            return (false, "New password must be at least 8 characters long");
        }

        // Update password
        user.PasswordHash = HashPassword(newPassword);
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} changed password", userId);

        return (true, null);
    }

    public async Task<(bool Success, string? ErrorMessage)> DeleteAccountAsync(int userId, string password)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return (false, "User not found");
        }

        // Verify password
        if (!VerifyPassword(password, user.PasswordHash))
        {
            return (false, "Password is incorrect");
        }

        // Soft delete - just mark as deleted
        user.AccountStatus = "Deleted";
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} deleted account", userId);

        return (true, null);
    }

    public async Task<Dictionary<string, object>> GetUserStatisticsAsync(int userId)
    {
        var user = await _context.Users
            .Include(u => u.Stakes)
            .Include(u => u.Badges)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user == null)
        {
            return new Dictionary<string, object>();
        }

        var stakes = user.Stakes.ToList();
        var completedStakes = stakes.Count(s => s.Status == StakeStatus.Completed);
        var failedStakes = stakes.Count(s => s.Status == StakeStatus.Failed);
        var activeStakes = stakes.Count(s => s.Status == StakeStatus.Active);

        var moneySaved = stakes.Where(s => s.Status == StakeStatus.Completed).Sum(s => s.AmountEUR);
        var moneyLost = stakes.Where(s => s.Status == StakeStatus.Failed).Sum(s => s.AmountEUR);

        var challengesParticipated = await _context.ChallengeParticipants
            .CountAsync(cp => cp.UserId == userId);

        var challengesWon = await _context.ChallengeParticipants
            .CountAsync(cp => cp.UserId == userId && cp.IsWinner);

        var dailyChallengesCompleted = await _context.UserDailyChallengeProgress
            .CountAsync(p => p.UserId == userId && p.IsCompleted);

        return new Dictionary<string, object>
        {
            { "totalStakes", stakes.Count },
            { "completedStakes", completedStakes },
            { "failedStakes", failedStakes },
            { "activeStakes", activeStakes },
            { "successRate", stakes.Count > 0 ? (decimal)completedStakes / stakes.Count * 100 : 0 },
            { "moneySaved", moneySaved },
            { "moneyLost", moneyLost },
            { "netSavings", moneySaved - moneyLost },
            { "currentStreak", user.CurrentStreak },
            { "longestStreak", user.LongestStreak },
            { "totalXP", user.TotalXP },
            { "currentLevel", user.CurrentLevel },
            { "badgesCount", user.Badges.Count },
            { "challengesParticipated", challengesParticipated },
            { "challengesWon", challengesWon },
            { "dailyChallengesCompleted", dailyChallengesCompleted }
        };
    }

    private string HashPassword(string password)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(128 / 8);
        byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
            Encoding.UTF8.GetBytes(password),
            salt,
            iterations: 100000,
            HashAlgorithmName.SHA256,
            outputLength: 256 / 8
        );

        return $"{Convert.ToBase64String(salt)}:{Convert.ToBase64String(hash)}";
    }

    private bool VerifyPassword(string password, string passwordHash)
    {
        var parts = passwordHash.Split(':');
        if (parts.Length != 2) return false;

        byte[] salt = Convert.FromBase64String(parts[0]);
        byte[] hash = Convert.FromBase64String(parts[1]);

        byte[] testHash = Rfc2898DeriveBytes.Pbkdf2(
            Encoding.UTF8.GetBytes(password),
            salt,
            iterations: 100000,
            HashAlgorithmName.SHA256,
            outputLength: 256 / 8
        );

        return CryptographicOperations.FixedTimeEquals(hash, testHash);
    }
}
