using StakeIt.API.DTOs.User;

namespace StakeIt.API.Services;

public interface IUserProfileService
{
    Task<UserProfileResponse?> GetUserProfileAsync(int userId);
    Task<(bool Success, string? ErrorMessage)> UpdateProfileAsync(int userId, UpdateProfileRequest request);
    Task<(bool Success, string? ErrorMessage)> ChangePasswordAsync(int userId, string currentPassword, string newPassword);
    Task<(bool Success, string? ErrorMessage)> DeleteAccountAsync(int userId, string password);
    Task<Dictionary<string, object>> GetUserStatisticsAsync(int userId);
}
