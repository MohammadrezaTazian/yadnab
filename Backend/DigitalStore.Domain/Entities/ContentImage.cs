using System;

namespace DigitalStore.Domain.Entities
{
    public class ContentImage
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; }
        public int DisplayOrder { get; set; }
        public string? AltText { get; set; }
        public int EntityTypeId { get; set; }
        public int EntityId { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
