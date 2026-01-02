using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class EducationContentRepository : IEducationContentRepository
    {
        private readonly ApplicationDbContext _context;

        public EducationContentRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<EducationContent>> GetByTopicItemIdAsync(int topicItemId, int? currentUserId = null)
        {
            var contentsMap = new Dictionary<int, EducationContent>();
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetEducationContentsByTopicId";
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
                        // 1. Read Contents
                        while (await reader.ReadAsync())
                        {
                            var ec = MapReaderToEntity(reader);
                            contentsMap[ec.Id] = ec;
                        }

                        // 2. Read Images
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

                                if (contentsMap.TryGetValue(image.EntityId, out var ec))
                                {
                                    ec.Images.Add(image);
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

            return contentsMap.Values;
        }

        public async Task<EducationContent> GetByIdAsync(int id, int? currentUserId = null)
        {
            EducationContent content = null;
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetEducationContentById";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var param = command.CreateParameter();
                    param.ParameterName = "@Id";
                    param.Value = id;
                    command.Parameters.Add(param);

                    var userParam = command.CreateParameter();
                    userParam.ParameterName = "@CurrentUserId";
                    userParam.Value = currentUserId ?? (object)DBNull.Value;
                    command.Parameters.Add(userParam);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // 1. Read Content
                        if (await reader.ReadAsync())
                        {
                            content = MapReaderToEntity(reader);
                        }

                        // 2. Read Images
                        if (content != null && await reader.NextResultAsync())
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
                                content.Images.Add(image);
                            }
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return content;
        }

        private EducationContent MapReaderToEntity(System.Data.Common.DbDataReader reader)
        {
            return new EducationContent
            {
                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                TopicItemId = reader.GetInt32(reader.GetOrdinal("TopicItemId")),
                Title = reader.GetString(reader.GetOrdinal("Title")),
                ContentText = reader.IsDBNull(reader.GetOrdinal("ContentText")) ? "" : reader.GetString(reader.GetOrdinal("ContentText")),
                MediaUrl = reader.IsDBNull(reader.GetOrdinal("MediaUrl")) ? null : reader.GetString(reader.GetOrdinal("MediaUrl")),
                MediaType = reader.GetString(reader.GetOrdinal("MediaType")),
                TeacherName = reader.IsDBNull(reader.GetOrdinal("TeacherName")) ? null : reader.GetString(reader.GetOrdinal("TeacherName")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                IsLiked = !reader.IsDBNull(reader.GetOrdinal("IsLiked")) && reader.GetBoolean(reader.GetOrdinal("IsLiked"))
            };
        }
    }
}
