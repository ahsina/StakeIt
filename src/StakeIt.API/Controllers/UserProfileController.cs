using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.DTOs.User;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UserProfileController : ControllerBase
{
    private readonly IUserProfileService _profileService;
    private readonly ILogger<UserProfileController> _logger;

    public UserProfileController(
        IUserProfileService profileService,
        ILogger<UserProfileController> logger)
    {
        _profileService = profileService;
        _logger = logger;
    }

    /// <summary>
    /// Get current user's profile
    /// </summary>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetProfile()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var profile = await _profileService.GetUserProfileAsync(userId);
        if (profile == null)
        {
            return NotFound(new { message = "User not found" });
        }

        return Ok(profile);
    }

    /// <summary>
    /// Get user profile by ID (for viewing other users)
    /// </summary>
    [HttpGet("{userId}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetProfileById(int userId)
    {
        var profile = await _profileService.GetUserProfileAsync(userId);
        if (profile == null)
        {
            return NotFound(new { message = "User not found" });
        }

        return Ok(profile);
    }

    /// <summary>
    /// Update current user's profile
    /// </summary>
    [HttpPut]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _profileService.UpdateProfileAsync(userId, request);
        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new { message = "Profile updated successfully" });
    }

    /// <summary>
    /// Change password
    /// </summary>
    [HttpPost("change-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _profileService.ChangePasswordAsync(
            userId,
            request.CurrentPassword,
            request.NewPassword);

        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new { message = "Password changed successfully" });
    }

    /// <summary>
    /// Get user statistics
    /// </summary>
    [HttpGet("statistics")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetStatistics()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var statistics = await _profileService.GetUserStatisticsAsync(userId);
        return Ok(statistics);
    }

    /// <summary>
    /// Delete user account
    /// </summary>
    [HttpDelete]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteAccount([FromBody] DeleteAccountRequest request)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _profileService.DeleteAccountAsync(userId, request.Password);
        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new { message = "Account deleted successfully" });
    }

    public class DeleteAccountRequest
    {
        public required string Password { get; set; }
    }
}
