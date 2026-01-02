using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;

namespace DigitalStore.Application.Interfaces
{
    public interface IAuthService
    {
        Task<string> SendOtpAsync(string phoneNumber); // Returns OTP for testing/display
        Task<UserDto> VerifyOtpAsync(string phoneNumber, string otp);
        Task<UserDto> RefreshTokenAsync(string refreshToken);
    }

    public interface IProductService
    {
        Task<IEnumerable<ProductDto>> GetProductsAsync(string category);
        Task<IEnumerable<ProductDto>> GetAllProductsAsync();
    }

    public interface ISettingsService
    {
        Task<SettingsDto> GetAllSettingsAsync(int userId);
        Task<string> GetThemeAsync(int userId);
        Task SetThemeAsync(int userId, string theme);
        Task<string> GetLanguageAsync(int userId);
        Task SetLanguageAsync(int userId, string language);
        Task<double> GetFontSizeAsync(int userId);
        Task SetFontSizeAsync(int userId, double fontSize);
        Task InitializeUserSettingsAsync(int userId);
    }

    public interface IUserService
    {
        Task<UserDto> GetProfileAsync(int userId);
        Task<UserDto> UpdateProfileAsync(int userId, UpdateProfileDto updateDto);
        Task<IEnumerable<GradeDto>> GetGradesAsync();
        Task<UserDto> UpdateProfilePictureAsync(int userId, string base64Image);
    }
}
