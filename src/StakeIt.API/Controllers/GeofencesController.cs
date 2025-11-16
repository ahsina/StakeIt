using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class GeofencesController : ControllerBase
{
    private readonly IGeofenceService _geofenceService;

    public GeofencesController(IGeofenceService geofenceService)
    {
        _geofenceService = geofenceService;
    }

    /// <summary>
    /// Get all public geofences
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPublicGeofences([FromQuery] string? city = null, [FromQuery] string? category = null)
    {
        var geofences = await _geofenceService.GetPublicGeofencesAsync(city, category);
        return Ok(geofences);
    }

    /// <summary>
    /// Get geofence by ID
    /// </summary>
    [HttpGet("{id}")]
    [AllowAnonymous]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetGeofence(int id)
    {
        var geofence = await _geofenceService.GetGeofenceByIdAsync(id);
        if (geofence == null)
        {
            return NotFound();
        }
        return Ok(geofence);
    }

    /// <summary>
    /// Find nearby geofences
    /// </summary>
    [HttpGet("nearby")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> FindNearbyGeofences(
        [FromQuery] decimal latitude,
        [FromQuery] decimal longitude,
        [FromQuery] int radiusKm = 5)
    {
        var geofences = await _geofenceService.FindNearbyGeofencesAsync(latitude, longitude, radiusKm);
        return Ok(geofences);
    }

    /// <summary>
    /// Check if coordinates are within a geofence
    /// </summary>
    [HttpPost("{id}/check")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> CheckGeofence(
        int id,
        [FromQuery] decimal latitude,
        [FromQuery] decimal longitude)
    {
        var isWithin = await _geofenceService.IsWithinGeofenceAsync(id, latitude, longitude);
        return Ok(new { geofenceId = id, isWithin });
    }
}
