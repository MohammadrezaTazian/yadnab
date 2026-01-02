using DigitalStore.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface IQuestionRepository
    {
        Task<IEnumerable<Question>> GetQuestionsByTopicIdAsync(int topicItemId, int? currentUserId = null);
        Task<Question> GetQuestionByIdAsync(int id, int? currentUserId = null);
    }
}
