using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class DifficultyLevel : BaseEntity
    {
        public required string Name { get; set; }
        public required string NameEn { get; set; }
    }
}
