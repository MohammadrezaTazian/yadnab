using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DigitalStore.Application.Services
{
    public class CommentService : ICommentService
    {
        private readonly ICommentRepository _repository;

        public CommentService(ICommentRepository repository)
        {
            _repository = repository;
        }

        public async Task<CommentDto> AddCommentAsync(int userId, CreateCommentDto dto)
        {
            var comment = new Comment
            {
                UserId = userId,
                TargetId = dto.TargetId,
                TargetType = dto.TargetType,
                ParentCommentId = dto.ParentCommentId,
                Content = dto.Content
            };

            var createdComment = await _repository.AddAsync(comment);

            // Simple mapping for the return value
            return new CommentDto
            {
                Id = createdComment.Id,
                UserId = createdComment.UserId,
                Content = createdComment.Content,
                LikeCount = createdComment.LikeCount,
                CreatedAt = createdComment.CreatedAt.ToString("yyyy-MM-dd HH:mm"),
                Replies = new List<CommentDto>()
                // UserDisplayName/Avatar might be empty here since database doesn't return join on Insert
                // But for UI "Add" functionality, client usually has user info or re-fetches.
            };
        }

        public async Task<IEnumerable<CommentDto>> GetCommentsByTargetIdAsync(int targetId, byte targetType, int? currentUserId = null)
        {
            var allComments = await _repository.GetByTargetIdAsync(targetId, targetType, currentUserId);
            
            // Transform flat list to tree
            var commentDtos = allComments.Select(c => new CommentDto
            {
                Id = c.Id,
                UserId = c.UserId,
                UserDisplayName = c.UserDisplayName,
                UserAvatar = c.UserAvatar,
                Content = c.Content,
                LikeCount = c.LikeCount,
                CreatedAt = c.CreatedAt.ToString("yyyy-MM-dd HH:mm"),
                IsLikedByCurrentUser = c.IsLikedByCurrentUser,
                Replies = new List<CommentDto>()
                // We need to keep ParentId temporarily for building tree, but DTO doesn't strictly need it if structure is nested
            }).ToList();

            var lookup = commentDtos.ToDictionary(c => c.Id);
            var rootComments = new List<CommentDto>();

            // The original list 'allComments' has ParentCommentId.
            // We need to iterate 'allComments' to know relationships.
            foreach (var commentEntity in allComments)
            {
                if (lookup.TryGetValue(commentEntity.Id, out var dto))
                {
                    if (commentEntity.ParentCommentId.HasValue && lookup.TryGetValue(commentEntity.ParentCommentId.Value, out var parentDto))
                    {
                        parentDto.Replies.Add(dto);
                    }
                    else
                    {
                        rootComments.Add(dto);
                    }
                }
            }

            return rootComments;
        }

        public async Task DeleteCommentAsync(long id, int userId)
        {
            await _repository.DeleteAsync(id, userId);
        }
    }
}
