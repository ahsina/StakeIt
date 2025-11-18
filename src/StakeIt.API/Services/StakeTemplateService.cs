using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class StakeTemplateService : IStakeTemplateService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<StakeTemplateService> _logger;

    public StakeTemplateService(StakeItDbContext context, ILogger<StakeTemplateService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<StakeTemplate>> GetAllTemplatesAsync(string? category = null, string? searchQuery = null)
    {
        var query = _context.StakeTemplates
            .Where(t => t.IsActive);

        if (!string.IsNullOrEmpty(category) && Enum.TryParse<StakeCategory>(category, out var stakeCategory))
        {
            query = query.Where(t => t.Category == stakeCategory);
        }

        if (!string.IsNullOrEmpty(searchQuery))
        {
            var lowerQuery = searchQuery.ToLower();
            query = query.Where(t =>
                t.Title.ToLower().Contains(lowerQuery) ||
                t.Description.ToLower().Contains(lowerQuery) ||
                t.Tags.ToLower().Contains(lowerQuery));
        }

        return await query
            .OrderByDescending(t => t.IsFeatured)
            .ThenByDescending(t => t.UsageCount)
            .ToListAsync();
    }

    public async Task<List<StakeTemplate>> GetFeaturedTemplatesAsync(int limit = 10)
    {
        return await _context.StakeTemplates
            .Where(t => t.IsActive && t.IsFeatured)
            .OrderByDescending(t => t.AverageSuccessRate)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<List<StakeTemplate>> GetPopularTemplatesAsync(int limit = 10)
    {
        return await _context.StakeTemplates
            .Where(t => t.IsActive)
            .OrderByDescending(t => t.UsageCount)
            .ThenByDescending(t => t.AverageSuccessRate)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<List<StakeTemplate>> GetUserTemplatesAsync(int userId)
    {
        return await _context.StakeTemplates
            .Where(t => t.CreatedByUserId == userId && t.IsActive)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task<StakeTemplate?> GetTemplateByIdAsync(int templateId)
    {
        return await _context.StakeTemplates.FindAsync(templateId);
    }

    public async Task<StakeTemplate> CreateUserTemplateAsync(int userId, StakeTemplate template)
    {
        template.CreatedByUserId = userId;
        template.IsActive = true;
        template.IsFeatured = false;
        template.UsageCount = 0;
        template.AverageSuccessRate = 0;
        template.CreatedAt = DateTime.UtcNow;

        _context.StakeTemplates.Add(template);
        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} created custom template: {Title}", userId, template.Title);

        return template;
    }

    public async Task SeedSystemTemplatesAsync()
    {
        // Check if templates already exist
        var existingCount = await _context.StakeTemplates.CountAsync();
        if (existingCount > 0)
        {
            _logger.LogInformation("Stake templates already seeded");
            return;
        }

        var templates = new List<StakeTemplate>
        {
            // Fitness templates
            new StakeTemplate
            {
                Title = "Gym 3x per week",
                Description = "Hit the gym at least 3 times this week",
                Category = StakeCategory.Fitness,
                Icon = "💪",
                SuggestedAmountEUR = 20,
                SuggestedRequiredCount = 3,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.GPS,
                SuggestedMinimumDurationMinutes = 45,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 75,
                Tags = "gym,fitness,workout,exercise",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "10,000 steps daily",
                Description = "Walk at least 10,000 steps every day this week",
                Category = StakeCategory.Fitness,
                Icon = "🚶",
                SuggestedAmountEUR = 15,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 70,
                Tags = "walking,steps,cardio,health",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Morning Run",
                Description = "Go for a morning run before 9 AM, 5 days this week",
                Category = StakeCategory.Fitness,
                Icon = "🏃",
                SuggestedAmountEUR = 25,
                SuggestedRequiredCount = 5,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.GPS,
                SuggestedMinimumDurationMinutes = 30,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 65,
                Tags = "running,morning,cardio,fitness",
                CreatedAt = DateTime.UtcNow
            },

            // Education templates
            new StakeTemplate
            {
                Title = "Learn 50 new words",
                Description = "Learn 50 new vocabulary words in a foreign language",
                Category = StakeCategory.Education,
                Icon = "📚",
                SuggestedAmountEUR = 30,
                SuggestedRequiredCount = 50,
                SuggestedDurationDays = 30,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 80,
                Tags = "language,learning,vocabulary,education",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Read 30 minutes daily",
                Description = "Read for at least 30 minutes every day",
                Category = StakeCategory.Education,
                Icon = "📖",
                SuggestedAmountEUR = 20,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Manual,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 85,
                Tags = "reading,books,learning,education",
                CreatedAt = DateTime.UtcNow
            },

            // Productivity templates
            new StakeTemplate
            {
                Title = "No social media after 9 PM",
                Description = "Avoid social media after 9 PM every night",
                Category = StakeCategory.Productivity,
                Icon = "📵",
                SuggestedAmountEUR = 25,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Manual,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 60,
                Tags = "digital-detox,focus,productivity,habits",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Wake up at 6 AM",
                Description = "Wake up at 6 AM every weekday",
                Category = StakeCategory.Productivity,
                Icon = "⏰",
                SuggestedAmountEUR = 20,
                SuggestedRequiredCount = 5,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 70,
                Tags = "morning,routine,productivity,wakeup",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Complete work by 6 PM",
                Description = "Finish all work tasks by 6 PM to have free evenings",
                Category = StakeCategory.Productivity,
                Icon = "💼",
                SuggestedAmountEUR = 30,
                SuggestedRequiredCount = 5,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Manual,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 65,
                Tags = "work,productivity,time-management,balance",
                CreatedAt = DateTime.UtcNow
            },

            // Finance templates
            new StakeTemplate
            {
                Title = "No eating out for a week",
                Description = "Cook all meals at home, save money by not eating out",
                Category = StakeCategory.Finance,
                Icon = "🍳",
                SuggestedAmountEUR = 40,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 70,
                Tags = "cooking,savings,budget,money",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Save 100€ this month",
                Description = "Put aside 100€ in savings account",
                Category = StakeCategory.Finance,
                Icon = "💰",
                SuggestedAmountEUR = 50,
                SuggestedRequiredCount = 1,
                SuggestedDurationDays = 30,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 75,
                Tags = "savings,money,finance,budget",
                CreatedAt = DateTime.UtcNow
            },

            // Personal Development templates
            new StakeTemplate
            {
                Title = "Meditate daily",
                Description = "Practice meditation for 10 minutes every day",
                Category = StakeCategory.Personal_Development,
                Icon = "🧘",
                SuggestedAmountEUR = 15,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Manual,
                IsFeatured = true,
                IsActive = true,
                AverageSuccessRate = 80,
                Tags = "meditation,mindfulness,wellness,mental-health",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Journal every morning",
                Description = "Write in your journal every morning for self-reflection",
                Category = StakeCategory.Personal_Development,
                Icon = "✍️",
                SuggestedAmountEUR = 20,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 75,
                Tags = "journaling,writing,reflection,mindfulness",
                CreatedAt = DateTime.UtcNow
            },

            // Health templates
            new StakeTemplate
            {
                Title = "Drink 2L water daily",
                Description = "Stay hydrated by drinking at least 2 liters of water per day",
                Category = StakeCategory.Personal_Development,
                Icon = "💧",
                SuggestedAmountEUR = 15,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Manual,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 85,
                Tags = "hydration,health,wellness,water",
                CreatedAt = DateTime.UtcNow
            },
            new StakeTemplate
            {
                Title = "Sleep by 11 PM",
                Description = "Go to bed before 11 PM every night for better sleep",
                Category = StakeCategory.Personal_Development,
                Icon = "😴",
                SuggestedAmountEUR = 20,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Manual,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 65,
                Tags = "sleep,health,routine,wellness",
                CreatedAt = DateTime.UtcNow
            },

            // Creativity templates
            new StakeTemplate
            {
                Title = "Create art daily",
                Description = "Spend 30 minutes on creative work (drawing, music, writing, etc.)",
                Category = StakeCategory.Creativity,
                Icon = "🎨",
                SuggestedAmountEUR = 25,
                SuggestedRequiredCount = 7,
                SuggestedDurationDays = 7,
                SuggestedProofMode = ProofMode.Photo,
                IsFeatured = false,
                IsActive = true,
                AverageSuccessRate = 70,
                Tags = "art,creativity,drawing,music,writing",
                CreatedAt = DateTime.UtcNow
            }
        };

        _context.StakeTemplates.AddRange(templates);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} system stake templates", templates.Count);
    }
}
