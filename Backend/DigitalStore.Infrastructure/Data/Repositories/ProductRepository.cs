using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class ProductRepository : IProductRepository
    {
        private readonly ApplicationDbContext _context;

        public ProductRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Product>> GetAllProductsAsync()
        {
            return await _context.Products
                .FromSqlRaw("EXEC sp_GetAllProducts")
                .ToListAsync();
        }

        public async Task<IEnumerable<Product>> GetProductsByCategoryAsync(string category)
        {
            var param = new SqlParameter("@Category", category);
            return await _context.Products
                .FromSqlRaw("EXEC sp_GetProductsByCategory @Category", param)
                .ToListAsync();
        }
    }
}
