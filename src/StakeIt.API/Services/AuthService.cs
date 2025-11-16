using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.Auth;
using StakeIt.Core.Entities;
using StakeIt.Infrastructure.Data;
using System.Security.Cryptography;
using System.Text;

namespace StakeIt.API.Services;

public class AuthService : IAuthService
{
    private readonly StakeItDbContext _context;

    public AuthService(StakeItDbContext context)
    {
        _context = context;
    }

    public async Task<(bool Success, string? ErrorMessage, User? User)> RegisterAsync(RegisterRequest request)
    {
        // Check if user already exists
        var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
        if (existingUser != null)
        {
            return (false, "User with this email already exists", null);
        }

        // Validate age (must be 18+)
        var age = DateTime.UtcNow.Year - request.DateOfBirth.Year;
        if (request.DateOfBirth.Date > DateTime.UtcNow.AddYears(-age)) age--;

        if (age < 18)
        {
            return (false, "You must be at least 18 years old to register", null);
        }

        // Create new user
        var user = new User
        {
            Email = request.Email,
            PasswordHash = HashPassword(request.Password),
            FirstName = request.FirstName,
            LastName = request.LastName,
            DateOfBirth = request.DateOfBirth,
            PhoneNumber = request.PhoneNumber,
            Country = request.Country,
            City = request.City,
            AccountStatus = "Active",
            IsPremium = false,
            CurrentLevel = 1,
            TotalXP = 0,
            CurrentStreak = 0,
            LongestStreak = 0,
            CreatedAt = DateTime.UtcNow,
            LastLoginAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return (true, null, user);
    }

    public async Task<(bool Success, string? ErrorMessage, User? User)> LoginAsync(LoginRequest request)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);

        if (user == null)
        {
            return (false, "Invalid email or password", null);
        }

        if (user.AccountStatus != "Active")
        {
            return (false, $"Account is {user.AccountStatus}. Please contact support.", null);
        }

        if (!VerifyPassword(request.Password, user.PasswordHash))
        {
            return (false, "Invalid email or password", null);
        }

        // Update last login
        user.LastLoginAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return (true, null, user);
    }

    public async Task<User?> GetUserByIdAsync(int userId)
    {
        return await _context.Users
            .Include(u => u.Badges)
            .FirstOrDefaultAsync(u => u.Id == userId);
    }

    public async Task<User?> GetUserByEmailAsync(string email)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
    }

    // Password hashing using PBKDF2
    private string HashPassword(string password)
    {
        byte[] salt = RandomNumberGenerator.GetBytes(128 / 8);
        byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
            Encoding.UTF8.GetBytes(password),
            salt,
            iterations: 100000,
            HashAlgorithmName.SHA256,
            outputLength: 256 / 8
        );

        return $"{Convert.ToBase64String(salt)}:{Convert.ToBase64String(hash)}";
    }

    private bool VerifyPassword(string password, string passwordHash)
    {
        var parts = passwordHash.Split(':');
        if (parts.Length != 2) return false;

        byte[] salt = Convert.FromBase64String(parts[0]);
        byte[] hash = Convert.FromBase64String(parts[1]);

        byte[] testHash = Rfc2898DeriveBytes.Pbkdf2(
            Encoding.UTF8.GetBytes(password),
            salt,
            iterations: 100000,
            HashAlgorithmName.SHA256,
            outputLength: 256 / 8
        );

        return CryptographicOperations.FixedTimeEquals(hash, testHash);
    }
}
