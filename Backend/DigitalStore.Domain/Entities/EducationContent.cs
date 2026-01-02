using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class EducationContent : BaseEntity
    {
        public int TopicItemId { get; set; }
        public string Title { get; set; }
        public string ContentText { get; set; }
        public string? MediaUrl { get; set; }
        public string MediaType { get; set; } // "Text", "Image", "Video"
        public string? TeacherName { get; set; }
        
        // Navigation Property
        public TopicItem TopicItem { get; set; }
        public List<ContentImage> Images { get; set; } = new List<ContentImage>();
        
        public bool IsLiked { get; set; }
    }
}
