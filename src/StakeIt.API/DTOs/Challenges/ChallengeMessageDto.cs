namespace StakeIt.API.DTOs.Challenges;

public class ChallengeMessageDto
{
    public int Id { get; set; }
    public int ChallengeId { get; set; }
    public int SenderId { get; set; }
    public string SenderEmail { get; set; } = string.Empty;
    public string SenderName { get; set; } = string.Empty;
    public string? SenderAvatarUrl { get; set; }
    public string Message { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }
}
