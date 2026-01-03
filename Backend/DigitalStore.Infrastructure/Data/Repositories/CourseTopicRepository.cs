using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class CourseTopicRepository : ICourseTopicRepository
    {
        private readonly ApplicationDbContext _context;

        public CourseTopicRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<CourseTopic>> GetAllAsync()
        {
            // For now, using EF Core for simple GetAll, though SP is available
            return await _context.CourseTopics.Include(x => x.TopicItems).ToListAsync();
        }

        public async Task<CourseTopic?> GetTopicsByCategoryAsync(string category)
        {
            CourseTopic? courseTopic = null;
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetCourseTopicsByCategory";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var param = command.CreateParameter();
                    param.ParameterName = "@Category";
                    param.Value = category;
                    command.Parameters.Add(param);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        var topicItems = new List<TopicItem>();
                        int ctId = 0;
                        string ctCategory = "";
                        string? ctTitle = null;

                        while (await reader.ReadAsync())
                        {
                            if (ctId == 0)
                            {
                                ctId = reader.GetInt32(reader.GetOrdinal("CourseTopicId"));
                                ctCategory = reader.GetString(reader.GetOrdinal("Category"));
                                if (!reader.IsDBNull(reader.GetOrdinal("CategoryTitle")))
                                    ctTitle = reader.GetString(reader.GetOrdinal("CategoryTitle"));
                            }

                            if (!reader.IsDBNull(reader.GetOrdinal("TopicItemId")))
                            {
                                topicItems.Add(new TopicItem
                                {
                                    Id = reader.GetInt32(reader.GetOrdinal("TopicItemId")),
                                    CourseTopicId = ctId,
                                    ParentId = reader.IsDBNull(reader.GetOrdinal("ParentId")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("ParentId")),
                                    Title = reader.GetString(reader.GetOrdinal("TopicTitle")),
                                    ImageUrl = reader.IsDBNull(reader.GetOrdinal("TopicImageUrl")) ? null : reader.GetString(reader.GetOrdinal("TopicImageUrl"))
                                });
                            }
                        }

                        if (ctId != 0)
                        {
                            courseTopic = new CourseTopic
                            {
                                Id = ctId,
                                Category = ctCategory,
                                Title = ctTitle,
                                TopicItems = topicItems
                            };
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return courseTopic;
        }

        public async Task<CourseTopic> AddAsync(CourseTopic entity)
        {
             _context.CourseTopics.Add(entity);
             await _context.SaveChangesAsync();
             return entity;
        }

        public async Task UpdateAsync(CourseTopic entity)
        {
            _context.Entry(entity).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _context.CourseTopics.FindAsync(id);
            if (entity != null)
            {
                _context.CourseTopics.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }
    }
}
