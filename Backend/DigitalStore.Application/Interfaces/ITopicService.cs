using DigitalStore.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Application.Interfaces
{
    public interface ITopicService
    {
        Task<List<TopicDto>> GetTopicsByPackageAsync(int packageId);
    }
}
