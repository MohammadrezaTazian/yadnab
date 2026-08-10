using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TopicsController : ControllerBase
    {
        private readonly ITopicService _topicService;

        public TopicsController(ITopicService topicService)
        {
            _topicService = topicService;
        }

        [HttpGet("{packageId:int}")]
        public async Task<IActionResult> GetTopicsByPackage(int packageId)
        {
            var topics = await _topicService.GetTopicsByPackageAsync(packageId);
            
            if (topics == null)
            {
                return NotFound(new { message = $"No topics found for package ID: {packageId}" });
            }

            return Ok(topics);
        }
    }
}
