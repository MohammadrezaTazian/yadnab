using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DigitalStore.Application.Services
{
    public class EducationContentService : IEducationContentService
    {
        private readonly IEducationContentRepository _repository;

        public EducationContentService(IEducationContentRepository repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<EducationContentDto>> GetContentsByTopicItemIdAsync(int topicItemId, int? currentUserId = null)
        {
            var contents = await _repository.GetByTopicItemIdAsync(topicItemId, currentUserId);
            return contents.Select(MapToDto);
        }

        public async Task<EducationContentDto> GetContentByIdAsync(int id, int? currentUserId = null)
        {
            var content = await _repository.GetByIdAsync(id, currentUserId);
            if (content == null) return null;
            return MapToDto(content);
        }

        private EducationContentDto MapToDto(EducationContent entity)
        {
            return new EducationContentDto
            {
                Id = entity.Id,
                TopicItemId = entity.TopicItemId,
                Title = entity.Title,
                ContentText = entity.ContentText,
                MediaUrl = entity.MediaUrl,
                MediaType = entity.MediaType,
                TeacherName = entity.TeacherName,
                CreatedAt = entity.CreatedAt.ToString("yyyy-MM-dd"),
                IsLiked = entity.IsLiked,
                Images = entity.Images.Select(i => new ContentImageDto
                {
                    Id = i.Id,
                    ImageUrl = i.ImageUrl,
                    DisplayOrder = i.DisplayOrder,
                    AltText = i.AltText
                }).ToList()
            };
        }
    }
}
