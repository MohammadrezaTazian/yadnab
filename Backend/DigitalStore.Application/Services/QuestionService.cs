using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;

namespace DigitalStore.Application.Services
{
    public class QuestionService : IQuestionService
    {
        private readonly IQuestionRepository _questionRepository;

        public QuestionService(IQuestionRepository questionRepository)
        {
            _questionRepository = questionRepository;
        }

        public async Task<IEnumerable<QuestionDto>> GetQuestionsByTopicIdAsync(int topicId, int? currentUserId = null)
        {
            var questions = await _questionRepository.GetQuestionsByTopicIdAsync(topicId, currentUserId);
            return questions.Select(q => new QuestionDto
            {
                Id = q.Id,
                TopicItemId = q.TopicItemId,
                QuestionText = q.QuestionText,
                Option1 = q.Option1,
                Option2 = q.Option2,
                Option3 = q.Option3,
                Option4 = q.Option4,
                CorrectOption = q.CorrectOption,
                QuestionImages = q.QuestionImages.Select(i => new ContentImageDto
                {
                    Id = i.Id,
                    ImageUrl = i.ImageUrl,
                    DisplayOrder = i.DisplayOrder,
                    AltText = i.AltText
                }).ToList(),
                QuestionDesigner = q.QuestionDesigner,
                QuestionYear = q.QuestionYear,
                DifficultyLevelId = q.DifficultyLevelId,
                DifficultyLevelName = q.DifficultyLevel?.Name,
                IsLiked = q.IsLiked,
                DetailedAnswer = q.DetailedAnswer != null ? new DetailedAnswerDto
                {
                    Id = q.DetailedAnswer.Id,
                    QuestionId = q.DetailedAnswer.QuestionId,
                    AnswerText = q.DetailedAnswer.AnswerText,
                    AnswerImages = q.DetailedAnswer.AnswerImages.Select(i => new ContentImageDto
                    {
                        Id = i.Id,
                        ImageUrl = i.ImageUrl,
                        DisplayOrder = i.DisplayOrder,
                        AltText = i.AltText
                    }).ToList(),
                    AnswerAuthor = q.DetailedAnswer.AnswerAuthor,
                    AnswerYear = q.DetailedAnswer.AnswerYear,
                    IsLiked = q.DetailedAnswer.IsLiked
                } : null
            });
        }

        public async Task<QuestionDto?> GetQuestionByIdAsync(int id, int? currentUserId = null)
        {
            var q = await _questionRepository.GetQuestionByIdAsync(id, currentUserId);
            if (q == null) return null;

            return new QuestionDto
            {
                Id = q.Id,
                TopicItemId = q.TopicItemId,
                QuestionText = q.QuestionText,
                Option1 = q.Option1,
                Option2 = q.Option2,
                Option3 = q.Option3,
                Option4 = q.Option4,
                CorrectOption = q.CorrectOption,
                QuestionImages = q.QuestionImages.Select(i => new ContentImageDto
                {
                    Id = i.Id,
                    ImageUrl = i.ImageUrl,
                    DisplayOrder = i.DisplayOrder,
                    AltText = i.AltText
                }).ToList(),
                QuestionDesigner = q.QuestionDesigner,
                QuestionYear = q.QuestionYear,
                DifficultyLevelId = q.DifficultyLevelId,
                DifficultyLevelName = q.DifficultyLevel?.Name,
                IsLiked = q.IsLiked,
                DetailedAnswer = q.DetailedAnswer != null ? new DetailedAnswerDto
                {
                    Id = q.DetailedAnswer.Id,
                    QuestionId = q.DetailedAnswer.QuestionId,
                    AnswerText = q.DetailedAnswer.AnswerText,
                    AnswerImages = q.DetailedAnswer.AnswerImages.Select(i => new ContentImageDto
                    {
                        Id = i.Id,
                        ImageUrl = i.ImageUrl,
                        DisplayOrder = i.DisplayOrder,
                        AltText = i.AltText
                    }).ToList(),
                    AnswerAuthor = q.DetailedAnswer.AnswerAuthor,
                    AnswerYear = q.DetailedAnswer.AnswerYear,
                    IsLiked = q.DetailedAnswer.IsLiked
                } : null
            };
        }
    }
}
