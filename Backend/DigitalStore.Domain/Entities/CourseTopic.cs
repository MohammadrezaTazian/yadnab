using DigitalStore.Domain.Common;
using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class CourseTopic : BaseEntity
    {
        public string Category { get; set; } // Grade6, Grade9, MathPhysics, Experimental, Humanities
        public string? Title { get; set; }
        
        public ICollection<TopicItem> TopicItems { get; set; } = new List<TopicItem>();
    }
}
