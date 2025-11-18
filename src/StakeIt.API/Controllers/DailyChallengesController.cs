using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DailyChallengesController : ControllerBase
{
    private readonly IDailyChallengeService _dailyChallengeService;
    private readonly ILogger<DailyChallengesController> _logger;

    public DailyChallengesController(
        IDailyChallengeService dailyChallengeService,
        ILogger<DailyChallengesController> logger)
    {
        _dailyChallengeService = dailyChallengeService;
        _logger = logger;
    }

    /// <summary>
    /// Get today's daily challenges
    /// </summary>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetTodaysChallenges()
    {
        var challenges = await _dailyChallengeService.GetTodaysChallengesAsync();
        return Ok(challenges);
    }

    /// <summary>
    /// Get current user's progress on daily challenges
    /// </summary>
    [HttpGet("progress")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyProgress()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var progress = await _dailyChallengeService.GetUserProgressAsync(userId);
        return Ok(progress);
    }

    /// <summary>
    /// Update progress on a daily challenge
    /// </summary>
    [HttpPost("{challengeId}/progress")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateProgress(int challengeId, [FromBody] UpdateProgressRequest request)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _dailyChallengeService.UpdateProgressAsync(
            userId,
            challengeId,
            request.IncrementBy);

        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new { message = "Progress updated successfully" });
    }

    /// <summary>
    /// Claim rewards for a completed daily challenge
    /// </summary>
    [HttpPost("{challengeId}/claim")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> ClaimRewards(int challengeId)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var (success, errorMessage, xpGained, bonusEarned) = await _dailyChallengeService.ClaimRewardsAsync(
            userId,
            challengeId);

        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new
        {
            message = "Rewards claimed successfully",
            xpGained,
            bonusEarned
        });
    }

    public class UpdateProgressRequest
    {
        public int IncrementBy { get; set; } = 1;
    }
}
