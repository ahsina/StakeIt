using StakeIt.API.DTOs.Auth;
using StakeIt.Core.Entities;

namespace StakeIt.API.Services;

public interface IAuthService
{
    Task<(bool Success, string? ErrorMessage, User? User)> RegisterAsync(RegisterRequest request);
    Task<(bool Success, string? ErrorMessage, User? User)> LoginAsync(LoginRequest request);
    Task<User?> GetUserByIdAsync(int userId);
    Task<User?> GetUserByEmailAsync(string email);
    Task<(bool Success, string? ErrorMessage)> SendEmailVerificationAsync(string email);
    Task<(bool Success, string? ErrorMessage)> VerifyEmailAsync(string token);
    Task<(bool Success, string? ErrorMessage)> RequestPasswordResetAsync(string email);
    Task<(bool Success, string? ErrorMessage)> ResetPasswordAsync(string token, string newPassword);
}
