using System;

namespace DigitalStore.Domain.Entities
{
    public class UserLike
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public int TargetId { get; set; }
        public byte TargetType { get; set; } // 1=Question, 2=Answer, 3=EducationContent, 4=Comment
        public DateTime CreatedAt { get; set; }
    }
}
