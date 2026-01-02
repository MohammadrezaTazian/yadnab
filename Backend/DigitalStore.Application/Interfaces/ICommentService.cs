using DigitalStore.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Application.Interfaces
{
    public interface ICommentService
    {
        Task<CommentDto> AddCommentAsync(int userId, CreateCommentDto dto);
        Task<IEnumerable<CommentDto>> GetCommentsByTargetIdAsync(int targetId, byte targetType, int? currentUserId = null);
        Task DeleteCommentAsync(long id, int userId);
    }
}
