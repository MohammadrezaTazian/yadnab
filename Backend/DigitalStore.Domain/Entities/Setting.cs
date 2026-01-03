using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class Setting : BaseEntity
    {
        public int UserId { get; set; }
        public required string Key { get; set; }
        public required string Value { get; set; }
    }
}
