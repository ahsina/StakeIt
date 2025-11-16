using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Challenges;

public class ChallengeProofDto
{
    public int Id { get; set; }
    public int ChallengeId { get; set; }
    public int ParticipantId { get; set; }
    public int UserId { get; set; }
    public string UserEmail { get; set; } = string.Empty;
    public string UserName { get; set; } = string.Empty;
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public string? PhotoUrl { get; set; }
    public string? Notes { get; set; }
    public ValidationStatus ValidationStatus { get; set; }
    public string? RejectionReason { get; set; }
    public DateTime SubmittedAt { get; set; }
    public DateTime? ValidatedAt { get; set; }
}
