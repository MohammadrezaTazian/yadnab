using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class Grade : BaseEntity
    {
        public required string Name { get; set; } // e.g., "پایه ششم", "پایه هفتم"
        public string? Description { get; set; }
    }
}
