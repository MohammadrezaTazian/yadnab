using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class Product : BaseEntity
    {
        public string Title { get; set; }
        public string? Description { get; set; }
        public string? Category { get; set; } // e.g., "Grade 6", "Math"
        public string? ImageUrl { get; set; }
        public decimal Price { get; set; }
    }
}
