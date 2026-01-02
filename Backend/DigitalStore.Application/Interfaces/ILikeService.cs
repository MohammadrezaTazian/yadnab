using DigitalStore.Application.DTOs;
using System.Threading.Tasks;

namespace DigitalStore.Application.Interfaces
{
    public interface ILikeService
    {
        Task<bool> ToggleLikeAsync(int userId, int targetId, byte targetType);
    }
}
