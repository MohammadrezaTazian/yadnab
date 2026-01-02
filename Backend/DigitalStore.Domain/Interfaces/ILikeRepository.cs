using DigitalStore.Domain.Entities;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface ILikeRepository
    {
        Task<bool> ToggleLikeAsync(int userId, int targetId, byte targetType);
    }
}
