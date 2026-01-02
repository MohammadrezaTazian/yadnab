using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class Setting : BaseEntity
    {
        public int UserId { get; set; }
        public string Key { get; set; }
        public string Value { get; set; }
    }
}
