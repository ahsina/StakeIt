namespace StakeIt.API.DTOs.Auth;

public class LoginResponse
{
    public required string Token { get; set; }
    public required string RefreshToken { get; set; }
    public DateTime ExpiresAt { get; set; }
    public required UserDto User { get; set; }
}

public class UserDto
{
    public int Id { get; set; }
    public required string Email { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? AvatarUrl { get; set; }
    public bool IsPremium { get; set; }
    public int TotalXP { get; set; }
    public int CurrentLevel { get; set; }
    public int CurrentStreak { get; set; }
}
