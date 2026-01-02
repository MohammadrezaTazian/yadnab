using System;
using System.Collections.Generic;

namespace DigitalStore.Application.DTOs
{
    public class CommentDto
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public string UserDisplayName { get; set; } = string.Empty;
        public string? UserAvatar { get; set; }
        public string Content { get; set; } = string.Empty;
        public int LikeCount { get; set; }
        public string CreatedAt { get; set; } = string.Empty;
        public List<CommentDto> Replies { get; set; } = new List<CommentDto>();
        public bool IsLikedByCurrentUser { get; set; }
    }

    public class CreateCommentDto
    {
        public int TargetId { get; set; }
        public byte TargetType { get; set; }
        public long? ParentCommentId { get; set; }
        public string Content { get; set; } = string.Empty;
    }

    public class ToggleLikeDto
    {
        public int TargetId { get; set; }
        public byte TargetType { get; set; }
    }
}
