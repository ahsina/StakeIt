using Microsoft.EntityFrameworkCore;
using StakeIt.API.DTOs.Stakes;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;
using StakeIt.Infrastructure.Services;

namespace StakeIt.API.Services;

public class StakeService : IStakeService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<StakeService> _logger;
    private readonly IConfiguration _configuration;
    private readonly IPaymentService _paymentService;

    public StakeService(
        StakeItDbContext context,
        ILogger<StakeService> logger,
        IConfiguration configuration,
        IPaymentService paymentService)
    {
        _context = context;
        _logger = logger;
        _configuration = configuration;
        _paymentService = paymentService;
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

        // Pre-authorize payment via Stripe
        var paymentResult = await _paymentService.PreAuthorizePaymentAsync(
            userId,
            request.AmountEUR,
            $"Stake: {request.Title}");

        if (!paymentResult.Success)
        {
            return (false, paymentResult.ErrorMessage ?? "Payment pre-authorization failed", null);
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
            StripePaymentIntentId = paymentResult.PaymentIntentId,
            PaymentStatus = PaymentStatus.PreAuthorized,
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

        // Cancel payment via Stripe
        if (!string.IsNullOrEmpty(stake.StripePaymentIntentId))
        {
            var cancelResult = await _paymentService.CancelPaymentAsync(stake.StripePaymentIntentId);
            if (!cancelResult.Success)
            {
                _logger.LogError("Failed to cancel payment for stake {StakeId}: {Error}", stakeId, cancelResult.ErrorMessage);
                return (false, "Failed to cancel payment. Please contact support.");
            }
        }

        stake.Status = StakeStatus.Cancelled;
        stake.PaymentStatus = PaymentStatus.Refunded;

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

            // Validate GPS coordinates against geofence
            if (stake.GeofenceId.HasValue)
            {
                var geofence = await _context.Geofences.FindAsync(stake.GeofenceId.Value);
                if (geofence != null)
                {
                    var distance = CalculateDistance(
                        request.Latitude.Value,
                        request.Longitude.Value,
                        geofence.Latitude,
                        geofence.Longitude);

                    if (distance > geofence.RadiusMeters)
                    {
                        _logger.LogWarning("GPS proof rejected for stake {StakeId}: distance {Distance}m exceeds radius {Radius}m",
                            stakeId, distance, geofence.RadiusMeters);
                        return (false, $"You are {Math.Round(distance)}m away from the required location (max: {geofence.RadiusMeters}m)", null);
                    }

                    _logger.LogInformation("GPS validation successful for stake {StakeId}: distance {Distance}m within radius {Radius}m",
                        stakeId, distance, geofence.RadiusMeters);
                }
            }

            // Validate minimum duration if required
            if (stake.MinimumDurationMinutes.HasValue && request.EntryTime.HasValue && request.ExitTime.HasValue)
            {
                var duration = (request.ExitTime.Value - request.EntryTime.Value).TotalMinutes;
                if (duration < stake.MinimumDurationMinutes.Value)
                {
                    return (false, $"Duration {Math.Round(duration)}min is less than required {stake.MinimumDurationMinutes}min", null);
                }
            }
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
            // Refund payment via Stripe (cancel pre-authorization)
            if (!string.IsNullOrEmpty(stake.StripePaymentIntentId))
            {
                var cancelResult = await _paymentService.CancelPaymentAsync(stake.StripePaymentIntentId);
                if (!cancelResult.Success)
                {
                    _logger.LogError("Failed to refund payment for completed stake {StakeId}: {Error}",
                        stakeId, cancelResult.ErrorMessage);
                }
            }

            stake.Status = StakeStatus.Completed;
            stake.SettledAt = DateTime.UtcNow;
            stake.PaymentStatus = PaymentStatus.Refunded;

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
            // SUCCESS - Refund payment via Stripe
            if (!string.IsNullOrEmpty(stake.StripePaymentIntentId))
            {
                var cancelResult = await _paymentService.CancelPaymentAsync(stake.StripePaymentIntentId);
                if (!cancelResult.Success)
                {
                    _logger.LogError("Failed to refund payment for successful stake {StakeId}: {Error}",
                        stakeId, cancelResult.ErrorMessage);
                    return (false, "Failed to process payment refund");
                }
            }

            stake.Status = StakeStatus.Completed;
            stake.PaymentStatus = PaymentStatus.Refunded;
        }
        else
        {
            // FAILURE - Capture payment via Stripe
            if (!string.IsNullOrEmpty(stake.StripePaymentIntentId))
            {
                var captureResult = await _paymentService.CapturePaymentAsync(stake.StripePaymentIntentId);
                if (!captureResult.Success)
                {
                    _logger.LogError("Failed to capture payment for failed stake {StakeId}: {Error}",
                        stakeId, captureResult.ErrorMessage);
                    return (false, "Failed to capture payment");
                }
            }

            stake.Status = StakeStatus.Failed;
            stake.PaymentStatus = PaymentStatus.Captured;

            // Distribute money according to FailureMode
            await DistributeFailureMoneyAsync(stake);
        }

        stake.SettledAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        _logger.LogInformation("Stake settled: {StakeId}, Status: {Status}", stakeId, stake.Status);

        return (true, null);
    }

    /// <summary>
    /// Calculate distance between two GPS coordinates using Haversine formula
    /// Returns distance in meters
    /// </summary>
    private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371000; // Earth's radius in meters

        var lat1Rad = DegreesToRadians(lat1);
        var lat2Rad = DegreesToRadians(lat2);
        var deltaLat = DegreesToRadians(lat2 - lat1);
        var deltaLon = DegreesToRadians(lon2 - lon1);

        var a = Math.Sin(deltaLat / 2) * Math.Sin(deltaLat / 2) +
                Math.Cos(lat1Rad) * Math.Cos(lat2Rad) *
                Math.Sin(deltaLon / 2) * Math.Sin(deltaLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

        return R * c; // Distance in meters
    }

    private double DegreesToRadians(double degrees)
    {
        return degrees * Math.PI / 180.0;
    }

    private async Task DistributeFailureMoneyAsync(Stake stake)
    {
        try
        {
            // Calculate commission (10% default)
            var commissionRate = decimal.Parse(_configuration["AppSettings:PlatformCommissionRate"] ?? "0.10");
            var commissionAmount = stake.AmountEUR * commissionRate;
            var distributionAmount = stake.AmountEUR - commissionAmount;

            switch (stake.FailureMode)
            {
                case FailureMode.Charity:
                    if (stake.FailureDestinationId.HasValue)
                    {
                        // Get charity from database
                        var charity = await _context.Charities.FindAsync(stake.FailureDestinationId.Value);
                        if (charity != null && !string.IsNullOrEmpty(charity.StripeAccountId))
                        {
                            var transferResult = await _paymentService.TransferToCharityAsync(
                                stake.UserId,
                                charity.StripeAccountId,
                                distributionAmount);

                            if (!transferResult.Success)
                            {
                                _logger.LogError("Failed to transfer to charity for stake {StakeId}: {Error}",
                                    stake.Id, transferResult.ErrorMessage);
                            }
                            else
                            {
                                _logger.LogInformation("Transferred {Amount}€ to charity {CharityName} for failed stake {StakeId}",
                                    distributionAmount, charity.Name, stake.Id);
                            }
                        }
                    }
                    break;

                case FailureMode.FriendTransfer:
                    if (stake.FailureDestinationId.HasValue)
                    {
                        var transferResult = await _paymentService.TransferToUserAsync(
                            stake.UserId,
                            stake.FailureDestinationId.Value,
                            distributionAmount,
                            $"Failed stake transfer: {stake.Title}");

                        if (!transferResult.Success)
                        {
                            _logger.LogError("Failed to transfer to friend for stake {StakeId}: {Error}",
                                stake.Id, transferResult.ErrorMessage);
                        }
                        else
                        {
                            _logger.LogInformation("Transferred {Amount}€ to friend (user {FriendId}) for failed stake {StakeId}",
                                distributionAmount, stake.FailureDestinationId.Value, stake.Id);
                        }
                    }
                    break;

                case FailureMode.WinnerPool:
                    // Add to winner pool - this would be distributed to challenge winners
                    _logger.LogInformation("Added {Amount}€ to winner pool for failed stake {StakeId} (commission: {Commission}€)",
                        distributionAmount, stake.Id, commissionAmount);
                    // In a real implementation, this would add to a pool table in the database
                    break;

                case FailureMode.Burn:
                    // Platform keeps the money (or could donate to a default charity)
                    _logger.LogInformation("Burned {Amount}€ from failed stake {StakeId} (total: {Total}€)",
                        distributionAmount, stake.Id, stake.AmountEUR);
                    break;

                case FailureMode.AllOrNothing:
                case FailureMode.ProRata:
                case FailureMode.Progressive:
                default:
                    // For these modes, the money goes to platform commission by default
                    _logger.LogInformation("Platform commission {Amount}€ from failed stake {StakeId}",
                        stake.AmountEUR, stake.Id);
                    break;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error distributing failure money for stake {StakeId}", stake.Id);
        }
    }
}
