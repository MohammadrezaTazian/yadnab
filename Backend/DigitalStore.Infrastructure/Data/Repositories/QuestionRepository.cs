using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using System.Text.Json;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class QuestionRepository : IQuestionRepository
    {
        private readonly ApplicationDbContext _context;

        public QuestionRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Question>> GetQuestionsByTopicIdAsync(int topicItemId, int? currentUserId = null)
        {
            var questionsMap = new Dictionary<int, Question>();
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetQuestionsByTopicItemId";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var param = command.CreateParameter();
                    param.ParameterName = "@TopicItemId";
                    param.Value = topicItemId;
                    command.Parameters.Add(param);
                    
                    var userParam = command.CreateParameter();
                    userParam.ParameterName = "@CurrentUserId";
                    userParam.Value = currentUserId ?? (object)DBNull.Value;
                    command.Parameters.Add(userParam);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // 1. Read Questions
                        while (await reader.ReadAsync())
                        {
                            var q = new Question
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                TopicItemId = reader.GetInt32(reader.GetOrdinal("TopicItemId")),
                                QuestionText = reader.GetString(reader.GetOrdinal("QuestionText")),
                                Option1 = reader.GetString(reader.GetOrdinal("Option1")),
                                Option2 = reader.GetString(reader.GetOrdinal("Option2")),
                                Option3 = reader.GetString(reader.GetOrdinal("Option3")),
                                Option4 = reader.GetString(reader.GetOrdinal("Option4")),
                                CorrectOption = reader.GetInt32(reader.GetOrdinal("CorrectOption")),
                                QuestionDesigner = reader.IsDBNull(reader.GetOrdinal("QuestionDesigner")) ? null : reader.GetString(reader.GetOrdinal("QuestionDesigner")),
                                QuestionYear = reader.IsDBNull(reader.GetOrdinal("QuestionYear")) ? 0 : reader.GetInt32(reader.GetOrdinal("QuestionYear")),
                                DifficultyLevelId = reader.GetInt32(reader.GetOrdinal("DifficultyLevelId"))
                            };

                            q.DifficultyLevel = new DifficultyLevel
                            {
                                Id = q.DifficultyLevelId,
                                Name = reader.GetString(reader.GetOrdinal("DifficultyLevelName")),
                                NameEn = reader.GetString(reader.GetOrdinal("DifficultyLevelNameEn"))
                            };
                            
                            q.IsLiked = !reader.IsDBNull(reader.GetOrdinal("IsLiked")) && reader.GetBoolean(reader.GetOrdinal("IsLiked"));

                            if (!reader.IsDBNull(reader.GetOrdinal("DetailedAnswerId")))
                            {
                                var da = new DetailedAnswer
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("DetailedAnswerId")),
                                    QuestionId = reader.GetInt32(reader.GetOrdinal("DetailedAnswerQuestionId")),
                                    AnswerText = reader.GetString(reader.GetOrdinal("AnswerText")),
                                    AnswerAuthor = reader.IsDBNull(reader.GetOrdinal("AnswerAuthor")) ? null : reader.GetString(reader.GetOrdinal("AnswerAuthor")),
                                    AnswerYear = reader.IsDBNull(reader.GetOrdinal("AnswerYear")) ? 0 : reader.GetInt32(reader.GetOrdinal("AnswerYear"))
                                };
                                
                                da.IsLiked = !reader.IsDBNull(reader.GetOrdinal("DetailedAnswerIsLiked")) && reader.GetBoolean(reader.GetOrdinal("DetailedAnswerIsLiked"));
                                q.DetailedAnswer = da;
                            }

                            questionsMap[q.Id] = q;
                        }

                        // 2. Read Content Images
                        if (await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var image = new ContentImage
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                    ImageUrl = reader.GetString(reader.GetOrdinal("ImageUrl")),
                                    DisplayOrder = reader.GetInt32(reader.GetOrdinal("DisplayOrder")),
                                    AltText = reader.IsDBNull(reader.GetOrdinal("AltText")) ? null : reader.GetString(reader.GetOrdinal("AltText")),
                                    EntityTypeId = reader.GetInt32(reader.GetOrdinal("EntityTypeId")),
                                    EntityId = reader.GetInt32(reader.GetOrdinal("EntityId"))
                                };

                                if (image.EntityTypeId == 1 && questionsMap.TryGetValue(image.EntityId, out var q))
                                {
                                    q.QuestionImages.Add(image);
                                }
                                else if (image.EntityTypeId == 2)
                                {
                                    // Find question containing this answer
                                    // Optimized: Use a separate map for AnswerId -> DetailedAnswer if needed
                                    // Or loop:
                                    foreach (var quest in questionsMap.Values)
                                    {
                                        if (quest.DetailedAnswer != null && quest.DetailedAnswer.Id == image.EntityId)
                                        {
                                            quest.DetailedAnswer.AnswerImages.Add(image);
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return questionsMap.Values;
        }

        public async Task<Question> GetQuestionByIdAsync(int id, int? currentUserId = null)
        {
            Question question = null;
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetQuestionById";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var param = command.CreateParameter();
                    param.ParameterName = "@QuestionId";
                    param.Value = id;
                    command.Parameters.Add(param);
                    
                    var userParam = command.CreateParameter();
                    userParam.ParameterName = "@CurrentUserId";
                    userParam.Value = currentUserId ?? (object)DBNull.Value;
                    command.Parameters.Add(userParam);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // 1. Read Question
                        if (await reader.ReadAsync())
                        {
                            question = new Question
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                TopicItemId = reader.GetInt32(reader.GetOrdinal("TopicItemId")),
                                QuestionText = reader.GetString(reader.GetOrdinal("QuestionText")),
                                Option1 = reader.GetString(reader.GetOrdinal("Option1")),
                                Option2 = reader.GetString(reader.GetOrdinal("Option2")),
                                Option3 = reader.GetString(reader.GetOrdinal("Option3")),
                                Option4 = reader.GetString(reader.GetOrdinal("Option4")),
                                CorrectOption = reader.GetInt32(reader.GetOrdinal("CorrectOption")),
                                QuestionDesigner = reader.IsDBNull(reader.GetOrdinal("QuestionDesigner")) ? null : reader.GetString(reader.GetOrdinal("QuestionDesigner")),
                                QuestionYear = reader.IsDBNull(reader.GetOrdinal("QuestionYear")) ? 0 : reader.GetInt32(reader.GetOrdinal("QuestionYear")),
                                DifficultyLevelId = reader.GetInt32(reader.GetOrdinal("DifficultyLevelId"))
                            };

                            question.DifficultyLevel = new DifficultyLevel { Id = question.DifficultyLevelId, Name = reader.GetString(reader.GetOrdinal("DifficultyLevelName")), NameEn = reader.GetString(reader.GetOrdinal("DifficultyLevelNameEn")) };
                            
                            question.IsLiked = !reader.IsDBNull(reader.GetOrdinal("IsLiked")) && reader.GetBoolean(reader.GetOrdinal("IsLiked"));

                            if (!reader.IsDBNull(reader.GetOrdinal("DetailedAnswerId")))
                            {
                                var da = new DetailedAnswer { Id = reader.GetInt32(reader.GetOrdinal("DetailedAnswerId")), QuestionId = reader.GetInt32(reader.GetOrdinal("DetailedAnswerQuestionId")), AnswerText = reader.GetString(reader.GetOrdinal("AnswerText")), AnswerAuthor = reader.IsDBNull(reader.GetOrdinal("AnswerAuthor")) ? null : reader.GetString(reader.GetOrdinal("AnswerAuthor")), AnswerYear = reader.IsDBNull(reader.GetOrdinal("AnswerYear")) ? 0 : reader.GetInt32(reader.GetOrdinal("AnswerYear")) };
                                da.IsLiked = !reader.IsDBNull(reader.GetOrdinal("DetailedAnswerIsLiked")) && reader.GetBoolean(reader.GetOrdinal("DetailedAnswerIsLiked"));
                                question.DetailedAnswer = da;
                            }
                        }

                        // 2. Read Content Images
                        if (question != null && await reader.NextResultAsync())
                        {
                            while (await reader.ReadAsync())
                            {
                                var image = new ContentImage
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                    ImageUrl = reader.GetString(reader.GetOrdinal("ImageUrl")),
                                    DisplayOrder = reader.GetInt32(reader.GetOrdinal("DisplayOrder")),
                                    AltText = reader.IsDBNull(reader.GetOrdinal("AltText")) ? null : reader.GetString(reader.GetOrdinal("AltText")),
                                    EntityTypeId = reader.GetInt32(reader.GetOrdinal("EntityTypeId")),
                                    EntityId = reader.GetInt32(reader.GetOrdinal("EntityId"))
                                };

                                if (image.EntityTypeId == 1 && image.EntityId == question.Id)
                                {
                                    question.QuestionImages.Add(image);
                                }
                                else if (image.EntityTypeId == 2 && question.DetailedAnswer != null && image.EntityId == question.DetailedAnswer.Id)
                                {
                                    question.DetailedAnswer.AnswerImages.Add(image);
                                }
                            }
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return question;
        }
    }
}
