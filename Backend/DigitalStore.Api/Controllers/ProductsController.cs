using System.Threading.Tasks;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DigitalStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProductsController : ControllerBase
    {
        private readonly IProductService _productService;

        public ProductsController(IProductService productService)
        {
            _productService = productService;
        }

        [HttpGet]
        public async Task<IActionResult> GetProducts([FromQuery] string category = null)
        {
            if (string.IsNullOrEmpty(category))
            {
                var allProducts = await _productService.GetAllProductsAsync();
                return Ok(allProducts);
            }
            
            var products = await _productService.GetProductsAsync(category);
            return Ok(products);
        }
    }
}
