namespace StakeIt.Core.Entities;

public class Geofence : BaseEntity
{
    public required string Name { get; set; }
    public string? Category { get; set; } // Gym, Library, Office, Custom
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public int RadiusMeters { get; set; }
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }

    // Visibilité
    public bool IsPublic { get; set; } = true; // Public geofences partagées
    public int? CreatedByUserId { get; set; }
    public User? CreatedByUser { get; set; }

    // Navigation properties
    public ICollection<Stake> Stakes { get; set; } = new List<Stake>();
}
