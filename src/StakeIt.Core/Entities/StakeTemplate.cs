using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

/// <summary>
/// Pre-defined stake templates for quick stake creation
/// </summary>
public class StakeTemplate : BaseEntity
{
    public required string Title { get; set; }
    public required string Description { get; set; }
    public StakeCategory Category { get; set; }
    public required string Icon { get; set; } // Emoji or icon name

    // Default parameters
    public decimal SuggestedAmountEUR { get; set; }
    public int SuggestedRequiredCount { get; set; }
    public int SuggestedDurationDays { get; set; }
    public ProofMode SuggestedProofMode { get; set; }
    public int? SuggestedMinimumDurationMinutes { get; set; }

    // Metadata
    public int UsageCount { get; set; }
    public decimal AverageSuccessRate { get; set; }
    public bool IsFeatured { get; set; }
    public bool IsActive { get; set; }
    public int? CreatedByUserId { get; set; } // Null for system templates
    public User? CreatedByUser { get; set; }

    // Tags for search
    public string Tags { get; set; } = string.Empty; // Comma-separated
}
