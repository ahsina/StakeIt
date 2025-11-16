using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

public class StakeProof : BaseEntity
{
    // Stake lié
    public int StakeId { get; set; }
    public Stake Stake { get; set; } = null!;

    // Type de preuve
    public ProofMode ProofType { get; set; }

    // Données GPS
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public int? Accuracy { get; set; } // en mètres
    public DateTime? EntryTime { get; set; }
    public DateTime? ExitTime { get; set; }
    public int? DurationMinutes { get; set; }

    // Données photo
    public string? PhotoUrl { get; set; }
    public string? PhotoMetadata { get; set; } // JSON avec EXIF data

    // Validation
    public ValidationStatus ValidationStatus { get; set; }
    public int? ValidatedBy { get; set; } // UserId du referee si applicable
    public User? ValidatedByUser { get; set; }
    public DateTime? ValidatedAt { get; set; }
    public string? RejectionReason { get; set; }
    public decimal? AIConfidenceScore { get; set; } // 0.00-1.00

    // Date de soumission
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
}
