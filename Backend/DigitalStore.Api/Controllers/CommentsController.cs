using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommentsController : ControllerBase
    {
        private readonly ICommentService _service;

        public CommentsController(ICommentService service)
        {
            _service = service;
        }

        private int GetUserId()
        {
            // Assuming "sub" or "nameid" or a custom claim "UserId" holds the int ID. 
            // Validating based on typical JWT setup.
            // If strictly using "sub" as string, we might need conversion or look for a specific claim.
            // Let's assume standard NameIdentifier has the ID.
            var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
            if (claim != null && int.TryParse(claim.Value, out int userId))
            {
                return userId;
            }
            // Fallback or throw. For authorized endpoints this should be present.
            return 0;
        }

        [HttpGet("{targetType}/{targetId}")]
        public async Task<IActionResult> GetComments(byte targetType, int targetId)
        {
            int? userId = null;
            try 
            {
               // Helper might return 0 if not found, but we want null if not logged in (though GetUserId returns 0).
               // Let's modify logic: check claim directly or use helper if fine.
               var uid = GetUserId();
               if (uid != 0) userId = uid;
            }
            catch {}

            var comments = await _service.GetCommentsByTargetIdAsync(targetId, targetType, userId);
            return Ok(comments);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> AddComment([FromBody] CreateCommentDto dto)
        {
            int userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var result = await _service.AddCommentAsync(userId, dto);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteComment(long id)
        {
            int userId = GetUserId();
            if (userId == 0) return Unauthorized();

            await _service.DeleteCommentAsync(id, userId);
            return NoContent();
        }
    }
}
