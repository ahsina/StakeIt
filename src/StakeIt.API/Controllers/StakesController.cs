using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.DTOs.Stakes;
using StakeIt.API.Services;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StakesController : ControllerBase
{
    private readonly IStakeService _stakeService;
    private readonly ILogger<StakesController> _logger;

    public StakesController(IStakeService stakeService, ILogger<StakesController> logger)
    {
        _stakeService = stakeService;
        _logger = logger;
    }

    /// <summary>
    /// Create a new stake
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(StakeDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateStake([FromBody] CreateStakeRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var userId = GetCurrentUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var (success, errorMessage, stake) = await _stakeService.CreateStakeAsync(userId.Value, request);

        if (!success || stake == null)
        {
            return BadRequest(new { message = errorMessage });
        }

        var stakeDto = MapToDto(stake);
        return CreatedAtAction(nameof(GetStake), new { id = stake.Id }, stakeDto);
    }

    /// <summary>
    /// Get stake by ID
    /// </summary>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(StakeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetStake(int id)
    {
        var stake = await _stakeService.GetStakeByIdAsync(id);
        if (stake == null)
        {
            return NotFound();
        }

        var stakeDto = MapToDto(stake);
        return Ok(stakeDto);
    }

    /// <summary>
    /// Get all stakes for current user
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<StakeDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyStakes([FromQuery] bool activeOnly = false)
    {
        var userId = GetCurrentUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var stakes = await _stakeService.GetUserStakesAsync(userId.Value, activeOnly);
        var stakeDtos = stakes.Select(MapToDto).ToList();

        return Ok(stakeDtos);
    }

    /// <summary>
    /// Cancel a stake (within cancellation window)
    /// </summary>
    [HttpPost("{id}/cancel")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CancelStake(int id)
    {
        var userId = GetCurrentUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _stakeService.CancelStakeAsync(id, userId.Value);

        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new { message = "Stake cancelled successfully" });
    }

    /// <summary>
    /// Submit proof for a stake
    /// </summary>
    [HttpPost("{id}/proofs")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SubmitProof(int id, [FromBody] SubmitProofRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var userId = GetCurrentUserId();
        if (userId == null)
        {
            return Unauthorized();
        }

        var (success, errorMessage, proof) = await _stakeService.SubmitProofAsync(id, userId.Value, request);

        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new
        {
            message = "Proof submitted successfully",
            proofId = proof?.Id,
            stakeId = id
        });
    }

    /// <summary>
    /// Get all proofs for a stake
    /// </summary>
    [HttpGet("{id}/proofs")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetStakeProofs(int id)
    {
        var proofs = await _stakeService.GetStakeProofsAsync(id);
        return Ok(proofs);
    }

    /// <summary>
    /// Manually settle a stake (admin/system use)
    /// </summary>
    [HttpPost("{id}/settle")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SettleStake(int id)
    {
        var (success, errorMessage) = await _stakeService.SettleStakeAsync(id);

        if (!success)
        {
            return BadRequest(new { message = errorMessage });
        }

        return Ok(new { message = "Stake settled successfully" });
    }

    private int? GetCurrentUserId()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return null;
        }
        return userId;
    }

    private StakeDto MapToDto(Core.Entities.Stake stake)
    {
        return new StakeDto
        {
            Id = stake.Id,
            UserId = stake.UserId,
            Title = stake.Title,
            Description = stake.Description,
            Category = stake.Category,
            AmountEUR = stake.AmountEUR,
            RequiredCount = stake.RequiredCount,
            CurrentCount = stake.CurrentCount,
            StartDate = stake.StartDate,
            EndDate = stake.EndDate,
            ProofMode = stake.ProofMode,
            GeofenceId = stake.GeofenceId,
            GeofenceName = stake.Geofence?.Name,
            MinimumDurationMinutes = stake.MinimumDurationMinutes,
            RequirePhoto = stake.RequirePhoto,
            FailureMode = stake.FailureMode,
            FailureDestinationId = stake.FailureDestinationId,
            StripePaymentIntentId = stake.StripePaymentIntentId,
            PaymentStatus = stake.PaymentStatus,
            Status = stake.Status,
            CreatedAt = stake.CreatedAt,
            SettledAt = stake.SettledAt
        };
    }
}
