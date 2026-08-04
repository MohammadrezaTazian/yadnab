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

        public async Task<CourseTopic?> GetTopicsByPackageAsync(int packageId)
        {
            CourseTopic? courseTopic = null;
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetCourseTopicsByPackage";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var param = command.CreateParameter();
                    param.ParameterName = "@PackageId";
                    param.DbType = DbType.Int32;
                    param.Value = packageId;
                    command.Parameters.Add(param);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        var topicItems = new List<TopicItem>();
                        int ctId = 0;
                        int ctPackageId = 0;
                        string? ctTitle = null;

                        while (await reader.ReadAsync())
                        {
                            if (ctId == 0)
                            {
                                ctId = reader.GetInt32(reader.GetOrdinal("CourseTopicId"));
                                ctPackageId = reader.GetInt32(reader.GetOrdinal("PackageId"));
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
                                PackageId = ctPackageId,
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
    }
}
