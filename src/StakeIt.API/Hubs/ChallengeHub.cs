using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using StakeIt.API.DTOs.Challenges;
using StakeIt.API.Services;

namespace StakeIt.API.Hubs;

[Authorize]
public class ChallengeHub : Hub
{
    private readonly IChallengeService _challengeService;
    private readonly ILogger<ChallengeHub> _logger;

    public ChallengeHub(
        IChallengeService challengeService,
        ILogger<ChallengeHub> logger)
    {
        _challengeService = challengeService;
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        var userId = GetUserId();
        if (userId.HasValue)
        {
            _logger.LogInformation("User {UserId} connected to ChallengeHub", userId.Value);
        }
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = GetUserId();
        if (userId.HasValue)
        {
            _logger.LogInformation("User {UserId} disconnected from ChallengeHub", userId.Value);
        }
        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Join a challenge room to receive real-time updates
    /// </summary>
    public async Task JoinChallenge(int challengeId)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return;
        }

        // Verify user is participant or spectator
        var challenge = await _challengeService.GetChallengeByIdAsync(challengeId);
        if (challenge == null)
        {
            await Clients.Caller.SendAsync("Error", "Challenge not found");
            return;
        }

        var isParticipant = challenge.Participants.Any(p => p.UserId == userId.Value);
        if (!isParticipant && !challenge.AllowSpectators)
        {
            await Clients.Caller.SendAsync("Error", "Not authorized to join this challenge");
            return;
        }

        var roomName = $"Challenge_{challengeId}";
        await Groups.AddToGroupAsync(Context.ConnectionId, roomName);

        _logger.LogInformation("User {UserId} joined challenge room {ChallengeId}",
            userId.Value, challengeId);

        await Clients.Caller.SendAsync("JoinedChallenge", challengeId);
    }

    /// <summary>
    /// Leave a challenge room
    /// </summary>
    public async Task LeaveChallenge(int challengeId)
    {
        var roomName = $"Challenge_{challengeId}";
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, roomName);

        var userId = GetUserId();
        _logger.LogInformation("User {UserId} left challenge room {ChallengeId}",
            userId, challengeId);

        await Clients.Caller.SendAsync("LeftChallenge", challengeId);
    }

    /// <summary>
    /// Send a chat message to the challenge
    /// </summary>
    public async Task SendMessage(int challengeId, string message)
    {
        var userId = GetUserId();
        if (!userId.HasValue)
        {
            return;
        }

        var (success, errorMessage, chatMessage) = await _challengeService
            .SendMessageAsync(challengeId, userId.Value, message);

        if (!success || chatMessage == null)
        {
            await Clients.Caller.SendAsync("Error", errorMessage ?? "Failed to send message");
            return;
        }

        // Broadcast to all participants in the challenge room
        var roomName = $"Challenge_{challengeId}";
        var messageDto = new ChallengeMessageDto
        {
            Id = chatMessage.Id,
            ChallengeId = chatMessage.ChallengeId,
            SenderId = chatMessage.SenderId,
            SenderEmail = chatMessage.Sender?.Email ?? "",
            SenderName = $"{chatMessage.Sender?.FirstName} {chatMessage.Sender?.LastName}".Trim(),
            SenderAvatarUrl = chatMessage.Sender?.AvatarUrl,
            Message = chatMessage.Message,
            SentAt = chatMessage.SentAt
        };

        await Clients.Group(roomName).SendAsync("NewMessage", messageDto);

        _logger.LogInformation("Message sent in challenge {ChallengeId} by user {UserId}",
            challengeId, userId.Value);
    }

    /// <summary>
    /// Notify when a new proof is submitted
    /// </summary>
    public async Task NotifyProofSubmitted(int challengeId, ChallengeProofDto proof)
    {
        var roomName = $"Challenge_{challengeId}";
        await Clients.Group(roomName).SendAsync("ProofSubmitted", proof);
    }

    /// <summary>
    /// Notify when leaderboard is updated
    /// </summary>
    public async Task NotifyLeaderboardUpdate(int challengeId, List<ChallengeParticipantDto> leaderboard)
    {
        var roomName = $"Challenge_{challengeId}";
        await Clients.Group(roomName).SendAsync("LeaderboardUpdated", leaderboard);
    }

    /// <summary>
    /// Notify when a participant joins
    /// </summary>
    public async Task NotifyParticipantJoined(int challengeId, ChallengeParticipantDto participant)
    {
        var roomName = $"Challenge_{challengeId}";
        await Clients.Group(roomName).SendAsync("ParticipantJoined", participant);
    }

    /// <summary>
    /// Notify when a participant leaves
    /// </summary>
    public async Task NotifyParticipantLeft(int challengeId, int userId)
    {
        var roomName = $"Challenge_{challengeId}";
        await Clients.Group(roomName).SendAsync("ParticipantLeft", userId);
    }

    /// <summary>
    /// Notify when challenge status changes
    /// </summary>
    public async Task NotifyChallengeStatusChanged(int challengeId, string status)
    {
        var roomName = $"Challenge_{challengeId}";
        await Clients.Group(roomName).SendAsync("ChallengeStatusChanged", new { challengeId, status });
    }

    private int? GetUserId()
    {
        var userIdClaim = Context.User?.FindFirst("userId")?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out var userId))
        {
            return null;
        }
        return userId;
    }
}
