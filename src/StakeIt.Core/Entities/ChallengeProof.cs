using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

public class ChallengeProof : BaseEntity
{
    // Challenge et participant
    public int ChallengeId { get; set; }
    public Challenge Challenge { get; set; } = null!;

    public int ParticipantId { get; set; }
    public ChallengeParticipant Participant { get; set; } = null!;

    // Type de preuve
    public ProofMode ProofType { get; set; }

    // Données GPS
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }

    // Données photo
    public string? PhotoUrl { get; set; }

    // Validation
    public ValidationStatus ValidationStatus { get; set; }

    // Score
    public int ScoreIncrement { get; set; } // +1 point, +5km, etc.

    // Date
    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
}
