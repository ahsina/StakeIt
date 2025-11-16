using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.Stakes;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class StakeService : IStakeService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<StakeService> _logger;
    private readonly IConfiguration _configuration;

    public StakeService(
        StakeItDbContext context,
        ILogger<StakeService> logger,
        IConfiguration configuration)
    {
        _context = context;
        _logger = logger;
        _configuration = configuration;
    }

    public async Task<(bool Success, string? ErrorMessage, Stake? Stake)> CreateStakeAsync(int userId, CreateStakeRequest request)
    {
        // Validate user exists
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return (false, "User not found", null);
        }

        // Validate end date
        if (request.EndDate <= DateTime.UtcNow)
        {
            return (false, "End date must be in the future", null);
        }

        // Validate amount limits
        var minAmount = decimal.Parse(_configuration["AppSettings:MinimumStakeAmount"] ?? "5.00");
        var maxAmount = decimal.Parse(_configuration["AppSettings:MaximumStakeAmount"] ?? "500.00");

        if (request.AmountEUR < minAmount || request.AmountEUR > maxAmount)
        {
            return (false, $"Amount must be between {minAmount}€ and {maxAmount}€", null);
        }

        // Validate geofence if GPS mode
        if (request.ProofMode == ProofMode.GPS && request.GeofenceId.HasValue)
        {
            var geofence = await _context.Geofences.FindAsync(request.GeofenceId.Value);
            if (geofence == null)
            {
                return (false, "Geofence not found", null);
            }
        }

        // Create stake
        var stake = new Stake
        {
            UserId = userId,
            Title = request.Title,
            Description = request.Description,
            Category = request.Category,
            AmountEUR = request.AmountEUR,
            RequiredCount = request.RequiredCount,
            CurrentCount = 0,
            StartDate = DateTime.UtcNow,
            EndDate = request.EndDate,
            ProofMode = request.ProofMode,
            GeofenceId = request.GeofenceId,
            MinimumDurationMinutes = request.MinimumDurationMinutes,
            RequirePhoto = request.RequirePhoto,
            FailureMode = request.FailureMode,
            FailureDestinationId = request.FailureDestinationId,
            Status = StakeStatus.Active,
            PaymentStatus = PaymentStatus.PreAuthorized, // TODO: Integrate with Stripe
            CreatedAt = DateTime.UtcNow
        };

        _context.Stakes.Add(stake);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Stake created: {StakeId} by user {UserId}", stake.Id, userId);

        return (true, null, stake);
    }

    public async Task<Stake?> GetStakeByIdAsync(int stakeId)
    {
        return await _context.Stakes
            .Include(s => s.Geofence)
            .Include(s => s.Proofs)
            .FirstOrDefaultAsync(s => s.Id == stakeId);
    }

    public async Task<List<Stake>> GetUserStakesAsync(int userId, bool activeOnly = false)
    {
        var query = _context.Stakes
            .Include(s => s.Geofence)
            .Include(s => s.Proofs)
            .Where(s => s.UserId == userId);

        if (activeOnly)
        {
            query = query.Where(s => s.Status == StakeStatus.Active);
        }

        return await query
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();
    }

    public async Task<(bool Success, string? ErrorMessage)> CancelStakeAsync(int stakeId, int userId)
    {
        var stake = await _context.Stakes.FindAsync(stakeId);

        if (stake == null)
        {
            return (false, "Stake not found");
        }

        if (stake.UserId != userId)
        {
            return (false, "Unauthorized");
        }

        if (stake.Status != StakeStatus.Active)
        {
            return (false, "Only active stakes can be cancelled");
        }

        // Check cancellation window (default 2 hours)
        var cancellationWindowHours = int.Parse(_configuration["AppSettings:CancellationWindowHours"] ?? "2");
        var timeSinceCreation = DateTime.UtcNow - stake.CreatedAt;

        if (timeSinceCreation.TotalHours > cancellationWindowHours)
        {
            return (false, $"Cancellation is only allowed within {cancellationWindowHours} hours of creation");
        }

        stake.Status = StakeStatus.Cancelled;
        stake.PaymentStatus = PaymentStatus.Refunded; // TODO: Actually refund via Stripe

        await _context.SaveChangesAsync();

        _logger.LogInformation("Stake cancelled: {StakeId}", stakeId);

        return (true, null);
    }

    public async Task<(bool Success, string? ErrorMessage, StakeProof? Proof)> SubmitProofAsync(
        int stakeId,
        int userId,
        SubmitProofRequest request)
    {
        var stake = await _context.Stakes
            .Include(s => s.Proofs)
            .FirstOrDefaultAsync(s => s.Id == stakeId);

        if (stake == null)
        {
            return (false, "Stake not found", null);
        }

        if (stake.UserId != userId)
        {
            return (false, "Unauthorized", null);
        }

        if (stake.Status != StakeStatus.Active)
        {
            return (false, "Stake is not active", null);
        }

        // Check if already completed
        if (stake.CurrentCount >= stake.RequiredCount)
        {
            return (false, "Stake is already completed", null);
        }

        // Validate proof based on proof mode
        if (stake.ProofMode == ProofMode.GPS)
        {
            if (!request.Latitude.HasValue || !request.Longitude.HasValue)
            {
                return (false, "GPS coordinates are required for GPS proof mode", null);
            }

            // TODO: Validate GPS coordinates against geofence
        }
        else if (stake.ProofMode == ProofMode.Photo)
        {
            if (string.IsNullOrEmpty(request.PhotoUrl))
            {
                return (false, "Photo is required for photo proof mode", null);
            }
        }

        // Create proof
        var proof = new StakeProof
        {
            StakeId = stakeId,
            ProofType = request.ProofType,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Accuracy = request.Accuracy,
            EntryTime = request.EntryTime,
            ExitTime = request.ExitTime,
            DurationMinutes = request.ExitTime.HasValue && request.EntryTime.HasValue
                ? (int)(request.ExitTime.Value - request.EntryTime.Value).TotalMinutes
                : null,
            PhotoUrl = request.PhotoUrl,
            PhotoMetadata = request.PhotoMetadata,
            ValidationStatus = ValidationStatus.Approved, // Auto-approve for now
            SubmittedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        _context.StakeProofs.Add(proof);

        // Increment stake progress
        stake.CurrentCount++;
        stake.UpdatedAt = DateTime.UtcNow;

        // Check if stake is now completed
        if (stake.CurrentCount >= stake.RequiredCount)
        {
            stake.Status = StakeStatus.Completed;
            stake.SettledAt = DateTime.UtcNow;
            stake.PaymentStatus = PaymentStatus.Refunded; // TODO: Actually refund via Stripe

            _logger.LogInformation("Stake completed successfully: {StakeId}", stakeId);
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("Proof submitted for stake {StakeId}: {ProofId}", stakeId, proof.Id);

        return (true, null, proof);
    }

    public async Task<List<StakeProof>> GetStakeProofsAsync(int stakeId)
    {
        return await _context.StakeProofs
            .Where(p => p.StakeId == stakeId)
            .OrderByDescending(p => p.SubmittedAt)
            .ToListAsync();
    }

    public async Task<(bool Success, string? ErrorMessage)> SettleStakeAsync(int stakeId)
    {
        var stake = await _context.Stakes.FindAsync(stakeId);

        if (stake == null)
        {
            return (false, "Stake not found");
        }

        if (stake.Status != StakeStatus.Active)
        {
            return (false, "Stake is not active");
        }

        if (DateTime.UtcNow < stake.EndDate)
        {
            return (false, "Stake has not reached its end date yet");
        }

        // Check if goal was met
        if (stake.CurrentCount >= stake.RequiredCount)
        {
            // SUCCESS
            stake.Status = StakeStatus.Completed;
            stake.PaymentStatus = PaymentStatus.Refunded; // TODO: Refund via Stripe
        }
        else
        {
            // FAILURE
            stake.Status = StakeStatus.Failed;
            stake.PaymentStatus = PaymentStatus.Captured; // TODO: Capture payment via Stripe

            // TODO: Distribute money according to FailureMode
            // - Transfer to charity
            // - Transfer to friend
            // - Add to winner pool
            // - Burn (donate anonymously)
        }

        stake.SettledAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("Stake settled: {StakeId}, Status: {Status}", stakeId, stake.Status);

        return (true, null);
    }
}
