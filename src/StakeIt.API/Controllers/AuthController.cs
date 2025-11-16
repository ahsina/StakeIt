using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.DTOs.Auth;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IJwtService _jwtService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(
        IAuthService authService,
        IJwtService jwtService,
        ILogger<AuthController> logger)
    {
        _authService = authService;
        _jwtService = jwtService;
        _logger = logger;
    }

    /// <summary>
    /// Register a new user
    /// </summary>
    [HttpPost("register")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var (success, errorMessage, user) = await _authService.RegisterAsync(request);

        if (!success || user == null)
        {
            return BadRequest(new { message = errorMessage ?? "Registration failed" });
        }

        // Generate tokens
        var accessToken = _jwtService.GenerateAccessToken(user);
        var refreshToken = _jwtService.GenerateRefreshToken();

        // Calculate expiry
        var expiryMinutes = int.Parse(HttpContext.RequestServices
            .GetRequiredService<IConfiguration>()["Jwt:ExpiryMinutes"] ?? "60");
        var expiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes);

        var response = new LoginResponse
        {
            Token = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = expiresAt,
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                AvatarUrl = user.AvatarUrl,
                IsPremium = user.IsPremium,
                TotalXP = user.TotalXP,
                CurrentLevel = user.CurrentLevel,
                CurrentStreak = user.CurrentStreak
            }
        };

        _logger.LogInformation("New user registered: {Email}", user.Email);

        return Ok(response);
    }

    /// <summary>
    /// Login with email and password
    /// </summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(LoginResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var (success, errorMessage, user) = await _authService.LoginAsync(request);

        if (!success || user == null)
        {
            return Unauthorized(new { message = errorMessage ?? "Login failed" });
        }

        // Generate tokens
        var accessToken = _jwtService.GenerateAccessToken(user);
        var refreshToken = _jwtService.GenerateRefreshToken();

        // Calculate expiry
        var expiryMinutes = int.Parse(HttpContext.RequestServices
            .GetRequiredService<IConfiguration>()["Jwt:ExpiryMinutes"] ?? "60");
        var expiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes);

        var response = new LoginResponse
        {
            Token = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = expiresAt,
            User = new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                AvatarUrl = user.AvatarUrl,
                IsPremium = user.IsPremium,
                TotalXP = user.TotalXP,
                CurrentLevel = user.CurrentLevel,
                CurrentStreak = user.CurrentStreak
            }
        };

        _logger.LogInformation("User logged in: {Email}", user.Email);

        return Ok(response);
    }

    /// <summary>
    /// Get current user profile
    /// </summary>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetCurrentUser()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _authService.GetUserByIdAsync(userId);
        if (user == null)
        {
            return NotFound(new { message = "User not found" });
        }

        var userDto = new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            FirstName = user.FirstName,
            LastName = user.LastName,
            AvatarUrl = user.AvatarUrl,
            IsPremium = user.IsPremium,
            TotalXP = user.TotalXP,
            CurrentLevel = user.CurrentLevel,
            CurrentStreak = user.CurrentStreak
        };

        return Ok(userDto);
    }

    /// <summary>
    /// Test endpoint to verify authentication
    /// </summary>
    [HttpGet("test")]
    [Authorize]
    [ProducesResponseType(typeof(object), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public IActionResult TestAuth()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        var emailClaim = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;

        return Ok(new
        {
            Message = "Authentication successful!",
            UserId = userIdClaim,
            Email = emailClaim,
            Claims = User.Claims.Select(c => new { c.Type, c.Value })
        });
    }
}
