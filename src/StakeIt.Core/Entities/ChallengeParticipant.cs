using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

public class ChallengeParticipant : BaseEntity
{
    // Challenge et utilisateur
    public int ChallengeId { get; set; }
    public Challenge Challenge { get; set; } = null!;

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    // Team (pour Team Battles)
    public int? TeamId { get; set; }

    // Dates
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    // Stakes
    public decimal StakeAmount { get; set; }
    public string? StripePaymentIntentId { get; set; }
    public PaymentStatus PaymentStatus { get; set; }

    // Scoring
    public int CurrentScore { get; set; }
    public int? CurrentRank { get; set; }
    public int? FinalScore { get; set; }
    public int? FinalRank { get; set; }

    // Payout
    public decimal WinAmount { get; set; }
    public string? PayoutStatus { get; set; } // Pending, Completed
    public DateTime? PayoutDate { get; set; }
}
