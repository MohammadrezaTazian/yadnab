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
    public class LikesController : ControllerBase
    {
        private readonly ILikeService _service;

        public LikesController(ILikeService service)
        {
            _service = service;
        }

        private int GetUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
            if (claim != null && int.TryParse(claim.Value, out int userId))
            {
                return userId;
            }
            return 0;
        }

        [HttpPost("toggle")]
        [Authorize]
        public async Task<IActionResult> ToggleLike([FromBody] ToggleLikeDto dto)
        {
            int userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var isLiked = await _service.ToggleLikeAsync(userId, dto.TargetId, dto.TargetType);
            // Return object for flexibility (e.g. adding new count later)
            return Ok(new { IsLiked = isLiked });
        }
    }
}
