using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class ContentManagementRepository : IContentManagementRepository
    {
        private readonly ApplicationDbContext _context;

        public ContentManagementRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<EntitySearchResult>> SearchEntitiesAsync(int entityTypeId, string? searchText)
        {
            var typeParam = new SqlParameter("@EntityTypeId", entityTypeId);
            var searchParam = new SqlParameter("@SearchText", (object?)searchText ?? DBNull.Value);

            // Using FromSqlRaw to map to keyless entity EntitySearchResult
            // Ensure EntitySearchResult is registered in DbContext as keyless if needed or simply use raw mapping
            // EF Core requires keyless entities to be defined in OnModelCreating to use FromSqlRaw on DbSet
            // Alternatively, we can use _context.Database.SqlQuery if available in this version, or map manually.
            // For now, I'll rely on a Set<EntitySearchResult>() matching the result. 
            // I need to add DbSet<EntitySearchResult> to AppDbContext or use Set<>()?
            
            // To be safe without modifying AppDbContext too much, I will assume I can use Set<EntitySearchResult>().FromSqlRaw
            // BUT EntitySearchResult must be registered as Keyless Entity.
            
            // Wait, to avoid modifying AppDbContext (which might be complex/risky to parse), 
            // I can use `_context.Set<EntitySearchResult>()` IF I modify DbContext.
            // If I can't modify DbContext easily, I might use ADO.NET style for this specific query inside the repo.
            // For simplicity and robustness given previous "MainScript.sql" focus, I will use ADO.NET here to avoid EF mapping issues if I don't see AppDbContext.
            
            // Let's stick to ADO.NET for the search to ensure it works without DbContext changes.
            var results = new List<EntitySearchResult>();
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == System.Data.ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "EXEC sp_SearchEntities @EntityTypeId, @SearchText";
                    command.Parameters.Add(typeParam);
                    command.Parameters.Add(searchParam);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            results.Add(new EntitySearchResult
                            {
                                Id = reader.GetInt32(0),
                                Title = reader.IsDBNull(1) ? "" : reader.GetString(1),
                                ExistingImageUrl = reader.IsDBNull(2) ? null : reader.GetString(2)
                            });
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return results;
        }

        public async Task<ContentImage?> AddContentImageAsync(int entityTypeId, int entityId, string imageUrl, string? altText, int displayOrder)
        {
            var typeParam = new SqlParameter("@EntityTypeId", entityTypeId);
            var idParam = new SqlParameter("@EntityId", entityId);
            var urlParam = new SqlParameter("@ImageUrl", imageUrl);
            var altParam = new SqlParameter("@AltText", (object?)altText ?? DBNull.Value);
            var orderParam = new SqlParameter("@DisplayOrder", displayOrder);

            ContentImage? newImage = null;
            var connection = _context.Database.GetDbConnection();
            bool wasOpen = connection.State == System.Data.ConnectionState.Open;
            if (!wasOpen) await connection.OpenAsync();

            try
            {
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "EXEC sp_AddContentImage @EntityTypeId, @EntityId, @ImageUrl, @AltText, @DisplayOrder";
                    command.Parameters.Add(typeParam);
                    command.Parameters.Add(idParam);
                    command.Parameters.Add(urlParam);
                    command.Parameters.Add(altParam);
                    command.Parameters.Add(orderParam);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            newImage = new ContentImage
                            {
                                Id = reader.GetInt32(reader.GetOrdinal("Id")),
                                ImageUrl = reader.GetString(reader.GetOrdinal("ImageUrl")),
                                DisplayOrder = reader.GetInt32(reader.GetOrdinal("DisplayOrder")),
                                AltText = reader.IsDBNull(reader.GetOrdinal("AltText")) ? null : reader.GetString(reader.GetOrdinal("AltText")),
                                EntityTypeId = reader.GetInt32(reader.GetOrdinal("EntityTypeId")),
                                EntityId = reader.GetInt32(reader.GetOrdinal("EntityId")),
                                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                            };
                        }
                    }
                }
            }
            finally
            {
                if (!wasOpen) await connection.CloseAsync();
            }

            return newImage;
        }
    }
}
