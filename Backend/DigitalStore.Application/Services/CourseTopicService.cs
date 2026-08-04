using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace DigitalStore.Application.Services
{
    public class CourseTopicService : ICourseTopicService
    {
        private readonly ICourseTopicRepository _courseTopicRepository;

        public CourseTopicService(ICourseTopicRepository courseTopicRepository)
        {
            _courseTopicRepository = courseTopicRepository;
        }

        public async Task<CourseTopicDto?> GetTopicsByPackageAsync(int packageId)
        {
            var courseTopic = await _courseTopicRepository.GetTopicsByPackageAsync(packageId);
            
            if (courseTopic == null) return null;

            // 1. Convert all items to DTOs
            var allItemDtos = courseTopic.TopicItems.Select(t => new TopicItemDto
            {
                Id = t.Id,
                CourseTopicId = t.CourseTopicId,
                ParentId = t.ParentId,
                Title = t.Title,
                ImageUrl = t.ImageUrl,
                Children = new List<TopicItemDto>()
            }).ToList();

            // 2. Build Hierarchy
            var lookup = allItemDtos.ToDictionary(x => x.Id);
            var rootNodes = new List<TopicItemDto>();

            foreach (var item in allItemDtos)
            {
                if (item.ParentId.HasValue && lookup.TryGetValue(item.ParentId.Value, out var parent))
                {
                    parent.Children.Add(item);
                }
                else
                {
                    rootNodes.Add(item);
                }
            }

            return new CourseTopicDto
            {
                Id = courseTopic.Id,
                PackageId = courseTopic.PackageId,
                Title = courseTopic.Title,
                Topics = rootNodes
            };
        }
    }
}
