using StakeIt.Core.Entities;

namespace StakeIt.API.Services;

public interface IStakeTemplateService
{
    Task<List<StakeTemplate>> GetAllTemplatesAsync(string? category = null, string? searchQuery = null);
    Task<List<StakeTemplate>> GetFeaturedTemplatesAsync(int limit = 10);
    Task<List<StakeTemplate>> GetPopularTemplatesAsync(int limit = 10);
    Task<List<StakeTemplate>> GetUserTemplatesAsync(int userId);
    Task<StakeTemplate?> GetTemplateByIdAsync(int templateId);
    Task<StakeTemplate> CreateUserTemplateAsync(int userId, StakeTemplate template);
    Task SeedSystemTemplatesAsync();
}
