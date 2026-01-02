using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class CourseTopicsController : ControllerBase
    {
        private readonly ICourseTopicService _courseTopicService;

        public CourseTopicsController(ICourseTopicService courseTopicService)
        {
            _courseTopicService = courseTopicService;
        }

        [HttpGet("{category}")]
        public async Task<IActionResult> GetTopicsByCategory(string category)
        {
            var topics = await _courseTopicService.GetTopicsByCategoryAsync(category);
            
            if (topics == null)
            {
                return NotFound(new { message = $"No topics found for category: {category}" });
            }

            return Ok(topics);
        }
    }
}
