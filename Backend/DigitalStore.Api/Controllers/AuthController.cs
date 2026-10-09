using System;
using System.Security.Claims;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ISettingsService _settingsService;
        private readonly IConfiguration _configuration;

        public AuthController(
            IAuthService authService,
            ISettingsService settingsService,
            IConfiguration configuration
        )
        {
            _authService = authService;
            _settingsService = settingsService;
            _configuration = configuration;
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
                SetSessionCookie(userDto.AccessToken);

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
                SetSessionCookie(userDto.AccessToken);
                return Ok(userDto);
            }
            catch (System.Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        private void SetSessionCookie(string accessToken)
        {
            var expiryMinutes = _configuration.GetValue<int?>("JwtSettings:ExpiryInMinutes") ?? 60;

            Response.Cookies.Append(
                "yadnab_session",
                accessToken,
                new CookieOptions
                {
                    HttpOnly = true,
                    Secure = Request.IsHttps,
                    SameSite = SameSiteMode.Lax,
                    Path = "/",
                    MaxAge = TimeSpan.FromMinutes(expiryMinutes),
                }
            );
        }

        [Authorize]
        [HttpGet("session")]
        public IActionResult GetSession()
        {
            return Ok(
                new
                {
                    authenticated = true,
                    userId = User.FindFirstValue(ClaimTypes.NameIdentifier),
                    phoneNumber = User.FindFirstValue(ClaimTypes.MobilePhone),
                }
            );
        }

        [HttpPost("logout")]
        public IActionResult Logout()
        {
            Response.Cookies.Delete(
                "yadnab_session",
                new CookieOptions
                {
                    HttpOnly = true,
                    Secure = Request.IsHttps,
                    SameSite = SameSiteMode.Lax,
                    Path = "/",
                }
            );

            return NoContent();
        }
    }
}
