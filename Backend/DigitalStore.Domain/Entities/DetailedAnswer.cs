using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class DetailedAnswer : BaseEntity
    {
        public int QuestionId { get; set; }
        public string AnswerText { get; set; }
        public List<ContentImage> AnswerImages { get; set; } = new List<ContentImage>();

        public string? AnswerAuthor { get; set; }
        public int AnswerYear { get; set; }
        
        public Question Question { get; set; }
        
        public bool IsLiked { get; set; }
    }
}
