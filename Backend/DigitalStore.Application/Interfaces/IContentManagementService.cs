using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using Microsoft.AspNetCore.Http;

namespace DigitalStore.Application.Interfaces
{
    public interface IContentManagementService
    {
        Task<List<EntitySearchResultDto>> SearchEntitiesAsync(int entityTypeId, string? searchText);
        Task<ContentImageDto?> UploadImageAsync(UploadContentImageDto uploadDto, string webRootPath);
    }
}
