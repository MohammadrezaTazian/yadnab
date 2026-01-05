using System.ComponentModel.DataAnnotations.Schema;

namespace DigitalStore.Domain.Entities
{
    [NotMapped]
    public class EntitySearchResult
    {
        public int Id { get; set; }
        public required string Title { get; set; }
        public string? ExistingImageUrl { get; set; }
    }
}
