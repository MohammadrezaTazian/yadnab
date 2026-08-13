using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace DigitalStore.Application.Services
{
    public class TopicService : ITopicService
    {
        private readonly ITopicRepository _topicRepository;

        public TopicService(ITopicRepository topicRepository)
        {
            _topicRepository = topicRepository;
        }

        public async Task<List<TopicDto>> GetTopicsByPackageAsync(int packageId)
        {
            var topics = await _topicRepository.GetTopicsByPackageAsync(packageId);

            // 1. Convert all items to DTOs
            var allTopicDtos = topics.Select(t => new TopicDto
            {
                Id = t.Id,
                ParentId = t.ParentId,
                Title = t.Title,
                ImageUrl = t.ImageUrl,
                Children = new List<TopicDto>()
            }).ToList();

            // 2. Build Hierarchy safely without crashing on duplicate leaf topic IDs
            var lookup = allTopicDtos.GroupBy(x => x.Id).ToDictionary(g => g.Key, g => g.First());
            var rootNodes = new List<TopicDto>();

            foreach (var item in allTopicDtos)
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

            return rootNodes;
        }
    }
}
