using DigitalStore.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface IEducationContentRepository
    {
        Task<IEnumerable<EducationContent>> GetByTopicIdAsync(int topicId, int? currentUserId = null);
        Task<EducationContent?> GetByIdAsync(int id, int? currentUserId = null);
    }
}
