using System.Threading.Tasks;
using DigitalStore.Domain.Entities;

namespace DigitalStore.Domain.Interfaces
{
    public interface IAuthRepository
    {
        Task<User?> GetUserByPhoneNumberAsync(string phoneNumber);
        Task<User?> CreateUserAsync(User user);
        Task UpdateUserAsync(User user);
        Task<User?> GetUserByRefreshTokenAsync(string refreshToken);
        Task<User?> UpdateProfilePictureAsync(int userId, string base64Image);
    }
}
