namespace DigitalStore.Application.DTOs
{
    public class EducationContentDto
    {
        public int Id { get; set; }
        public int TopicItemId { get; set; }
        public required string Title { get; set; }
        public required string ContentText { get; set; }
        public string? MediaUrl { get; set; }
        public required string MediaType { get; set; } // "Text", "Image", "Video"
        public string? TeacherName { get; set; }
        public required string CreatedAt { get; set; } // Formatted Date
        public bool IsLiked { get; set; }
        public List<ContentImageDto> Images { get; set; } = new List<ContentImageDto>();
    }
}
