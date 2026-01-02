using DigitalStore.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface ICommentRepository
    {
        Task<Comment> AddAsync(Comment comment);
        Task<IEnumerable<Comment>> GetByTargetIdAsync(int targetId, byte targetType, int? currentUserId = null);
        Task DeleteAsync(long id, int userId);
    }
}
