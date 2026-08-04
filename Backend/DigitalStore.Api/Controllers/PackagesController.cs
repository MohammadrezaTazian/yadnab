using System.Threading.Tasks;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PackagesController : ControllerBase
    {
        private readonly IPackageService _packageService;

        public PackagesController(IPackageService packageService)
        {
            _packageService = packageService;
        }

        [HttpGet]
        public async Task<IActionResult> GetPackages([FromQuery] string? category = null)
        {
            if (string.IsNullOrEmpty(category))
            {
                var allPackages = await _packageService.GetAllPackagesAsync();
                return Ok(allPackages);
            }
            
            var packages = await _packageService.GetPackagesAsync(category);
            return Ok(packages);
        }
    }
}
