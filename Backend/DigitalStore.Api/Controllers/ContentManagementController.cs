using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ContentManagementController : ControllerBase
    {
        private readonly IContentManagementService _service;
        private readonly IWebHostEnvironment _env;

        public ContentManagementController(IContentManagementService service, IWebHostEnvironment env)
        {
            _service = service;
            _env = env;
        }

        [HttpGet("search")]
        [Authorize] 
        public async Task<IActionResult> Search([FromQuery] int entityTypeId, [FromQuery] string? searchText)
        {
            var results = await _service.SearchEntitiesAsync(entityTypeId, searchText);
            return Ok(results);
        }

        [HttpPost("upload")]
        [Authorize]
        public async Task<IActionResult> UploadImage([FromForm] UploadContentImageDto uploadDto)
        {
            if (uploadDto.ImageFile == null)
                return BadRequest("No image file provided.");

            var result = await _service.UploadImageAsync(uploadDto, _env.WebRootPath);
            
            if (result == null)
                return StatusCode(500, "Failed to upload image.");

            return Ok(result);
        }
    }
}
