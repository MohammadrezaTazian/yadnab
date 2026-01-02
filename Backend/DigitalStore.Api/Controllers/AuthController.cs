using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ISettingsService _settingsService;

        public AuthController(IAuthService authService, ISettingsService settingsService)
        {
            _authService = authService;
            _settingsService = settingsService;
        }

        [HttpPost("send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] LoginRequestDto request)
        {
            var otp = await _authService.SendOtpAsync(request.PhoneNumber);
            return Ok(new { Message = "OTP sent", Otp = otp }); // Returning OTP for demo purposes
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            try
            {
                if (string.IsNullOrEmpty(request.Otp))
                {
                    return BadRequest(new { Message = "OTP is required" });
                }
                
                var userDto = await _authService.VerifyOtpAsync(request.PhoneNumber, request.Otp);
                
                // Initialize user settings after successful login
                await _settingsService.InitializeUserSettingsAsync(userDto.Id);
                
                return Ok(userDto);
            }
            catch (System.Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] string refreshToken)
        {
            try
            {
                var userDto = await _authService.RefreshTokenAsync(refreshToken);
                return Ok(userDto);
            }
            catch (System.Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }
    }
}
