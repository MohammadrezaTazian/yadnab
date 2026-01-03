using System.Threading.Tasks;
using DigitalStore.Domain.Entities;

namespace DigitalStore.Domain.Interfaces
{
    public interface ISettingsRepository
    {
        Task<Setting?> GetSettingByKeyAsync(int userId, string key);
        Task UpdateSettingAsync(int userId, Setting setting);
        Task InitializeUserSettingsAsync(int userId);
    }
}
