using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class CourseTopic : BaseEntity
    {
        public int PackageId { get; set; }
        public Package? Package { get; set; }
        public string? Title { get; set; }
        
        public ICollection<TopicItem> TopicItems { get; set; } = new List<TopicItem>();
    }
}
