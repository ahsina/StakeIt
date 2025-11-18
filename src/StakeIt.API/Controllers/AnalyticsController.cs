using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AnalyticsController : ControllerBase
{
    private readonly IAnalyticsService _analyticsService;
    private readonly ILogger<AnalyticsController> _logger;

    public AnalyticsController(
        IAnalyticsService analyticsService,
        ILogger<AnalyticsController> logger)
    {
        _analyticsService = analyticsService;
        _logger = logger;
    }

    /// <summary>
    /// Get user analytics summary
    /// </summary>
    [HttpGet("summary")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetSummary([FromQuery] int days = 30)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var summary = await _analyticsService.GetUserAnalyticsSummaryAsync(userId, days);
        return Ok(summary);
    }

    /// <summary>
    /// Get category performance analytics
    /// </summary>
    [HttpGet("category-performance")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetCategoryPerformance([FromQuery] int days = 30)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var performance = await _analyticsService.GetCategoryPerformanceAsync(userId, days);
        return Ok(performance);
    }

    /// <summary>
    /// Get streak analytics
    /// </summary>
    [HttpGet("streaks")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetStreakAnalytics()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var streaks = await _analyticsService.GetStreakAnalyticsAsync(userId);
        return Ok(streaks);
    }

    /// <summary>
    /// Get financial analytics
    /// </summary>
    [HttpGet("financial")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetFinancialAnalytics([FromQuery] int days = 30)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var financial = await _analyticsService.GetFinancialAnalyticsAsync(userId, days);
        return Ok(financial);
    }

    /// <summary>
    /// Get time-based analytics
    /// </summary>
    [HttpGet("time")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetTimeAnalytics([FromQuery] int days = 30)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var timeAnalytics = await _analyticsService.GetTimeAnalyticsAsync(userId, days);
        return Ok(timeAnalytics);
    }

    /// <summary>
    /// Get performance trends over time
    /// </summary>
    [HttpGet("trends")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetPerformanceTrends([FromQuery] int days = 90)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var trends = await _analyticsService.GetPerformanceTrendsAsync(userId, days);
        return Ok(trends);
    }
}
