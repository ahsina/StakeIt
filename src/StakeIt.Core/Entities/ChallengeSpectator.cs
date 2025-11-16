namespace StakeIt.Core.Entities;

public class ChallengeSpectator : BaseEntity
{
    // Challenge et spectateur
    public int ChallengeId { get; set; }
    public Challenge Challenge { get; set; } = null!;

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    // Date
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    // Betting (optionnel)
    public int? BetOnUserId { get; set; }
    public User? BetOnUser { get; set; }
    public decimal? BetAmount { get; set; }
    public decimal? BetOdds { get; set; }
    public decimal? BetPayout { get; set; }
}
