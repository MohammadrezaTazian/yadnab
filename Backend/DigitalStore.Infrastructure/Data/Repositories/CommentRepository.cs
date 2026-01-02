using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Data;
using System.Linq; // Added for Select
using System; // Added for DBNull and conversions

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class CommentRepository : ICommentRepository
    {
        private readonly ApplicationDbContext _context;

        public CommentRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Comment> AddAsync(Comment comment)
        {
            var userIdParam = new SqlParameter("@UserId", comment.UserId);
            var targetIdParam = new SqlParameter("@TargetId", comment.TargetId);
            var targetTypeParam = new SqlParameter("@TargetType", comment.TargetType);
            var parentIdParam = new SqlParameter("@ParentCommentId", comment.ParentCommentId ?? (object)DBNull.Value);
            var contentParam = new SqlParameter("@Content", comment.Content);

            var connection = _context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open) await connection.OpenAsync();

            using (var command = connection.CreateCommand())
            {
                command.CommandText = "sp_AddComment";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(userIdParam);
                command.Parameters.Add(targetIdParam);
                command.Parameters.Add(targetTypeParam);
                command.Parameters.Add(parentIdParam);
                command.Parameters.Add(contentParam);

                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        return new Comment
                        {
                            Id = reader.GetInt64(reader.GetOrdinal("Id")),
                            UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                            TargetId = reader.GetInt32(reader.GetOrdinal("TargetId")),
                            TargetType = reader.GetByte(reader.GetOrdinal("TargetType")),
                            ParentCommentId = reader.IsDBNull(reader.GetOrdinal("ParentCommentId")) ? null : reader.GetInt64(reader.GetOrdinal("ParentCommentId")),
                            Content = reader.GetString(reader.GetOrdinal("Content")),
                            LikeCount = reader.GetInt32(reader.GetOrdinal("LikeCount")),
                            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
                        };
                    }
                }
            }
            return comment;
        }

        public async Task<IEnumerable<Comment>> GetByTargetIdAsync(int targetId, byte targetType, int? currentUserId = null)
        {
            var comments = new List<Comment>();
            var connection = _context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open) await connection.OpenAsync();

            using (var command = connection.CreateCommand())
            {
                command.CommandText = "sp_GetCommentsByTargetId";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@TargetId", targetId));
                command.Parameters.Add(new SqlParameter("@TargetType", targetType));
                command.Parameters.Add(new SqlParameter("@CurrentUserId", currentUserId ?? (object)DBNull.Value));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        comments.Add(new Comment
                        {
                            Id = reader.GetInt64(reader.GetOrdinal("Id")),
                            UserId = reader.GetInt32(reader.GetOrdinal("UserId")),
                            TargetId = reader.GetInt32(reader.GetOrdinal("TargetId")),
                            TargetType = reader.GetByte(reader.GetOrdinal("TargetType")),
                            ParentCommentId = reader.IsDBNull(reader.GetOrdinal("ParentCommentId")) ? null : reader.GetInt64(reader.GetOrdinal("ParentCommentId")),
                            Content = reader.GetString(reader.GetOrdinal("Content")),
                            LikeCount = reader.GetInt32(reader.GetOrdinal("LikeCount")),
                            CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                            UserDisplayName = reader.IsDBNull(reader.GetOrdinal("UserDisplayName")) ? "کاربر ناشناس" : reader.GetString(reader.GetOrdinal("UserDisplayName")),
                            UserAvatar = reader.IsDBNull(reader.GetOrdinal("UserAvatar")) ? null : reader.GetString(reader.GetOrdinal("UserAvatar")),
                            IsLikedByCurrentUser = !reader.IsDBNull(reader.GetOrdinal("IsLikedByCurrentUser")) && reader.GetBoolean(reader.GetOrdinal("IsLikedByCurrentUser"))
                        });
                    }
                }
            }
            return comments;
        }

        public async Task DeleteAsync(long id, int userId)
        {
            var connection = _context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open) await connection.OpenAsync();

            using (var command = connection.CreateCommand())
            {
                command.CommandText = "sp_DeleteComment";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@Id", id));
                command.Parameters.Add(new SqlParameter("@UserId", userId));
                await command.ExecuteNonQueryAsync();
            }
        }
    }
}
