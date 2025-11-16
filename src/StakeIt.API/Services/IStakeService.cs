using StakeIt.API.DTOs.Stakes;
using StakeIt.Core.Entities;

namespace StakeIt.API.Services;

public interface IStakeService
{
    Task<(bool Success, string? ErrorMessage, Stake? Stake)> CreateStakeAsync(int userId, CreateStakeRequest request);
    Task<Stake?> GetStakeByIdAsync(int stakeId);
    Task<List<Stake>> GetUserStakesAsync(int userId, bool activeOnly = false);
    Task<(bool Success, string? ErrorMessage)> CancelStakeAsync(int stakeId, int userId);
    Task<(bool Success, string? ErrorMessage, StakeProof? Proof)> SubmitProofAsync(int stakeId, int userId, SubmitProofRequest request);
    Task<List<StakeProof>> GetStakeProofsAsync(int stakeId);
    Task<(bool Success, string? ErrorMessage)> SettleStakeAsync(int stakeId);
}
