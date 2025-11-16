namespace StakeIt.Core.Entities;

public class ChallengeMessage : BaseEntity
{
    // Challenge et utilisateur
    public int ChallengeId { get; set; }
    public Challenge Challenge { get; set; } = null!;

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    // Message
    public string? MessageType { get; set; } // Chat, System, TrashTalk
    public string? MessageText { get; set; }
    public string? GifUrl { get; set; }

    // Dates et statut
    public DateTime SentAt { get; set; } = DateTime.UtcNow;
    public bool IsEdited { get; set; }
    public bool IsDeleted { get; set; }
}
