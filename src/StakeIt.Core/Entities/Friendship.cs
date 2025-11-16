namespace StakeIt.Core.Entities;

public class Friendship : BaseEntity
{
    // Les deux utilisateurs
    public int UserAId { get; set; }
    public User UserA { get; set; } = null!;

    public int UserBId { get; set; }
    public User UserB { get; set; } = null!;

    // Status
    public string Status { get; set; } = "Pending"; // Pending, Accepted, Blocked

    // Dates
    public DateTime? AcceptedAt { get; set; }
}
