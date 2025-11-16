using StakeIt.API.DTOs.Auth;
using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Challenges;

public class ChallengeDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public StakeCategory Category { get; set; }
    public ChallengeType ChallengeType { get; set; }
    public ChallengeStatus Status { get; set; }
    public int MaxParticipants { get; set; }
    public int CurrentParticipants { get; set; }
    public decimal EntryFeeEUR { get; set; }
    public decimal TotalPrizePool { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int TargetCount { get; set; }
    public ProofMode ProofMode { get; set; }
    public int? GeofenceId { get; set; }
    public bool AllowSpectators { get; set; }
    public bool IsPublic { get; set; }
    public DateTime CreatedAt { get; set; }

    // Creator info
    public int CreatorId { get; set; }
    public string CreatorEmail { get; set; } = string.Empty;
    public string CreatorName { get; set; } = string.Empty;

    // Participants
    public List<ChallengeParticipantDto> Participants { get; set; } = new();

    // Computed properties
    public bool IsStarted => DateTime.UtcNow >= StartDate;
    public bool IsEnded => DateTime.UtcNow >= EndDate;
    public bool IsFull => CurrentParticipants >= MaxParticipants;
    public TimeSpan TimeUntilStart => StartDate - DateTime.UtcNow;
    public TimeSpan TimeRemaining => EndDate - DateTime.UtcNow;
    public double FillPercentage => MaxParticipants > 0 ? (double)CurrentParticipants / MaxParticipants * 100 : 0;
}

public class ChallengeParticipantDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserEmail { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public string? UserAvatarUrl { get; set; }
    public int CurrentCount { get; set; }
    public int Rank { get; set; }
    public bool HasCompleted { get; set; }
    public DateTime JoinedAt { get; set; }

    // Computed
    public double ProgressPercentage { get; set; }
}
