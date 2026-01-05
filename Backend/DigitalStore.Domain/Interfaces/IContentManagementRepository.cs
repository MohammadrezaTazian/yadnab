using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;

namespace DigitalStore.Domain.Interfaces
{
    public interface IContentManagementRepository
    {
        Task<List<EntitySearchResult>> SearchEntitiesAsync(int entityTypeId, string? searchText);
        Task<ContentImage?> AddContentImageAsync(int entityTypeId, int entityId, string imageUrl, string? altText, int displayOrder);
    }
}
