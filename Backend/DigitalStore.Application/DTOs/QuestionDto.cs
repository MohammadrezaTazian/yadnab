using System.Collections.Generic;

namespace DigitalStore.Application.DTOs
{
    public class QuestionDto
    {
        public int Id { get; set; }
        public int TopicItemId { get; set; }
        public string QuestionText { get; set; }
        public string Option1 { get; set; }
        public string Option2 { get; set; }
        public string Option3 { get; set; }
        public string Option4 { get; set; }
        public int CorrectOption { get; set; }
        public List<ContentImageDto> QuestionImages { get; set; } = new List<ContentImageDto>();
        public string? QuestionDesigner { get; set; }
        public int QuestionYear { get; set; }
        public int DifficultyLevelId { get; set; }
        public string? DifficultyLevelName { get; set; }
        
        public DetailedAnswerDto? DetailedAnswer { get; set; }
        public bool IsLiked { get; set; }
    }

    public class DetailedAnswerDto
    {
        public int Id { get; set; }
        public int QuestionId { get; set; }
        public string AnswerText { get; set; }
        public List<ContentImageDto> AnswerImages { get; set; } = new List<ContentImageDto>();
        public string? AnswerAuthor { get; set; }
        public int AnswerYear { get; set; }
        public bool IsLiked { get; set; }
    }
}
