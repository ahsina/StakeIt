using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class SettlementBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<SettlementBackgroundService> _logger;
    private readonly TimeSpan _checkInterval = TimeSpan.FromMinutes(5); // Check every 5 minutes

    public SettlementBackgroundService(
        IServiceProvider serviceProvider,
        ILogger<SettlementBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Settlement Background Service started");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ProcessSettlementsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing settlements");
            }

            // Wait before next check
            await Task.Delay(_checkInterval, stoppingToken);
        }

        _logger.LogInformation("Settlement Background Service stopped");
    }

    private async Task ProcessSettlementsAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<StakeItDbContext>();
        var challengeService = scope.ServiceProvider.GetRequiredService<IChallengeService>();

        // Find all active challenges that have ended
        var completedChallenges = await context.Challenges
            .Where(c => c.Status == ChallengeStatus.Active && c.EndDate <= DateTime.UtcNow)
            .Select(c => c.Id)
            .ToListAsync(cancellationToken);

        if (completedChallenges.Any())
        {
            _logger.LogInformation("Found {Count} challenges ready for settlement",
                completedChallenges.Count);

            foreach (var challengeId in completedChallenges)
            {
                try
                {
                    var (success, errorMessage) = await challengeService.SettleChallengeAsync(challengeId);

                    if (success)
                    {
                        _logger.LogInformation("Successfully settled challenge {ChallengeId}", challengeId);
                    }
                    else
                    {
                        _logger.LogWarning("Failed to settle challenge {ChallengeId}: {Error}",
                            challengeId, errorMessage);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error settling challenge {ChallengeId}", challengeId);
                }
            }
        }

        // Also process Stakes that need settlement
        await ProcessStakeSettlementsAsync(context, scope.ServiceProvider, cancellationToken);
    }

    private async Task ProcessStakeSettlementsAsync(
        StakeItDbContext context,
        IServiceProvider serviceProvider,
        CancellationToken cancellationToken)
    {
        var stakeService = serviceProvider.GetRequiredService<IStakeService>();

        // Find all active stakes that have ended
        var completedStakes = await context.Stakes
            .Where(s => s.Status == StakeStatus.Active && s.EndDate <= DateTime.UtcNow)
            .Select(s => s.Id)
            .ToListAsync(cancellationToken);

        if (completedStakes.Any())
        {
            _logger.LogInformation("Found {Count} stakes ready for settlement",
                completedStakes.Count);

            foreach (var stakeId in completedStakes)
            {
                try
                {
                    var (success, errorMessage) = await stakeService.SettleStakeAsync(stakeId);

                    if (success)
                    {
                        _logger.LogInformation("Successfully settled stake {StakeId}", stakeId);
                    }
                    else
                    {
                        _logger.LogWarning("Failed to settle stake {StakeId}: {Error}",
                            stakeId, errorMessage);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error settling stake {StakeId}", stakeId);
                }
            }
        }
    }
}
