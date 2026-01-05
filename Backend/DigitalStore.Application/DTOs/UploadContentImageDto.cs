using Microsoft.AspNetCore.Http;

namespace DigitalStore.Application.DTOs
{
    public class UploadContentImageDto
    {
        public int EntityTypeId { get; set; }
        public int EntityId { get; set; }
        public required IFormFile ImageFile { get; set; }
        public string? AltText { get; set; }
    }
}
