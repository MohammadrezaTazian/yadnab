using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;

namespace DigitalStore.Application.Services
{
    public class ContentManagementService : IContentManagementService
    {
        private readonly IContentManagementRepository _repository;
        private readonly IFileStorageService _fileStorageService;

        public ContentManagementService(
            IContentManagementRepository repository,
            IFileStorageService fileStorageService)
        {
            _repository = repository;
            _fileStorageService = fileStorageService;
        }

        public async Task<List<EntitySearchResultDto>> SearchEntitiesAsync(int entityTypeId, string? searchText)
        {
            var entities = await _repository.SearchEntitiesAsync(entityTypeId, searchText);
            
            return entities.Select(e => new EntitySearchResultDto
            {
                Id = e.Id,
                Title = e.Title,
                ExistingImageUrl = e.ExistingImageUrl
            }).ToList();
        }

        public async Task<ContentImageDto?> UploadImageAsync(UploadContentImageDto uploadDto, string? webRootPath = null)
        {
            if (uploadDto.ImageFile == null || uploadDto.ImageFile.Length == 0)
                return null;

            // 1. Determine subfolder based on EntityTypeId
            string subFolder = uploadDto.EntityTypeId switch
            {
                1 => "questions",
                2 => "answers",
                3 => "edu",
                _ => "others"
            };

            // 2. Save file securely using FileStorageService
            string relativeUrl = await _fileStorageService.SaveFileAsync(uploadDto.ImageFile, subFolder);

            // 3. Call Repository to save to DB with ImageTypeId
            var contentImage = await _repository.AddContentImageAsync(
                uploadDto.EntityTypeId,
                uploadDto.EntityId,
                relativeUrl,
                uploadDto.AltText,
                uploadDto.DisplayOrder,
                uploadDto.ImageTypeId
            );

            if (contentImage == null) return null;

            return new ContentImageDto
            {
                Id = contentImage.Id,
                ImageUrl = contentImage.ImageUrl,
                AltText = contentImage.AltText,
                DisplayOrder = contentImage.DisplayOrder,
                EntityTypeId = contentImage.EntityTypeId,
                EntityId = contentImage.EntityId,
                ImageTypeId = contentImage.ImageTypeId
            };
        }
    }
}
