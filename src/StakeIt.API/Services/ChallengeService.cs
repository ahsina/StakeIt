using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.Challenges;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class ChallengeService : IChallengeService
{
    private readonly StakeItDbContext _context;
    private readonly IPaymentService _paymentService;
    private readonly IGeofenceService _geofenceService;
    private readonly ILogger<ChallengeService> _logger;

    public ChallengeService(
        StakeItDbContext context,
        IPaymentService paymentService,
        IGeofenceService geofenceService,
        ILogger<ChallengeService> logger)
    {
        _context = context;
        _paymentService = paymentService;
        _geofenceService = geofenceService;
        _logger = logger;
    }

    public async Task<(bool Success, string? ErrorMessage, Challenge? Challenge)> CreateChallengeAsync(
        int creatorId, CreateChallengeRequest request)
    {
        try
        {
            // Validate creator exists
            var creator = await _context.Users.FindAsync(creatorId);
            if (creator == null)
            {
                return (false, "User not found", null);
            }

            // Validate dates
            if (request.StartDate <= DateTime.UtcNow)
            {
                return (false, "Start date must be in the future", null);
            }

            if (request.EndDate <= request.StartDate)
            {
                return (false, "End date must be after start date", null);
            }

            // Validate geofence if specified
            if (request.GeofenceId.HasValue)
            {
                var geofence = await _context.Geofences.FindAsync(request.GeofenceId.Value);
                if (geofence == null)
                {
                    return (false, "Geofence not found", null);
                }
            }

            // Create the challenge
            var challenge = new Challenge
            {
                Title = request.Title,
                Description = request.Description,
                Category = request.Category,
                ChallengeType = request.ChallengeType,
                CreatorId = creatorId,
                Status = ChallengeStatus.Open,
                MaxParticipants = request.MaxParticipants,
                EntryFeeEUR = request.EntryFeeEUR,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                TargetCount = request.TargetCount,
                ProofMode = request.ProofMode,
                GeofenceId = request.GeofenceId,
                AllowSpectators = request.AllowSpectators,
                IsPublic = request.IsPublic
            };

            _context.Challenges.Add(challenge);
            await _context.SaveChangesAsync();

            // Auto-join creator as first participant
            var creatorParticipant = new ChallengeParticipant
            {
                ChallengeId = challenge.Id,
                UserId = creatorId,
                CurrentCount = 0,
                Rank = 1
            };

            _context.ChallengeParticipants.Add(creatorParticipant);

            // Pre-authorize creator's entry fee
            var (paymentSuccess, paymentError, paymentIntentId) = await _paymentService
                .PreAuthorizePaymentAsync(creatorId, request.EntryFeeEUR,
                    $"Challenge entry fee: {request.Title}");

            if (!paymentSuccess || string.IsNullOrEmpty(paymentIntentId))
            {
                return (false, paymentError ?? "Payment pre-authorization failed", null);
            }

            // Create transaction record
            var transaction = new Transaction
            {
                UserId = creatorId,
                AmountEUR = request.EntryFeeEUR,
                Type = "ChallengeEntry",
                Description = $"Entry fee for challenge: {request.Title}",
                Status = PaymentStatus.PreAuthorized,
                StripePaymentIntentId = paymentIntentId,
                ChallengeId = challenge.Id
            };

            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Challenge {ChallengeId} created by user {UserId}",
                challenge.Id, creatorId);

            return (true, null, challenge);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating challenge");
            return (false, "An error occurred while creating the challenge", null);
        }
    }

    public async Task<Challenge?> GetChallengeByIdAsync(int challengeId)
    {
        return await _context.Challenges
            .Include(c => c.Creator)
            .Include(c => c.Participants)
                .ThenInclude(p => p.User)
            .Include(c => c.Geofence)
            .FirstOrDefaultAsync(c => c.Id == challengeId);
    }

    public async Task<List<Challenge>> GetPublicChallengesAsync(
        ChallengeStatus? status = null, StakeCategory? category = null)
    {
        var query = _context.Challenges
            .Include(c => c.Creator)
            .Include(c => c.Participants)
            .Where(c => c.IsPublic);

        if (status.HasValue)
        {
            query = query.Where(c => c.Status == status.Value);
        }

        if (category.HasValue)
        {
            query = query.Where(c => c.Category == category.Value);
        }

        return await query
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<List<Challenge>> GetMyChallengesAsync(int userId)
    {
        return await _context.Challenges
            .Include(c => c.Creator)
            .Include(c => c.Participants)
                .ThenInclude(p => p.User)
            .Where(c => c.CreatorId == userId || c.Participants.Any(p => p.UserId == userId))
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<(bool Success, string? ErrorMessage)> CancelChallengeAsync(
        int challengeId, int userId)
    {
        try
        {
            var challenge = await GetChallengeByIdAsync(challengeId);
            if (challenge == null)
            {
                return (false, "Challenge not found");
            }

            // Only creator can cancel
            if (challenge.CreatorId != userId)
            {
                return (false, "Only the challenge creator can cancel it");
            }

            // Can only cancel if not started yet
            if (challenge.Status != ChallengeStatus.Open || DateTime.UtcNow >= challenge.StartDate)
            {
                return (false, "Can only cancel challenges that haven't started yet");
            }

            // Refund all participants
            var transactions = await _context.Transactions
                .Where(t => t.ChallengeId == challengeId && t.Status == PaymentStatus.PreAuthorized)
                .ToListAsync();

            foreach (var transaction in transactions)
            {
                if (!string.IsNullOrEmpty(transaction.StripePaymentIntentId))
                {
                    var (refundSuccess, _) = await _paymentService
                        .CancelPreAuthorizedPaymentAsync(transaction.StripePaymentIntentId);

                    if (refundSuccess)
                    {
                        transaction.Status = PaymentStatus.Refunded;
                    }
                }
            }

            challenge.Status = ChallengeStatus.Cancelled;
            await _context.SaveChangesAsync();

            _logger.LogInformation("Challenge {ChallengeId} cancelled by user {UserId}",
                challengeId, userId);

            return (true, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error cancelling challenge {ChallengeId}", challengeId);
            return (false, "An error occurred while cancelling the challenge");
        }
    }

    public async Task<(bool Success, string? ErrorMessage, ChallengeParticipant? Participant)> JoinChallengeAsync(
        int challengeId, int userId)
    {
        try
        {
            var challenge = await GetChallengeByIdAsync(challengeId);
            if (challenge == null)
            {
                return (false, "Challenge not found", null);
            }

            // Validate challenge is open for joining
            if (challenge.Status != ChallengeStatus.Open)
            {
                return (false, "Challenge is not open for new participants", null);
            }

            if (DateTime.UtcNow >= challenge.StartDate)
            {
                return (false, "Challenge has already started", null);
            }

            // Check if already participating
            if (challenge.Participants.Any(p => p.UserId == userId))
            {
                return (false, "You are already participating in this challenge", null);
            }

            // Check if challenge is full
            if (challenge.Participants.Count >= challenge.MaxParticipants)
            {
                return (false, "Challenge is full", null);
            }

            // Pre-authorize entry fee
            var (paymentSuccess, paymentError, paymentIntentId) = await _paymentService
                .PreAuthorizePaymentAsync(userId, challenge.EntryFeeEUR,
                    $"Challenge entry fee: {challenge.Title}");

            if (!paymentSuccess || string.IsNullOrEmpty(paymentIntentId))
            {
                return (false, paymentError ?? "Payment pre-authorization failed", null);
            }

            // Create participant
            var participant = new ChallengeParticipant
            {
                ChallengeId = challengeId,
                UserId = userId,
                CurrentCount = 0,
                Rank = challenge.Participants.Count + 1
            };

            _context.ChallengeParticipants.Add(participant);

            // Create transaction
            var transaction = new Transaction
            {
                UserId = userId,
                AmountEUR = challenge.EntryFeeEUR,
                Type = "ChallengeEntry",
                Description = $"Entry fee for challenge: {challenge.Title}",
                Status = PaymentStatus.PreAuthorized,
                StripePaymentIntentId = paymentIntentId,
                ChallengeId = challengeId
            };

            _context.Transactions.Add(transaction);
            await _context.SaveChangesAsync();

            _logger.LogInformation("User {UserId} joined challenge {ChallengeId}",
                userId, challengeId);

            return (true, null, participant);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error joining challenge {ChallengeId}", challengeId);
            return (false, "An error occurred while joining the challenge", null);
        }
    }

    public async Task<(bool Success, string? ErrorMessage)> LeaveChallengeAsync(
        int challengeId, int userId)
    {
        try
        {
            var challenge = await GetChallengeByIdAsync(challengeId);
            if (challenge == null)
            {
                return (false, "Challenge not found");
            }

            // Can't leave if you're the creator
            if (challenge.CreatorId == userId)
            {
                return (false, "Creator cannot leave their own challenge. Cancel it instead.");
            }

            // Can only leave before challenge starts
            if (DateTime.UtcNow >= challenge.StartDate)
            {
                return (false, "Cannot leave a challenge that has already started");
            }

            var participant = challenge.Participants.FirstOrDefault(p => p.UserId == userId);
            if (participant == null)
            {
                return (false, "You are not participating in this challenge");
            }

            // Refund entry fee
            var transaction = await _context.Transactions
                .FirstOrDefaultAsync(t => t.ChallengeId == challengeId &&
                                         t.UserId == userId &&
                                         t.Status == PaymentStatus.PreAuthorized);

            if (transaction != null && !string.IsNullOrEmpty(transaction.StripePaymentIntentId))
            {
                var (refundSuccess, _) = await _paymentService
                    .CancelPreAuthorizedPaymentAsync(transaction.StripePaymentIntentId);

                if (refundSuccess)
                {
                    transaction.Status = PaymentStatus.Refunded;
                }
            }

            _context.ChallengeParticipants.Remove(participant);
            await _context.SaveChangesAsync();

            _logger.LogInformation("User {UserId} left challenge {ChallengeId}",
                userId, challengeId);

            return (true, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error leaving challenge {ChallengeId}", challengeId);
            return (false, "An error occurred while leaving the challenge");
        }
    }

    public async Task<(bool Success, string? ErrorMessage, ChallengeProof? Proof)> SubmitProofAsync(
        int challengeId, int userId, SubmitChallengeProofRequest request)
    {
        try
        {
            var challenge = await GetChallengeByIdAsync(challengeId);
            if (challenge == null)
            {
                return (false, "Challenge not found", null);
            }

            // Validate user is participant
            var participant = challenge.Participants.FirstOrDefault(p => p.UserId == userId);
            if (participant == null)
            {
                return (false, "You are not participating in this challenge", null);
            }

            // Validate challenge is active
            if (challenge.Status != ChallengeStatus.Active)
            {
                return (false, "Challenge is not active", null);
            }

            // Validate proof based on mode
            if (challenge.ProofMode == ProofMode.GPS)
            {
                if (!request.Latitude.HasValue || !request.Longitude.HasValue)
                {
                    return (false, "GPS coordinates are required for this challenge", null);
                }

                // Validate geofence if specified
                if (challenge.GeofenceId.HasValue)
                {
                    var isWithin = await _geofenceService.IsWithinGeofenceAsync(
                        challenge.GeofenceId.Value, request.Latitude.Value, request.Longitude.Value);

                    if (!isWithin)
                    {
                        return (false, "You are not within the required location", null);
                    }
                }
            }
            else if (challenge.ProofMode == ProofMode.Photo)
            {
                if (string.IsNullOrEmpty(request.PhotoUrl))
                {
                    return (false, "Photo is required for this challenge", null);
                }
            }

            // Create proof
            var proof = new ChallengeProof
            {
                ChallengeId = challengeId,
                ParticipantId = participant.Id,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                PhotoUrl = request.PhotoUrl,
                Notes = request.Notes,
                ValidationStatus = ValidationStatus.Pending
            };

            _context.ChallengeProofs.Add(proof);

            // Auto-validate GPS proofs, photos need manual review
            if (challenge.ProofMode == ProofMode.GPS)
            {
                proof.ValidationStatus = ValidationStatus.Approved;
                proof.ValidatedAt = DateTime.UtcNow;

                // Increment participant count
                participant.CurrentCount++;

                // Check if participant reached target
                if (participant.CurrentCount >= challenge.TargetCount)
                {
                    participant.CompletedAt = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync();

            // Update leaderboard
            await UpdateLeaderboardAsync(challengeId);

            _logger.LogInformation("Proof submitted for challenge {ChallengeId} by user {UserId}",
                challengeId, userId);

            return (true, null, proof);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error submitting proof for challenge {ChallengeId}", challengeId);
            return (false, "An error occurred while submitting proof", null);
        }
    }

    public async Task<List<ChallengeProof>> GetChallengeProofsAsync(int challengeId)
    {
        return await _context.ChallengeProofs
            .Include(p => p.Participant)
                .ThenInclude(p => p.User)
            .Where(p => p.ChallengeId == challengeId)
            .OrderByDescending(p => p.SubmittedAt)
            .ToListAsync();
    }

    public async Task<(bool Success, string? ErrorMessage, ChallengeMessage? Message)> SendMessageAsync(
        int challengeId, int userId, string message)
    {
        try
        {
            var challenge = await GetChallengeByIdAsync(challengeId);
            if (challenge == null)
            {
                return (false, "Challenge not found", null);
            }

            // Validate user is participant or spectator
            var isParticipant = challenge.Participants.Any(p => p.UserId == userId);
            if (!isParticipant)
            {
                // Check if spectators allowed and user is spectator
                var isSpectator = await _context.ChallengeSpectators
                    .AnyAsync(s => s.ChallengeId == challengeId && s.UserId == userId);

                if (!challenge.AllowSpectators || !isSpectator)
                {
                    return (false, "You are not allowed to send messages in this challenge", null);
                }
            }

            var chatMessage = new ChallengeMessage
            {
                ChallengeId = challengeId,
                SenderId = userId,
                Message = message
            };

            _context.ChallengeMessages.Add(chatMessage);
            await _context.SaveChangesAsync();

            return (true, null, chatMessage);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending message in challenge {ChallengeId}", challengeId);
            return (false, "An error occurred while sending the message", null);
        }
    }

    public async Task<List<ChallengeMessage>> GetChallengeMessagesAsync(int challengeId, int limit = 50)
    {
        return await _context.ChallengeMessages
            .Include(m => m.Sender)
            .Where(m => m.ChallengeId == challengeId)
            .OrderByDescending(m => m.SentAt)
            .Take(limit)
            .OrderBy(m => m.SentAt)
            .ToListAsync();
    }

    public async Task<List<ChallengeParticipant>> GetLeaderboardAsync(int challengeId)
    {
        return await _context.ChallengeParticipants
            .Include(p => p.User)
            .Where(p => p.ChallengeId == challengeId)
            .OrderByDescending(p => p.CurrentCount)
                .ThenBy(p => p.CompletedAt ?? DateTime.MaxValue)
            .ToListAsync();
    }

    public async Task<(bool Success, string? ErrorMessage)> SettleChallengeAsync(int challengeId)
    {
        try
        {
            var challenge = await GetChallengeByIdAsync(challengeId);
            if (challenge == null)
            {
                return (false, "Challenge not found");
            }

            // Can only settle completed or failed challenges
            if (challenge.Status != ChallengeStatus.Active || DateTime.UtcNow < challenge.EndDate)
            {
                return (false, "Challenge is not ready for settlement");
            }

            // Get final leaderboard
            var participants = await GetLeaderboardAsync(challengeId);

            // Determine winners based on challenge type
            var winners = new List<ChallengeParticipant>();

            if (challenge.ChallengeType == ChallengeType.FirstToComplete)
            {
                // Winner is first to complete target
                winners = participants.Where(p => p.CompletedAt.HasValue)
                    .OrderBy(p => p.CompletedAt)
                    .Take(1)
                    .ToList();
            }
            else if (challenge.ChallengeType == ChallengeType.HighestScore)
            {
                // Winners are top scorers
                var maxScore = participants.Max(p => p.CurrentCount);
                winners = participants.Where(p => p.CurrentCount == maxScore).ToList();
            }
            else if (challenge.ChallengeType == ChallengeType.TeamBased)
            {
                // Team logic - for now treat as highest score
                var maxScore = participants.Max(p => p.CurrentCount);
                winners = participants.Where(p => p.CurrentCount == maxScore).ToList();
            }

            // Calculate prize distribution
            var totalPool = participants.Count * challenge.EntryFeeEUR;
            var platformFee = totalPool * 0.10m; // 10% platform fee
            var prizePool = totalPool - platformFee;

            if (winners.Any())
            {
                var prizePerWinner = prizePool / winners.Count;

                foreach (var winner in winners)
                {
                    // Refund winner's entry fee (cancel pre-auth)
                    var entryTransaction = await _context.Transactions
                        .FirstOrDefaultAsync(t => t.ChallengeId == challengeId &&
                                                 t.UserId == winner.UserId &&
                                                 t.Type == "ChallengeEntry");

                    if (entryTransaction != null && !string.IsNullOrEmpty(entryTransaction.StripePaymentIntentId))
                    {
                        await _paymentService.CancelPreAuthorizedPaymentAsync(
                            entryTransaction.StripePaymentIntentId);
                        entryTransaction.Status = PaymentStatus.Refunded;
                    }

                    // Pay out winnings
                    var (payoutSuccess, _, _) = await _paymentService.PayoutAsync(
                        winner.UserId, prizePerWinner, $"Prize for challenge: {challenge.Title}");

                    if (payoutSuccess)
                    {
                        var winTransaction = new Transaction
                        {
                            UserId = winner.UserId,
                            AmountEUR = prizePerWinner,
                            Type = "ChallengeWin",
                            Description = $"Prize from challenge: {challenge.Title}",
                            Status = PaymentStatus.Completed,
                            ChallengeId = challengeId
                        };
                        _context.Transactions.Add(winTransaction);
                    }
                }
            }

            // Capture entry fees from losers
            var losers = participants.Except(winners).ToList();
            foreach (var loser in losers)
            {
                var entryTransaction = await _context.Transactions
                    .FirstOrDefaultAsync(t => t.ChallengeId == challengeId &&
                                             t.UserId == loser.UserId &&
                                             t.Type == "ChallengeEntry");

                if (entryTransaction != null && !string.IsNullOrEmpty(entryTransaction.StripePaymentIntentId))
                {
                    var (captureSuccess, _) = await _paymentService
                        .CapturePaymentAsync(entryTransaction.StripePaymentIntentId);

                    if (captureSuccess)
                    {
                        entryTransaction.Status = PaymentStatus.Completed;
                    }
                }
            }

            challenge.Status = ChallengeStatus.Completed;
            challenge.SettledAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation("Challenge {ChallengeId} settled with {WinnerCount} winners",
                challengeId, winners.Count);

            return (true, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error settling challenge {ChallengeId}", challengeId);
            return (false, "An error occurred while settling the challenge");
        }
    }

    private async Task UpdateLeaderboardAsync(int challengeId)
    {
        var participants = await _context.ChallengeParticipants
            .Where(p => p.ChallengeId == challengeId)
            .OrderByDescending(p => p.CurrentCount)
                .ThenBy(p => p.CompletedAt ?? DateTime.MaxValue)
            .ToListAsync();

        for (int i = 0; i < participants.Count; i++)
        {
            participants[i].Rank = i + 1;
        }

        await _context.SaveChangesAsync();
    }
}
