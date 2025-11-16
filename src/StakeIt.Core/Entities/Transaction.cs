namespace StakeIt.Core.Entities;

public class Transaction : BaseEntity
{
    // User
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    // Type et montant
    public required string Type { get; set; } // StakePreAuth, StakeCapture, StakeRefund, ChallengeWin, Payout, Commission
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "EUR";
    public string Status { get; set; } = "Pending"; // Pending, Completed, Failed, Refunded

    // Références
    public int? StakeId { get; set; }
    public Stake? Stake { get; set; }
    public int? ChallengeId { get; set; }
    public Challenge? Challenge { get; set; }

    // Stripe data
    public string? StripeTransactionId { get; set; }
    public string? StripePaymentIntentId { get; set; }
    public string? StripeTransferId { get; set; }

    // Metadata
    public string? Description { get; set; }
    public DateTime? CompletedAt { get; set; }
}
