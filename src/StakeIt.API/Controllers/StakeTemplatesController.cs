using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.Services;
using StakeIt.Core.Entities;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StakeTemplatesController : ControllerBase
{
    private readonly IStakeTemplateService _templateService;
    private readonly ILogger<StakeTemplatesController> _logger;

    public StakeTemplatesController(
        IStakeTemplateService templateService,
        ILogger<StakeTemplatesController> logger)
    {
        _templateService = templateService;
        _logger = logger;
    }

    /// <summary>
    /// Get all stake templates
    /// </summary>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetAllTemplates(
        [FromQuery] string? category = null,
        [FromQuery] string? search = null)
    {
        var templates = await _templateService.GetAllTemplatesAsync(category, search);
        return Ok(templates);
    }

    /// <summary>
    /// Get featured stake templates
    /// </summary>
    [HttpGet("featured")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetFeaturedTemplates([FromQuery] int limit = 10)
    {
        var templates = await _templateService.GetFeaturedTemplatesAsync(limit);
        return Ok(templates);
    }

    /// <summary>
    /// Get popular stake templates
    /// </summary>
    [HttpGet("popular")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetPopularTemplates([FromQuery] int limit = 10)
    {
        var templates = await _templateService.GetPopularTemplatesAsync(limit);
        return Ok(templates);
    }

    /// <summary>
    /// Get current user's custom templates
    /// </summary>
    [HttpGet("my-templates")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetMyTemplates()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var templates = await _templateService.GetUserTemplatesAsync(userId);
        return Ok(templates);
    }

    /// <summary>
    /// Get a specific template by ID
    /// </summary>
    [HttpGet("{templateId}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetTemplateById(int templateId)
    {
        var template = await _templateService.GetTemplateByIdAsync(templateId);
        if (template == null)
        {
            return NotFound(new { message = "Template not found" });
        }

        return Ok(template);
    }

    /// <summary>
    /// Create a custom stake template
    /// </summary>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateTemplate([FromBody] StakeTemplate template)
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var createdTemplate = await _templateService.CreateUserTemplateAsync(userId, template);
        return CreatedAtAction(nameof(GetTemplateById), new { templateId = createdTemplate.Id }, createdTemplate);
    }
}
