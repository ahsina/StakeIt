namespace StakeIt.Core.Entities;

public class User : BaseEntity
{
    // Informations personnelles
    public required string Email { get; set; }
    public required string PasswordHash { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }

    // Localisation
    public string? Country { get; set; }
    public string? City { get; set; }

    // Stripe & Payments
    public string? StripeCustomerId { get; set; }
    public string? KYCStatus { get; set; } // Pending, Verified, Rejected

    // Account status
    public string AccountStatus { get; set; } = "Active"; // Active, Suspended, Banned

    // Premium
    public bool IsPremium { get; set; }
    public DateTime? PremiumExpiryDate { get; set; }

    // Gamification
    public int TotalXP { get; set; }
    public int CurrentLevel { get; set; } = 1;
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }

    // Dates
    public DateTime? LastLoginAt { get; set; }

    // Navigation properties
    public ICollection<Stake> Stakes { get; set; } = new List<Stake>();
    public ICollection<ChallengeParticipant> ChallengeParticipations { get; set; } = new List<ChallengeParticipant>();
    public ICollection<Badge> Badges { get; set; } = new List<Badge>();
    public ICollection<Friendship> FriendshipsInitiated { get; set; } = new List<Friendship>();
    public ICollection<Friendship> FriendshipsReceived { get; set; } = new List<Friendship>();
}
