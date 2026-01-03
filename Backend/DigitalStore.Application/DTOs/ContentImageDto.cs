namespace DigitalStore.Application.DTOs
{
    public class ContentImageDto
    {
        public int Id { get; set; }
        public required string ImageUrl { get; set; }
        public int DisplayOrder { get; set; }
        public string? AltText { get; set; }
    }
}
