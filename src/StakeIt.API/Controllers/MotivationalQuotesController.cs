using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.Services;
using StakeIt.Core.Enums;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MotivationalQuotesController : ControllerBase
{
    private readonly IMotivationalQuoteService _quoteService;
    private readonly ILogger<MotivationalQuotesController> _logger;

    public MotivationalQuotesController(
        IMotivationalQuoteService quoteService,
        ILogger<MotivationalQuotesController> logger)
    {
        _quoteService = quoteService;
        _logger = logger;
    }

    /// <summary>
    /// Get a random motivational quote
    /// </summary>
    [HttpGet("random")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetRandomQuote([FromQuery] string? category = null)
    {
        StakeCategory? stakeCategory = null;
        if (!string.IsNullOrEmpty(category) && Enum.TryParse<StakeCategory>(category, out var parsed))
        {
            stakeCategory = parsed;
        }

        try
        {
            var quote = await _quoteService.GetRandomQuoteAsync(stakeCategory);
            return Ok(quote);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get the daily motivational quote (same for all users on a given day)
    /// </summary>
    [HttpGet("daily")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetDailyQuote()
    {
        try
        {
            var quote = await _quoteService.GetDailyQuoteAsync();
            return Ok(quote);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Get quotes by type
    /// </summary>
    [HttpGet("by-type/{type}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetQuotesByType(string type, [FromQuery] int limit = 10)
    {
        if (!Enum.TryParse<QuoteType>(type, out var quoteType))
        {
            return BadRequest(new { message = "Invalid quote type" });
        }

        var quotes = await _quoteService.GetQuotesByTypeAsync(quoteType, limit);
        return Ok(quotes);
    }

    /// <summary>
    /// Like a quote
    /// </summary>
    [HttpPost("{quoteId}/like")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> LikeQuote(int quoteId)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var success = await _quoteService.LikeQuoteAsync(quoteId, userId);
        if (!success)
        {
            return NotFound(new { message = "Quote not found" });
        }

        return Ok(new { message = "Quote liked successfully" });
    }
}
