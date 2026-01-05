namespace DigitalStore.Application.DTOs
{
    public class EntitySearchResultDto
    {
        public int Id { get; set; }
        public required string Title { get; set; }
        public string? ExistingImageUrl { get; set; }
    }
}
