using System.ComponentModel.DataAnnotations;

namespace StakeIt.API.DTOs.Challenges;

public class SubmitChallengeProofRequest
{
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public string? PhotoUrl { get; set; }

    [StringLength(500)]
    public string? Notes { get; set; }
}
