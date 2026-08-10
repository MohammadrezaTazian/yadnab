using DigitalStore.Domain.Entities;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace DigitalStore.Domain.Interfaces
{
    public interface ITopicRepository
    {
        Task<IEnumerable<Topic>> GetTopicsByPackageAsync(int packageId);
        Task<IEnumerable<Topic>> GetAllTopicsAsync();
        Task<Topic?> GetByIdAsync(int id);
    }
}
