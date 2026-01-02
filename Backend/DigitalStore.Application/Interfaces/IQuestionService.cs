using DigitalStore.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Application.Interfaces
{
    public interface IQuestionService
    {
        Task<IEnumerable<QuestionDto>> GetQuestionsByTopicIdAsync(int topicItemId, int? currentUserId = null);
        Task<QuestionDto> GetQuestionByIdAsync(int id, int? currentUserId = null);
    }
}
