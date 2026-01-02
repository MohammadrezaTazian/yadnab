using System.Security.Claims;
using System.Threading.Tasks;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SettingsController : ControllerBase
    {
        private readonly ISettingsService _settingsService;

        public SettingsController(ISettingsService settingsService)
        {
            _settingsService = settingsService;
        }

        private int GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return int.Parse(userIdClaim);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllSettings()
        {
            var userId = GetUserId();
            var settings = await _settingsService.GetAllSettingsAsync(userId);
            return Ok(settings);
        }

        [HttpGet("theme")]
        public async Task<IActionResult> GetTheme()
        {
            var userId = GetUserId();
            var theme = await _settingsService.GetThemeAsync(userId);
            return Ok(new { Theme = theme });
        }

        [HttpPost("theme")]
        public async Task<IActionResult> SetTheme([FromBody] string theme)
        {
            var userId = GetUserId();
            await _settingsService.SetThemeAsync(userId, theme);
            return Ok();
        }

        [HttpGet("language")]
        public async Task<IActionResult> GetLanguage()
        {
            var userId = GetUserId();
            var lang = await _settingsService.GetLanguageAsync(userId);
            return Ok(new { Language = lang });
        }

        [HttpPost("language")]
        public async Task<IActionResult> SetLanguage([FromBody] string language)
        {
            var userId = GetUserId();
            await _settingsService.SetLanguageAsync(userId, language);
            return Ok();
        }

        [HttpGet("fontsize")]
        public async Task<IActionResult> GetFontSize()
        {
            var userId = GetUserId();
            var fontSize = await _settingsService.GetFontSizeAsync(userId);
            return Ok(new { FontSize = fontSize });
        }

        [HttpPost("fontsize")]
        public async Task<IActionResult> SetFontSize([FromBody] double fontSize)
        {
            var userId = GetUserId();
            await _settingsService.SetFontSizeAsync(userId, fontSize);
            return Ok();
        }
    }
}
