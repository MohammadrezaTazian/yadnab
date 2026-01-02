using DigitalStore.Domain.Entities;

namespace DigitalStore.Application.Interfaces
{
    public interface IJwtService
    {
        string GenerateAccessToken(User user);
        string GenerateRefreshToken();
        // ClaimsPrincipal GetPrincipalFromExpiredToken(string token);
    }
}
