using System;

namespace DigitalStore.Domain.Entities
{
    public class EntityType
    {
        public int Id { get; set; }
        public required string TypeName { get; set; }
    }
}
