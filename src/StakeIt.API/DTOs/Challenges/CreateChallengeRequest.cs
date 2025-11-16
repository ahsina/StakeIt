using System.ComponentModel.DataAnnotations;
using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Challenges;

public class CreateChallengeRequest
{
    [Required]
    [StringLength(200, MinimumLength = 3)]
    public required string Title { get; set; }

    [StringLength(1000)]
    public string? Description { get; set; }

    [Required]
    public StakeCategory Category { get; set; }

    [Required]
    public ChallengeType ChallengeType { get; set; }

    [Required]
    [Range(2, 100)]
    public int MaxParticipants { get; set; }

    [Required]
    [Range(5.00, 500.00)]
    public decimal EntryFeeEUR { get; set; }

    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    [Required]
    [Range(1, 1000)]
    public int TargetCount { get; set; }

    [Required]
    public ProofMode ProofMode { get; set; }

    public int? GeofenceId { get; set; }

    public bool AllowSpectators { get; set; } = true;

    public bool IsPublic { get; set; } = true;
}
