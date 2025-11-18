using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LeaderboardController : ControllerBase
{
    private readonly ILeaderboardService _leaderboardService;
    private readonly ILogger<LeaderboardController> _logger;

    public LeaderboardController(
        ILeaderboardService leaderboardService,
        ILogger<LeaderboardController> logger)
    {
        _leaderboardService = leaderboardService;
        _logger = logger;
    }

    /// <summary>
    /// Get global leaderboard
    /// </summary>
    [HttpGet("global")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetGlobalLeaderboard([FromQuery] int limit = 100)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var leaderboard = await _leaderboardService.GetGlobalLeaderboardAsync(userId, limit);
        return Ok(leaderboard);
    }

    /// <summary>
    /// Get monthly leaderboard
    /// </summary>
    [HttpGet("monthly")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMonthlyLeaderboard([FromQuery] int limit = 100)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var leaderboard = await _leaderboardService.GetMonthlyLeaderboardAsync(userId, limit);
        return Ok(leaderboard);
    }

    /// <summary>
    /// Get local leaderboard (by city)
    /// </summary>
    [HttpGet("local")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetLocalLeaderboard([FromQuery] string? city, [FromQuery] int limit = 100)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var leaderboard = await _leaderboardService.GetLocalLeaderboardAsync(userId, city, limit);
        return Ok(leaderboard);
    }

    /// <summary>
    /// Get friends leaderboard
    /// </summary>
    [HttpGet("friends")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetFriendsLeaderboard([FromQuery] int limit = 100)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var leaderboard = await _leaderboardService.GetFriendsLeaderboardAsync(userId, limit);
        return Ok(leaderboard);
    }

    /// <summary>
    /// Get category-specific leaderboard
    /// </summary>
    [HttpGet("category/{category}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetCategoryLeaderboard(string category, [FromQuery] int limit = 100)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        try
        {
            var leaderboard = await _leaderboardService.GetCategoryLeaderboardAsync(userId, category, limit);
            return Ok(leaderboard);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get current user's global rank
    /// </summary>
    [HttpGet("my-rank")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyRank()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var rank = await _leaderboardService.GetUserGlobalRankAsync(userId);
        return Ok(new { rank });
    }
}
