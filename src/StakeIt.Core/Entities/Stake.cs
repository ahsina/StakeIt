using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

public class Stake : BaseEntity
{
    // Propriétaire
    public int UserId { get; set; }
    public User User { get; set; } = null!;

    // Description de l'objectif
    public required string Title { get; set; }
    public string? Description { get; set; }
    public StakeCategory Category { get; set; }

    // Paramètres du stake
    public decimal AmountEUR { get; set; }
    public int RequiredCount { get; set; } // Combien de fois à accomplir
    public int CurrentCount { get; set; }  // Progression actuelle

    // Dates
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime? SettledAt { get; set; }

    // Mode de preuve
    public ProofMode ProofMode { get; set; }
    public int? GeofenceId { get; set; }
    public Geofence? Geofence { get; set; }
    public int? MinimumDurationMinutes { get; set; } // Pour GPS mode
    public bool RequirePhoto { get; set; }

    // Gestion de l'échec
    public FailureMode FailureMode { get; set; }
    public int? FailureDestinationId { get; set; } // CharityId ou FriendUserId

    // Paiement
    public string? StripePaymentIntentId { get; set; }
    public PaymentStatus PaymentStatus { get; set; }

    // Status
    public StakeStatus Status { get; set; }

    // Navigation properties
    public ICollection<StakeProof> Proofs { get; set; } = new List<StakeProof>();
}
