using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class Topic
    {
        public int Id { get; set; }
        public int? ParentId { get; set; }
        public required string Title { get; set; }
        public string? ImageUrl { get; set; }

        public Topic? Parent { get; set; }
        public ICollection<Topic> Children { get; set; } = new List<Topic>();
        public ICollection<PackageTopic> PackageTopics { get; set; } = new List<PackageTopic>();
    }
}
