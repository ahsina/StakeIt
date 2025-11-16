using System.ComponentModel.DataAnnotations;
using StakeIt.Core.Enums;

namespace StakeIt.API.DTOs.Stakes;

public class CreateStakeRequest
{
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
    public required string Title { get; set; }

    [StringLength(1000, ErrorMessage = "Description cannot exceed 1000 characters")]
    public string? Description { get; set; }

    [Required(ErrorMessage = "Category is required")]
    public StakeCategory Category { get; set; }

    [Required(ErrorMessage = "Amount is required")]
    [Range(5.00, 500.00, ErrorMessage = "Amount must be between 5€ and 500€")]
    public decimal AmountEUR { get; set; }

    [Required(ErrorMessage = "Required count is required")]
    [Range(1, 100, ErrorMessage = "Required count must be between 1 and 100")]
    public int RequiredCount { get; set; }

    [Required(ErrorMessage = "End date is required")]
    [DataType(DataType.DateTime)]
    public DateTime EndDate { get; set; }

    [Required(ErrorMessage = "Proof mode is required")]
    public ProofMode ProofMode { get; set; }

    public int? GeofenceId { get; set; }

    [Range(5, 240, ErrorMessage = "Minimum duration must be between 5 and 240 minutes")]
    public int? MinimumDurationMinutes { get; set; }

    public bool RequirePhoto { get; set; }

    [Required(ErrorMessage = "Failure mode is required")]
    public FailureMode FailureMode { get; set; }

    public int? FailureDestinationId { get; set; }
}
