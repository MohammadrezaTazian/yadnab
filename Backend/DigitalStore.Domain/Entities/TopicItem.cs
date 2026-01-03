using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class TopicItem
    {
        public int Id { get; set; }
        public int CourseTopicId { get; set; }
        public int? ParentId { get; set; } // New: Self-Ref
        public required string Title { get; set; }
        public required string ImageUrl { get; set; }

        public ICollection<TopicItem> Children { get; set; } = new List<TopicItem>(); // New: Navigation property
        public CourseTopic CourseTopic { get; set; } = null!;
    }
}
