using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class QuestionsController : ControllerBase
    {
        private readonly IQuestionService _questionService;

        public QuestionsController(IQuestionService questionService)
        {
            _questionService = questionService;
        }

        [HttpGet("topic/{topicItemId}")]
        public async Task<IActionResult> GetQuestionsByTopicId(int topicItemId)
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
            var questions = await _questionService.GetQuestionsByTopicIdAsync(topicItemId, userId);
            return Ok(questions);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetQuestionById(int id)
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
            var question = await _questionService.GetQuestionByIdAsync(id, userId);
            if (question == null) return NotFound();
            return Ok(question);
        }
    }
}
