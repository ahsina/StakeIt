using System.ComponentModel.DataAnnotations;
using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Stakes;

public class SubmitProofRequest
{
    [Required]
    public ProofMode ProofType { get; set; }

    // GPS data
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public int? Accuracy { get; set; }
    public DateTime? EntryTime { get; set; }
    public DateTime? ExitTime { get; set; }

    // Photo data
    public string? PhotoUrl { get; set; }
    public string? PhotoMetadata { get; set; }
}
