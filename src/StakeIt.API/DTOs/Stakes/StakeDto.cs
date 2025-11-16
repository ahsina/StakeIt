using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Stakes;

public class StakeDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public required string Title { get; set; }
    public string? Description { get; set; }
    public StakeCategory Category { get; set; }
    public decimal AmountEUR { get; set; }
    public int RequiredCount { get; set; }
    public int CurrentCount { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public ProofMode ProofMode { get; set; }
    public int? GeofenceId { get; set; }
    public string? GeofenceName { get; set; }
    public int? MinimumDurationMinutes { get; set; }
    public bool RequirePhoto { get; set; }
    public FailureMode FailureMode { get; set; }
    public int? FailureDestinationId { get; set; }
    public string? StripePaymentIntentId { get; set; }
    public PaymentStatus PaymentStatus { get; set; }
    public StakeStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? SettledAt { get; set; }

    // Calculated fields
    public double ProgressPercentage => RequiredCount > 0 ? (double)CurrentCount / RequiredCount * 100 : 0;
    public TimeSpan TimeRemaining => EndDate - DateTime.UtcNow;
    public bool IsExpired => DateTime.UtcNow > EndDate;
}
