using StakeIt.Core.Enums;

namespace StakeIt.Core.Entities;

/// <summary>
/// Motivational quotes to inspire users
/// </summary>
public class MotivationalQuote : BaseEntity
{
    public required string Text { get; set; }
    public required string Author { get; set; }
    public StakeCategory? Category { get; set; } // Optional category association
    public QuoteType Type { get; set; }
    public bool IsActive { get; set; }
    public int TimesShown { get; set; }
    public int TimesLiked { get; set; }
    public string? SourceUrl { get; set; }
}
