using System;

namespace DigitalStore.Domain.Entities
{
    public class Comment
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public int TargetId { get; set; }
        public byte TargetType { get; set; } // 1=Question, 2=Answer, 3=EducationContent
        public long? ParentCommentId { get; set; }
        public string Content { get; set; } = string.Empty;
        public int LikeCount { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime CreatedAt { get; set; }

        // Extra properties mapped from SQL Join
        public string UserDisplayName { get; set; } = string.Empty;
        public string? UserAvatar { get; set; }
        public bool IsLikedByCurrentUser { get; set; }
    }
}
