namespace StakeIt.Core.Entities;

public class Badge : BaseEntity
{
    public required string Name { get; set; }
    public string? Description { get; set; }
    public string? IconUrl { get; set; }
    public string? Category { get; set; } // Achievement, Streak, Social, Financial
    public string? Rarity { get; set; } // Common, Rare, Epic, Legendary
    public int XPReward { get; set; }

    // Navigation properties
    public ICollection<User> Users { get; set; } = new List<User>();
}
