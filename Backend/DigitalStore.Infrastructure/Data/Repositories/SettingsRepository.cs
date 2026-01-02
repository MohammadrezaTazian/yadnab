using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class SettingsRepository : ISettingsRepository
    {
        private readonly ApplicationDbContext _context;

        public SettingsRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Setting> GetSettingByKeyAsync(int userId, string key)
        {
            // Use EF Core directly instead of stored procedure
            return await _context.Settings
                .FirstOrDefaultAsync(s => s.UserId == userId && s.Key == key);
        }

        public async Task UpdateSettingAsync(int userId, Setting setting)
        {
            // Use EF Core directly instead of stored procedure
            var existingSetting = await _context.Settings
                .FirstOrDefaultAsync(s => s.UserId == userId && s.Key == setting.Key);

            if (existingSetting != null)
            {
                // Update existing setting
                existingSetting.Value = setting.Value;
                _context.Settings.Update(existingSetting);
            }
            else
            {
                // Create new setting
                var newSetting = new Setting
                {
                    UserId = userId,
                    Key = setting.Key,
                    Value = setting.Value
                };
                await _context.Settings.AddAsync(newSetting);
            }

            await _context.SaveChangesAsync();
        }

        public async Task InitializeUserSettingsAsync(int userId)
        {
            // Not needed anymore since we handle it in SettingsService
            await Task.CompletedTask;
        }
    }
}
