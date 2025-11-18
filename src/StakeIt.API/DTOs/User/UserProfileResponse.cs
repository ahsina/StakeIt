namespace StakeIt.API.DTOs.User;

public class UserProfileResponse
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public bool EmailVerified { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }
    public string? Country { get; set; }
    public string? City { get; set; }
    public bool IsPremium { get; set; }
    public DateTime? PremiumExpiryDate { get; set; }
    public int TotalXP { get; set; }
    public int CurrentLevel { get; set; }
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public string AccountStatus { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }

    // Statistics
    public int TotalStakes { get; set; }
    public int CompletedStakes { get; set; }
    public decimal SuccessRate { get; set; }
    public int BadgesCount { get; set; }
    public int FriendsCount { get; set; }
}
