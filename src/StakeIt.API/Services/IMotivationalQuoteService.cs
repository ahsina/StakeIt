using StakeIt.Core.Entities;
using StakeIt.Core.Enums;

namespace StakeIt.API.Services;

public interface IMotivationalQuoteService
{
    Task<MotivationalQuote> GetRandomQuoteAsync(StakeCategory? category = null);
    Task<MotivationalQuote> GetDailyQuoteAsync();
    Task<List<MotivationalQuote>> GetQuotesByTypeAsync(QuoteType type, int limit = 10);
    Task<bool> LikeQuoteAsync(int quoteId, int userId);
    Task SeedQuotesAsync();
}
