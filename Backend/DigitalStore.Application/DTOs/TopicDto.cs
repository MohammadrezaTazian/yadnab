namespace DigitalStore.Application.DTOs
{
    public class TopicDto
    {
        public int Id { get; set; }
        public int? ParentId { get; set; }
        public required string Title { get; set; }
        public string? ImageUrl { get; set; }
        public List<TopicDto> Children { get; set; } = new List<TopicDto>();
    }
}
