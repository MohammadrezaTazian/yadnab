using DigitalStore.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Application.Interfaces
{
    public interface IEducationContentService
    {
        Task<IEnumerable<EducationContentDto>> GetContentsByTopicItemIdAsync(int topicItemId, int? currentUserId = null);
        Task<EducationContentDto?> GetContentByIdAsync(int id, int? currentUserId = null);
    }
}
