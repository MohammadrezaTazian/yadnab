using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EducationContentsController : ControllerBase
    {
        private readonly IEducationContentService _service;

        public EducationContentsController(IEducationContentService service)
        {
            _service = service;
        }

        [HttpGet("topic/{topicItemId}")]
        public async Task<ActionResult<IEnumerable<EducationContentDto>>> GetByTopicItemId(int topicItemId)
        {
            int? userId = null;
            if (User.Identity != null && User.Identity.IsAuthenticated)
            {
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
                if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int id))
                {
                    userId = id;
                }
            }
            var contents = await _service.GetContentsByTopicItemIdAsync(topicItemId, userId);
            return Ok(contents);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EducationContentDto>> GetById(int id)
        {
            int? userId = null;
            if (User.Identity != null && User.Identity.IsAuthenticated)
            {
                var userIdClaim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
                if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int uid))
                {
                    userId = uid;
                }
            }
            var content = await _service.GetContentByIdAsync(id, userId);
            if (content == null) return NotFound();
            return Ok(content);
        }
    }
}
