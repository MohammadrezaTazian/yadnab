using DigitalStore.Domain.Entities;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface ICourseTopicRepository
    {
        Task<CourseTopic> GetTopicsByCategoryAsync(string category);
    }
}
