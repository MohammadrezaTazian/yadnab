using DigitalStore.Domain.Common;
using System.Collections.Generic;

namespace DigitalStore.Domain.Entities
{
    public class Question : BaseEntity
    {
        public int TopicItemId { get; set; }
        public required string QuestionText { get; set; }
        public required string Option1 { get; set; }
        public required string Option2 { get; set; }
        public required string Option3 { get; set; }
        public required string Option4 { get; set; }
        public int CorrectOption { get; set; } // 1, 2, 3, or 4
        public List<ContentImage> QuestionImages { get; set; } = new List<ContentImage>();

        public string? QuestionDesigner { get; set; }
        public int QuestionYear { get; set; }
        public int DifficultyLevelId { get; set; }
        
        public TopicItem TopicItem { get; set; } = null!;
        public DifficultyLevel DifficultyLevel { get; set; } = null!;
        public DetailedAnswer DetailedAnswer { get; set; } = null!;

        public bool IsLiked { get; set; }
    }
}
