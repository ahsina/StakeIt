using StakeIt.API.DTOs.Challenges;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;

namespace StakeIt.API.Services;

public interface IChallengeService
{
    // Challenge CRUD
    Task<(bool Success, string? ErrorMessage, Challenge? Challenge)> CreateChallengeAsync(int creatorId, CreateChallengeRequest request);
    Task<Challenge?> GetChallengeByIdAsync(int challengeId);
    Task<List<Challenge>> GetPublicChallengesAsync(ChallengeStatus? status = null, StakeCategory? category = null);
    Task<List<Challenge>> GetMyChallengesAsync(int userId);
    Task<(bool Success, string? ErrorMessage)> CancelChallengeAsync(int challengeId, int userId);

    // Participation
    Task<(bool Success, string? ErrorMessage, ChallengeParticipant? Participant)> JoinChallengeAsync(int challengeId, int userId);
    Task<(bool Success, string? ErrorMessage)> LeaveChallengeAsync(int challengeId, int userId);

    // Proofs
    Task<(bool Success, string? ErrorMessage, ChallengeProof? Proof)> SubmitProofAsync(int challengeId, int userId, SubmitChallengeProofRequest request);
    Task<List<ChallengeProof>> GetChallengeProofsAsync(int challengeId);

    // Chat
    Task<(bool Success, string? ErrorMessage, ChallengeMessage? Message)> SendMessageAsync(int challengeId, int userId, string message);
    Task<List<ChallengeMessage>> GetChallengeMessagesAsync(int challengeId, int limit = 50);

    // Leaderboard
    Task<List<ChallengeParticipant>> GetLeaderboardAsync(int challengeId);

    // Settlement
    Task<(bool Success, string? ErrorMessage)> SettleChallengeAsync(int challengeId);
}
