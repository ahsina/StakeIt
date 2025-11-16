using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

public class Challenge : BaseEntity
{
    // Type et créateur
    public ChallengeType Type { get; set; }
    public int CreatorUserId { get; set; }
    public User Creator { get; set; } = null!;

    // Description
    public required string Title { get; set; }
    public string? Description { get; set; }
    public string? Objective { get; set; }

    // Dates
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public DateTime? SettledAt { get; set; }

    // Scoring
    public string? ScoringMethod { get; set; } // Highest, Fastest, Accumulative

    // Status et résultat
    public ChallengeStatus Status { get; set; }
    public int? WinnerUserId { get; set; }
    public User? Winner { get; set; }

    // Settings
    public bool IsPublic { get; set; }
    public bool AllowSpectators { get; set; } = true;
    public bool AllowChat { get; set; } = true;
    public int? MaxParticipants { get; set; }

    // Navigation properties
    public ICollection<ChallengeParticipant> Participants { get; set; } = new List<ChallengeParticipant>();
    public ICollection<ChallengeProof> Proofs { get; set; } = new List<ChallengeProof>();
    public ICollection<ChallengeMessage> Messages { get; set; } = new List<ChallengeMessage>();
    public ICollection<ChallengeSpectator> Spectators { get; set; } = new List<ChallengeSpectator>();
}
