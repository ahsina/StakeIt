using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Net.Mail;

namespace StakeIt.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;
    private readonly IConfiguration _configuration;
    private readonly string _smtpHost;
    private readonly int _smtpPort;
    private readonly string _smtpUsername;
    private readonly string _smtpPassword;
    private readonly string _fromEmail;
    private readonly string _fromName;
    private readonly string _appUrl;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _logger = logger;
        _configuration = configuration;

        _smtpHost = configuration["Email:SmtpHost"] ?? "smtp.gmail.com";
        _smtpPort = int.Parse(configuration["Email:SmtpPort"] ?? "587");
        _smtpUsername = configuration["Email:SmtpUsername"] ?? "";
        _smtpPassword = configuration["Email:SmtpPassword"] ?? "";
        _fromEmail = configuration["Email:FromEmail"] ?? "noreply@stakeit.app";
        _fromName = configuration["Email:FromName"] ?? "StakeIt";
        _appUrl = configuration["AppSettings:AppUrl"] ?? "https://stakeit.app";
    }

    public async Task<bool> SendEmailVerificationAsync(string email, string verificationToken, string userName)
    {
        try
        {
            var verificationUrl = $"{_appUrl}/verify-email?token={verificationToken}";

            var subject = "Verify your StakeIt email address";
            var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #4F46E5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }}
        .button {{ display: inline-block; background-color: #4F46E5; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Welcome to StakeIt!</h1>
        </div>
        <div class='content'>
            <p>Hi {userName},</p>
            <p>Thanks for signing up! Please verify your email address to get started with StakeIt.</p>
            <p style='text-align: center;'>
                <a href='{verificationUrl}' class='button'>Verify Email Address</a>
            </p>
            <p>Or copy and paste this link in your browser:</p>
            <p style='word-break: break-all; color: #4F46E5;'>{verificationUrl}</p>
            <p>This link will expire in 24 hours.</p>
            <p>If you didn't create an account, you can safely ignore this email.</p>
        </div>
        <div class='footer'>
            <p>&copy; 2024 StakeIt. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(email, subject, body);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending verification email to {Email}", email);
            return false;
        }
    }

    public async Task<bool> SendPasswordResetAsync(string email, string resetToken, string userName)
    {
        try
        {
            var resetUrl = $"{_appUrl}/reset-password?token={resetToken}";

            var subject = "Reset your StakeIt password";
            var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #DC2626; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }}
        .button {{ display: inline-block; background-color: #DC2626; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin: 20px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Password Reset</h1>
        </div>
        <div class='content'>
            <p>Hi {userName},</p>
            <p>We received a request to reset your password. Click the button below to create a new password:</p>
            <p style='text-align: center;'>
                <a href='{resetUrl}' class='button'>Reset Password</a>
            </p>
            <p>Or copy and paste this link in your browser:</p>
            <p style='word-break: break-all; color: #DC2626;'>{resetUrl}</p>
            <p>This link will expire in 1 hour.</p>
            <p><strong>If you didn't request a password reset, please ignore this email and your password will remain unchanged.</strong></p>
        </div>
        <div class='footer'>
            <p>&copy; 2024 StakeIt. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(email, subject, body);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending password reset email to {Email}", email);
            return false;
        }
    }

    public async Task<bool> SendWelcomeEmailAsync(string email, string userName)
    {
        try
        {
            var subject = "Welcome to StakeIt - Start achieving your goals!";
            var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #10B981; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }}
        .feature {{ margin: 15px 0; padding: 15px; background-color: white; border-radius: 6px; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎯 Welcome to StakeIt!</h1>
        </div>
        <div class='content'>
            <p>Hi {userName},</p>
            <p>Your email has been verified! You're all set to start using StakeIt.</p>

            <h2>What's Next?</h2>
            <div class='feature'>
                <h3>💰 Create Your First Stake</h3>
                <p>Put money on the line to motivate yourself. When there's something at stake, you're more likely to succeed!</p>
            </div>

            <div class='feature'>
                <h3>🤝 Challenge Friends</h3>
                <p>Compete with friends in duels, team battles, or asymmetric bets. Make achieving goals more fun!</p>
            </div>

            <div class='feature'>
                <h3>🏆 Earn Rewards</h3>
                <p>Level up, unlock badges, and climb the leaderboards as you complete your goals.</p>
            </div>

            <p>Ready to get started? Open the app and create your first stake!</p>
        </div>
        <div class='footer'>
            <p>&copy; 2024 StakeIt. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(email, subject, body);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending welcome email to {Email}", email);
            return false;
        }
    }

    public async Task<bool> SendStakeCompletedEmailAsync(string email, string userName, string stakeTitle, decimal amount)
    {
        try
        {
            var subject = $"🎉 Congratulations! You completed: {stakeTitle}";
            var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #10B981; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }}
        .amount {{ font-size: 32px; font-weight: bold; color: #10B981; text-align: center; margin: 20px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎉 Success!</h1>
        </div>
        <div class='content'>
            <p>Hi {userName},</p>
            <p>Congratulations! You've successfully completed your stake:</p>
            <h2 style='text-align: center; color: #4F46E5;'>{stakeTitle}</h2>
            <div class='amount'>€{amount:F2} Saved!</div>
            <p>Your pre-authorized payment has been released and you keep your money. Great job staying committed to your goal!</p>
            <p>Keep up the momentum and create your next stake to continue building positive habits.</p>
        </div>
        <div class='footer'>
            <p>&copy; 2024 StakeIt. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(email, subject, body);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending stake completed email to {Email}", email);
            return false;
        }
    }

    public async Task<bool> SendStakeFailedEmailAsync(string email, string userName, string stakeTitle, decimal amount)
    {
        try
        {
            var subject = $"Stake Failed: {stakeTitle}";
            var body = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #DC2626; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }}
        .content {{ background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }}
        .amount {{ font-size: 32px; font-weight: bold; color: #DC2626; text-align: center; margin: 20px 0; }}
        .footer {{ text-align: center; margin-top: 20px; color: #666; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Stake Failed</h1>
        </div>
        <div class='content'>
            <p>Hi {userName},</p>
            <p>Unfortunately, you didn't complete your stake:</p>
            <h2 style='text-align: center; color: #4F46E5;'>{stakeTitle}</h2>
            <div class='amount'>€{amount:F2} Charged</div>
            <p>Your payment has been processed according to your failure settings.</p>
            <p>Don't be discouraged! Every setback is a learning opportunity. Create a new stake and try again - you've got this!</p>
            <p><strong>Remember:</strong> The key to success is persistence. Keep pushing forward!</p>
        </div>
        <div class='footer'>
            <p>&copy; 2024 StakeIt. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";

            return await SendEmailAsync(email, subject, body);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending stake failed email to {Email}", email);
            return false;
        }
    }

    private async Task<bool> SendEmailAsync(string toEmail, string subject, string htmlBody)
    {
        try
        {
            // If SMTP is not configured, just log and return true (for development)
            if (string.IsNullOrEmpty(_smtpUsername) || string.IsNullOrEmpty(_smtpPassword))
            {
                _logger.LogInformation("Email would be sent to {Email}: {Subject}", toEmail, subject);
                _logger.LogDebug("Email body: {Body}", htmlBody);
                return true;
            }

            using var smtpClient = new SmtpClient(_smtpHost, _smtpPort)
            {
                Credentials = new NetworkCredential(_smtpUsername, _smtpPassword),
                EnableSsl = true,
                Timeout = 10000
            };

            var mailMessage = new MailMessage
            {
                From = new MailAddress(_fromEmail, _fromName),
                Subject = subject,
                Body = htmlBody,
                IsBodyHtml = true
            };
            mailMessage.To.Add(toEmail);

            await smtpClient.SendMailAsync(mailMessage);

            _logger.LogInformation("Email sent successfully to {Email}: {Subject}", toEmail, subject);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send email to {Email}: {Subject}", toEmail, subject);
            return false;
        }
    }
}
