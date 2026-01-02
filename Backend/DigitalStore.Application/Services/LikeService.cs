using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;
using System.Threading.Tasks;

namespace DigitalStore.Application.Services
{
    public class LikeService : ILikeService
    {
        private readonly ILikeRepository _repository;

        public LikeService(ILikeRepository repository)
        {
            _repository = repository;
        }

        public async Task<bool> ToggleLikeAsync(int userId, int targetId, byte targetType)
        {
            return await _repository.ToggleLikeAsync(userId, targetId, targetType);
        }
    }
}
