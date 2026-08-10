using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class TopicRepository : ITopicRepository
    {
        private readonly ApplicationDbContext _context;

        public TopicRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Topic>> GetTopicsByPackageAsync(int packageId)
        {
            var topics = new List<Topic>();
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetTopicsByPackage";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var param = command.CreateParameter();
                    param.ParameterName = "@PackageId";
                    param.DbType = DbType.Int32;
                    param.Value = packageId;
                    command.Parameters.Add(param);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            topics.Add(new Topic
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                ParentId = reader.IsDBNull(reader.GetOrdinal("ParentId")) ? (int?)null : reader.GetInt32(reader.GetOrdinal("ParentId")),
                                Title = reader.GetString(reader.GetOrdinal("Title")),
                                ImageUrl = reader.IsDBNull(reader.GetOrdinal("ImageUrl")) ? null : reader.GetString(reader.GetOrdinal("ImageUrl"))
                            });
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return topics;
        }

        public async Task<IEnumerable<Topic>> GetAllTopicsAsync()
        {
            return await _context.Topics.ToListAsync();
        }

        public async Task<Topic?> GetByIdAsync(int id)
        {
            return await _context.Topics.FindAsync(id);
        }
    }
}
