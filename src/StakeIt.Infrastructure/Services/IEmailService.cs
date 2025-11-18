namespace StakeIt.Infrastructure.Services;

public interface IEmailService
{
    Task<bool> SendEmailVerificationAsync(string email, string verificationToken, string userName);
    Task<bool> SendPasswordResetAsync(string email, string resetToken, string userName);
    Task<bool> SendWelcomeEmailAsync(string email, string userName);
    Task<bool> SendStakeCompletedEmailAsync(string email, string userName, string stakeTitle, decimal amount);
    Task<bool> SendStakeFailedEmailAsync(string email, string userName, string stakeTitle, decimal amount);
}
