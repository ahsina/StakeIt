using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StakeIt.API.DTOs.Auth;
using StakeIt.API.DTOs.Challenges;
using StakeIt.API.Services;
using StakeIt.Core.Enums;

namespace StakeIt.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ChallengesController : ControllerBase
{
    private readonly IChallengeService _challengeService;
    private readonly ILogger<ChallengesController> _logger;

    public ChallengesController(
        IChallengeService challengeService,
        ILogger<ChallengesController> logger)
    {
        _challengeService = challengeService;
        _logger = logger;
    }

    /// <summary>
    /// Create a new challenge
    /// </summary>
    [HttpPost]
    [Authorize]
    [ProducesResponseType(typeof(ChallengeDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CreateChallenge([FromBody] CreateChallengeRequest request)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var (success, errorMessage, challenge) = await _challengeService
            .CreateChallengeAsync(userId.Value, request);

        if (!success || challenge == null)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to create challenge" });
        }

        var dto = MapToChallengeDto(challenge);
        return CreatedAtAction(nameof(GetChallenge), new { id = challenge.Id }, dto);
    }

    /// <summary>
    /// Get challenge by ID
    /// </summary>
    [HttpGet("{id}")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ChallengeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetChallenge(int id)
    {
        var challenge = await _challengeService.GetChallengeByIdAsync(id);
        if (challenge == null)
        {
            return NotFound();
        }

        var dto = MapToChallengeDto(challenge);
        return Ok(dto);
    }

    /// <summary>
    /// Get all public challenges
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    [ProducesResponseType(typeof(List<ChallengeDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPublicChallenges(
        [FromQuery] ChallengeStatus? status = null,
        [FromQuery] StakeCategory? category = null)
    {
        var challenges = await _challengeService.GetPublicChallengesAsync(status, category);
        var dtos = challenges.Select(MapToChallengeDto).ToList();
        return Ok(dtos);
    }

    /// <summary>
    /// Get my challenges (as participant or creator)
    /// </summary>
    [HttpGet("my")]
    [Authorize]
    [ProducesResponseType(typeof(List<ChallengeDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyChallenges()
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var challenges = await _challengeService.GetMyChallengesAsync(userId.Value);
        var dtos = challenges.Select(MapToChallengeDto).ToList();
        return Ok(dtos);
    }

    /// <summary>
    /// Cancel a challenge (creator only, before start)
    /// </summary>
    [HttpPost("{id}/cancel")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CancelChallenge(int id)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _challengeService.CancelChallengeAsync(id, userId.Value);

        if (!success)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to cancel challenge" });
        }

        return Ok(new { message = "Challenge cancelled successfully" });
    }

    /// <summary>
    /// Join a challenge
    /// </summary>
    [HttpPost("{id}/join")]
    [Authorize]
    [ProducesResponseType(typeof(ChallengeParticipantDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> JoinChallenge(int id)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var (success, errorMessage, participant) = await _challengeService
            .JoinChallengeAsync(id, userId.Value);

        if (!success || participant == null)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to join challenge" });
        }

        var dto = MapToParticipantDto(participant);
        return Ok(dto);
    }

    /// <summary>
    /// Leave a challenge (before start)
    /// </summary>
    [HttpPost("{id}/leave")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> LeaveChallenge(int id)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var (success, errorMessage) = await _challengeService.LeaveChallengeAsync(id, userId.Value);

        if (!success)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to leave challenge" });
        }

        return Ok(new { message = "Left challenge successfully" });
    }

    /// <summary>
    /// Submit proof for a challenge
    /// </summary>
    [HttpPost("{id}/proofs")]
    [Authorize]
    [ProducesResponseType(typeof(ChallengeProofDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SubmitProof(int id, [FromBody] SubmitChallengeProofRequest request)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var (success, errorMessage, proof) = await _challengeService
            .SubmitProofAsync(id, userId.Value, request);

        if (!success || proof == null)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to submit proof" });
        }

        var dto = MapToProofDto(proof);
        return CreatedAtAction(nameof(GetProofs), new { id }, dto);
    }

    /// <summary>
    /// Get all proofs for a challenge
    /// </summary>
    [HttpGet("{id}/proofs")]
    [Authorize]
    [ProducesResponseType(typeof(List<ChallengeProofDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetProofs(int id)
    {
        var proofs = await _challengeService.GetChallengeProofsAsync(id);
        var dtos = proofs.Select(MapToProofDto).ToList();
        return Ok(dtos);
    }

    /// <summary>
    /// Get challenge leaderboard
    /// </summary>
    [HttpGet("{id}/leaderboard")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(List<ChallengeParticipantDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetLeaderboard(int id)
    {
        var participants = await _challengeService.GetLeaderboardAsync(id);
        var dtos = participants.Select(MapToParticipantDto).ToList();
        return Ok(dtos);
    }

    /// <summary>
    /// Send a message in challenge chat
    /// </summary>
    [HttpPost("{id}/messages")]
    [Authorize]
    [ProducesResponseType(typeof(ChallengeMessageDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SendMessage(int id, [FromBody] SendMessageRequest request)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return Unauthorized();
        }

        var (success, errorMessage, message) = await _challengeService
            .SendMessageAsync(id, userId.Value, request.Message);

        if (!success || message == null)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to send message" });
        }

        var dto = MapToMessageDto(message);
        return CreatedAtAction(nameof(GetMessages), new { id }, dto);
    }

    /// <summary>
    /// Get challenge chat messages
    /// </summary>
    [HttpGet("{id}/messages")]
    [Authorize]
    [ProducesResponseType(typeof(List<ChallengeMessageDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMessages(int id, [FromQuery] int limit = 50)
    {
        var messages = await _challengeService.GetChallengeMessagesAsync(id, limit);
        var dtos = messages.Select(MapToMessageDto).ToList();
        return Ok(dtos);
    }

    /// <summary>
    /// Settle a completed challenge (distribute prizes)
    /// </summary>
    [HttpPost("{id}/settle")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SettleChallenge(int id)
    {
        var (success, errorMessage) = await _challengeService.SettleChallengeAsync(id);

        if (!success)
        {
            return BadRequest(new { message = errorMessage ?? "Failed to settle challenge" });
        }

        return Ok(new { message = "Challenge settled successfully" });
    }

    // Helper methods
    private int? GetUserId()
    {
        var userIdClaim = User.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return null;
        }
        return userId;
    }

    private ChallengeDto MapToChallengeDto(StakeIt.Core.Entities.Challenge challenge)
    {
        return new ChallengeDto
        {
            Id = challenge.Id,
            Title = challenge.Title,
            Description = challenge.Description,
            Category = challenge.Category,
            ChallengeType = challenge.ChallengeType,
            Status = challenge.Status,
            MaxParticipants = challenge.MaxParticipants,
            CurrentParticipants = challenge.Participants?.Count ?? 0,
            EntryFeeEUR = challenge.EntryFeeEUR,
            TotalPrizePool = (challenge.Participants?.Count ?? 0) * challenge.EntryFeeEUR * 0.9m, // 90% after platform fee
            StartDate = challenge.StartDate,
            EndDate = challenge.EndDate,
            TargetCount = challenge.TargetCount,
            ProofMode = challenge.ProofMode,
            GeofenceId = challenge.GeofenceId,
            AllowSpectators = challenge.AllowSpectators,
            IsPublic = challenge.IsPublic,
            CreatedAt = challenge.CreatedAt,
            CreatorId = challenge.CreatorId,
            CreatorEmail = challenge.Creator?.Email ?? "",
            CreatorName = $"{challenge.Creator?.FirstName} {challenge.Creator?.LastName}".Trim(),
            Participants = challenge.Participants?.Select(MapToParticipantDto).ToList() ?? new()
        };
    }

    private ChallengeParticipantDto MapToParticipantDto(StakeIt.Core.Entities.ChallengeParticipant participant)
    {
        var targetCount = participant.Challenge?.TargetCount ?? 1;
        return new ChallengeParticipantDto
        {
            Id = participant.Id,
            UserId = participant.UserId,
            UserEmail = participant.User?.Email ?? "",
            UserName = $"{participant.User?.FirstName} {participant.User?.LastName}".Trim(),
            UserAvatarUrl = participant.User?.AvatarUrl,
            CurrentCount = participant.CurrentCount,
            Rank = participant.Rank,
            HasCompleted = participant.CompletedAt.HasValue,
            JoinedAt = participant.JoinedAt,
            ProgressPercentage = targetCount > 0 ? (double)participant.CurrentCount / targetCount * 100 : 0
        };
    }

    private ChallengeProofDto MapToProofDto(StakeIt.Core.Entities.ChallengeProof proof)
    {
        return new ChallengeProofDto
        {
            Id = proof.Id,
            ChallengeId = proof.ChallengeId,
            ParticipantId = proof.ParticipantId,
            UserId = proof.Participant?.UserId ?? 0,
            UserEmail = proof.Participant?.User?.Email ?? "",
            UserName = $"{proof.Participant?.User?.FirstName} {proof.Participant?.User?.LastName}".Trim(),
            Latitude = proof.Latitude,
            Longitude = proof.Longitude,
            PhotoUrl = proof.PhotoUrl,
            Notes = proof.Notes,
            ValidationStatus = proof.ValidationStatus,
            RejectionReason = proof.RejectionReason,
            SubmittedAt = proof.SubmittedAt,
            ValidatedAt = proof.ValidatedAt
        };
    }

    private ChallengeMessageDto MapToMessageDto(StakeIt.Core.Entities.ChallengeMessage message)
    {
        return new ChallengeMessageDto
        {
            Id = message.Id,
            ChallengeId = message.ChallengeId,
            SenderId = message.SenderId,
            SenderEmail = message.Sender?.Email ?? "",
            SenderName = $"{message.Sender?.FirstName} {message.Sender?.LastName}".Trim(),
            SenderAvatarUrl = message.Sender?.AvatarUrl,
            Message = message.Message,
            SentAt = message.SentAt
        };
    }
}
