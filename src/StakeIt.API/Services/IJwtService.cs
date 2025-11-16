using StakeIt.Core.Entities;
using System.Security.Claims;

namespace StakeIt.API.Services;

public interface IJwtService
{
    string GenerateAccessToken(User user);
    string GenerateRefreshToken();
    ClaimsPrincipal? ValidateToken(string token);
}
