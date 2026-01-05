namespace DigitalStore.Application.DTOs
{
    public class TopicItemDto
    {
        public int Id { get; set; }
        public int CourseTopicId { get; set; }
        public int? ParentId { get; set; } // New
        public required string Title { get; set; }
        public string? ImageUrl { get; set; }
        public List<TopicItemDto> Children { get; set; } = new List<TopicItemDto>(); // New
    }
}
