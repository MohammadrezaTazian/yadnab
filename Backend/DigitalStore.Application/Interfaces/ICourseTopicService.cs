using DigitalStore.Application.DTOs;
using System.Threading.Tasks;

namespace DigitalStore.Application.Interfaces
{
    public interface ICourseTopicService
    {
        Task<CourseTopicDto> GetTopicsByCategoryAsync(string category);
    }
}
