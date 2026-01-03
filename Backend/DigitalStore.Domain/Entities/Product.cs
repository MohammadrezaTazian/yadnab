using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class Product : BaseEntity
    {
        public required string Title { get; set; }
        public string? Description { get; set; }
        public string? Category { get; set; } // e.g., "Grade 6", "Math"
        public string? ImageUrl { get; set; }
        
        [System.ComponentModel.DataAnnotations.Schema.Column(TypeName = "decimal(18,2)")]
        public decimal Price { get; set; }
    }
}
