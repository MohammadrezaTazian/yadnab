using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;

namespace DigitalStore.Application.Services
{
    public class SettingsService : ISettingsService
    {
        private readonly ISettingsRepository _settingsRepository;

        public SettingsService(ISettingsRepository settingsRepository)
        {
            _settingsRepository = settingsRepository;
        }

        public async Task<SettingsDto> GetAllSettingsAsync(int userId)
        {
            var theme = await GetThemeAsync(userId);
            var language = await GetLanguageAsync(userId);
            var fontSize = await GetFontSizeAsync(userId);

            return new SettingsDto
            {
                Theme = theme,
                Language = language,
                FontSize = fontSize
            };
        }

        public async Task<string> GetThemeAsync(int userId)
        {
            var setting = await _settingsRepository.GetSettingByKeyAsync(userId, "Theme");
            return setting?.Value ?? "Light";
        }

        public async Task SetThemeAsync(int userId, string theme)
        {
            var setting = await _settingsRepository.GetSettingByKeyAsync(userId, "Theme");
            if (setting == null)
            {
                setting = new Setting { Key = "Theme", Value = theme };
            }
            else
            {
                setting.Value = theme;
            }
            await _settingsRepository.UpdateSettingAsync(userId, setting);
        }

        public async Task<string> GetLanguageAsync(int userId)
        {
             var setting = await _settingsRepository.GetSettingByKeyAsync(userId, "Language");
            return setting?.Value ?? "fa";
        }

        public async Task SetLanguageAsync(int userId, string language)
        {
             var setting = await _settingsRepository.GetSettingByKeyAsync(userId, "Language");
             if (setting == null)
             {
                 setting = new Setting { Key = "Language", Value = language };
             }
             else
             {
                 setting.Value = language;
             }
             await _settingsRepository.UpdateSettingAsync(userId, setting);
        }

        public async Task<double> GetFontSizeAsync(int userId)
        {
            var setting = await _settingsRepository.GetSettingByKeyAsync(userId, "FontSize");
            if (setting?.Value != null && double.TryParse(setting.Value, out double fontSize))
            {
                return fontSize;
            }
            return 14.0; // Default font size
        }

        public async Task SetFontSizeAsync(int userId, double fontSize)
        {
            var setting = await _settingsRepository.GetSettingByKeyAsync(userId, "FontSize");
            if (setting == null)
            {
                setting = new Setting { Key = "FontSize", Value = fontSize.ToString() };
            }
            else
            {
                setting.Value = fontSize.ToString();
            }
            await _settingsRepository.UpdateSettingAsync(userId, setting);
        }

        public async Task InitializeUserSettingsAsync(int userId)
        {
            // Ensure Theme exists
            var theme = await _settingsRepository.GetSettingByKeyAsync(userId, "Theme");
            if (theme == null)
            {
                await _settingsRepository.UpdateSettingAsync(userId, new Setting { Key = "Theme", Value = "Light" });
            }

            // Ensure Language exists
            var language = await _settingsRepository.GetSettingByKeyAsync(userId, "Language");
            if (language == null)
            {
                await _settingsRepository.UpdateSettingAsync(userId, new Setting { Key = "Language", Value = "fa" });
            }

            // Ensure FontSize exists
            var fontSize = await _settingsRepository.GetSettingByKeyAsync(userId, "FontSize");
            if (fontSize == null)
            {
                await _settingsRepository.UpdateSettingAsync(userId, new Setting { Key = "FontSize", Value = "14.0" });
            }
        }
    }
}
