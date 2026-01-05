using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;
using Microsoft.AspNetCore.Http;

namespace DigitalStore.Application.Services
{
    public class ContentManagementService : IContentManagementService
    {
        private readonly IContentManagementRepository _repository;

        public ContentManagementService(IContentManagementRepository repository)
        {
            _repository = repository;
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

        public async Task<ContentImageDto?> UploadImageAsync(UploadContentImageDto uploadDto, string webRootPath)
        {
            if (uploadDto.ImageFile == null || uploadDto.ImageFile.Length == 0)
                return null;

            // 1. Determine relative path folder based on type
            string folderName = uploadDto.EntityTypeId switch
            {
                1 => "questions",
                2 => "answers",
                3 => "edu",
                _ => "others"
            };

            string uploadsFolder = Path.Combine(webRootPath, "images", folderName);
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            // 2. Generate unique filename
            string uniqueFileName = Guid.NewGuid().ToString() + Path.GetExtension(uploadDto.ImageFile.FileName);
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);

            // 3. Save file
            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await uploadDto.ImageFile.CopyToAsync(fileStream);
            }

            // 4. Generate relative URL for DB
            // e.g. /images/questions/abc.png
            string relativeUrl = $"/images/{folderName}/{uniqueFileName}";

            // 5. Call Repository to save to DB
            var contentImage = await _repository.AddContentImageAsync(
                uploadDto.EntityTypeId,
                uploadDto.EntityId,
                relativeUrl,
                uploadDto.AltText,
                0 // Default display order
            );

            if (contentImage == null) return null;

            return new ContentImageDto
            {
                Id = contentImage.Id,
                ImageUrl = contentImage.ImageUrl,
                AltText = contentImage.AltText,
                DisplayOrder = contentImage.DisplayOrder,
                EntityTypeId = contentImage.EntityTypeId,
                EntityId = contentImage.EntityId
            };
        }
    }
}
