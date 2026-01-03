using DigitalStore.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface IEducationContentRepository
    {
        Task<IEnumerable<EducationContent>> GetByTopicItemIdAsync(int topicItemId, int? currentUserId = null);
        Task<EducationContent?> GetByIdAsync(int id, int? currentUserId = null);
    }
}
