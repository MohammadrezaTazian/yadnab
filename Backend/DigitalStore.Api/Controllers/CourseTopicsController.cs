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

        [HttpGet("{packageId:int}")]
        public async Task<IActionResult> GetTopicsByPackage(int packageId)
        {
            var topics = await _courseTopicService.GetTopicsByPackageAsync(packageId);
            
            if (topics == null)
            {
                return NotFound(new { message = $"No topics found for package ID: {packageId}" });
            }

            return Ok(topics);
        }
    }
}
