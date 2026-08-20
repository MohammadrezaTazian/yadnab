using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class DetailedAnswer : BaseEntity
    {
        public int QuestionId { get; set; }
        public required string AnswerText { get; set; }
        public List<ContentImage> AnswerImages { get; set; } = new List<ContentImage>();

        public string? AnswerAuthor { get; set; }
        public int AnswerYear { get; set; }
        public string? SourceCode { get; set; } // Helper key for data import/convert pipeline
        
        public Question Question { get; set; } = null!;
        
        public bool IsLiked { get; set; }
    }
}
