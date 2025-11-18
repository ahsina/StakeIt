using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Entities;
using StakeIt.Core.Enums;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class MotivationalQuoteService : IMotivationalQuoteService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<MotivationalQuoteService> _logger;

    public MotivationalQuoteService(StakeItDbContext context, ILogger<MotivationalQuoteService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<MotivationalQuote> GetRandomQuoteAsync(StakeCategory? category = null)
    {
        var query = _context.MotivationalQuotes.Where(q => q.IsActive);

        if (category.HasValue)
        {
            query = query.Where(q => q.Category == category.Value || q.Category == null);
        }

        var quotes = await query.ToListAsync();
        if (!quotes.Any())
        {
            throw new InvalidOperationException("No quotes available");
        }

        var random = new Random();
        var selectedQuote = quotes[random.Next(quotes.Count)];

        selectedQuote.TimesShown++;
        await _context.SaveChangesAsync();

        return selectedQuote;
    }

    public async Task<MotivationalQuote> GetDailyQuoteAsync()
    {
        // Use today's date as seed for consistency throughout the day
        var today = DateTime.UtcNow.Date;
        var seed = today.Year * 10000 + today.Month * 100 + today.Day;
        var random = new Random(seed);

        var quotes = await _context.MotivationalQuotes
            .Where(q => q.IsActive)
            .ToListAsync();

        if (!quotes.Any())
        {
            throw new InvalidOperationException("No quotes available");
        }

        var selectedQuote = quotes[random.Next(quotes.Count)];

        selectedQuote.TimesShown++;
        await _context.SaveChangesAsync();

        return selectedQuote;
    }

    public async Task<List<MotivationalQuote>> GetQuotesByTypeAsync(QuoteType type, int limit = 10)
    {
        return await _context.MotivationalQuotes
            .Where(q => q.IsActive && q.Type == type)
            .OrderByDescending(q => q.TimesLiked)
            .Take(limit)
            .ToListAsync();
    }

    public async Task<bool> LikeQuoteAsync(int quoteId, int userId)
    {
        var quote = await _context.MotivationalQuotes.FindAsync(quoteId);
        if (quote == null)
        {
            return false;
        }

        quote.TimesLiked++;
        await _context.SaveChangesAsync();

        return true;
    }

    public async Task SeedQuotesAsync()
    {
        var existingCount = await _context.MotivationalQuotes.CountAsync();
        if (existingCount > 0)
        {
            _logger.LogInformation("Motivational quotes already seeded");
            return;
        }

        var quotes = new List<MotivationalQuote>
        {
            // Discipline & Perseverance
            new MotivationalQuote
            {
                Text = "Discipline is choosing between what you want now and what you want most.",
                Author = "Abraham Lincoln",
                Type = QuoteType.Discipline,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "The difference between who you are and who you want to be is what you do.",
                Author = "Bill Phillips",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Success is the sum of small efforts repeated day in and day out.",
                Author = "Robert Collier",
                Type = QuoteType.Success,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "You don't have to be great to start, but you have to start to be great.",
                Author = "Zig Ziglar",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "The only impossible journey is the one you never begin.",
                Author = "Tony Robbins",
                Type = QuoteType.Inspirational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // Fitness-related
            new MotivationalQuote
            {
                Text = "Take care of your body. It's the only place you have to live.",
                Author = "Jim Rohn",
                Type = QuoteType.Fitness,
                Category = StakeCategory.Fitness,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "The only bad workout is the one that didn't happen.",
                Author = "Unknown",
                Type = QuoteType.Fitness,
                Category = StakeCategory.Fitness,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Your body can stand almost anything. It's your mind you have to convince.",
                Author = "Unknown",
                Type = QuoteType.Fitness,
                Category = StakeCategory.Fitness,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // Growth & Learning
            new MotivationalQuote
            {
                Text = "The beautiful thing about learning is that no one can take it away from you.",
                Author = "B.B. King",
                Type = QuoteType.Growth,
                Category = StakeCategory.Education,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Education is the most powerful weapon which you can use to change the world.",
                Author = "Nelson Mandela",
                Type = QuoteType.Growth,
                Category = StakeCategory.Education,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // Productivity
            new MotivationalQuote
            {
                Text = "Productivity is never an accident. It is always the result of a commitment to excellence.",
                Author = "Paul J. Meyer",
                Type = QuoteType.Productivity,
                Category = StakeCategory.Productivity,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Focus on being productive instead of busy.",
                Author = "Tim Ferriss",
                Type = QuoteType.Productivity,
                Category = StakeCategory.Productivity,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "The way to get started is to quit talking and begin doing.",
                Author = "Walt Disney",
                Type = QuoteType.Productivity,
                Category = StakeCategory.Productivity,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // Perseverance & Overcoming
            new MotivationalQuote
            {
                Text = "It does not matter how slowly you go as long as you do not stop.",
                Author = "Confucius",
                Type = QuoteType.Perseverance,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Fall seven times, stand up eight.",
                Author = "Japanese Proverb",
                Type = QuoteType.Perseverance,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Success is not final, failure is not fatal: it is the courage to continue that counts.",
                Author = "Winston Churchill",
                Type = QuoteType.Perseverance,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // Wisdom & Mindfulness
            new MotivationalQuote
            {
                Text = "The mind is everything. What you think you become.",
                Author = "Buddha",
                Type = QuoteType.Mindfulness,
                Category = StakeCategory.Personal_Development,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Be yourself; everyone else is already taken.",
                Author = "Oscar Wilde",
                Type = QuoteType.Wisdom,
                Category = StakeCategory.Personal_Development,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "In the middle of difficulty lies opportunity.",
                Author = "Albert Einstein",
                Type = QuoteType.Wisdom,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // Financial
            new MotivationalQuote
            {
                Text = "Do not save what is left after spending, but spend what is left after saving.",
                Author = "Warren Buffett",
                Type = QuoteType.Wisdom,
                Category = StakeCategory.Finance,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "An investment in knowledge pays the best interest.",
                Author = "Benjamin Franklin",
                Type = QuoteType.Wisdom,
                Category = StakeCategory.Finance,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },

            // More general motivation
            new MotivationalQuote
            {
                Text = "The secret of getting ahead is getting started.",
                Author = "Mark Twain",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Don't watch the clock; do what it does. Keep going.",
                Author = "Sam Levenson",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Everything you've ever wanted is on the other side of fear.",
                Author = "George Addair",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "The future belongs to those who believe in the beauty of their dreams.",
                Author = "Eleanor Roosevelt",
                Type = QuoteType.Inspirational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Believe you can and you're halfway there.",
                Author = "Theodore Roosevelt",
                Type = QuoteType.Inspirational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "What you do today can improve all your tomorrows.",
                Author = "Ralph Marston",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "The only way to do great work is to love what you do.",
                Author = "Steve Jobs",
                Type = QuoteType.Success,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "I have not failed. I've just found 10,000 ways that won't work.",
                Author = "Thomas Edison",
                Type = QuoteType.Perseverance,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "It always seems impossible until it's done.",
                Author = "Nelson Mandela",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            },
            new MotivationalQuote
            {
                Text = "Yesterday you said tomorrow. Just do it!",
                Author = "Nike",
                Type = QuoteType.Motivational,
                IsActive = true,
                TimesShown = 0,
                TimesLiked = 0,
                CreatedAt = DateTime.UtcNow
            }
        };

        _context.MotivationalQuotes.AddRange(quotes);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Seeded {Count} motivational quotes", quotes.Count);
    }
}
