using System.Collections.Generic;

namespace DigitalStore.Application.DTOs
{
    public class CourseTopicDto
    {
        public int Id { get; set; }
        public string Category { get; set; }
        public string? Title { get; set; }
        public List<TopicItemDto> Topics { get; set; } = new List<TopicItemDto>();
    }
}
