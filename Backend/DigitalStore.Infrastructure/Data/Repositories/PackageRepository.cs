using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class PackageRepository : IPackageRepository
    {
        private readonly ApplicationDbContext _context;

        public PackageRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Package>> GetAllPackagesAsync()
        {
            return await _context.Packages
                .FromSqlRaw("EXEC sp_GetAllPackages")
                .ToListAsync();
        }

        public async Task<IEnumerable<Package>> GetPackagesByCategoryAsync(string category)
        {
            var param = new SqlParameter("@Category", category);
            return await _context.Packages
                .FromSqlRaw("EXEC sp_GetPackagesByCategory @Category", param)
                .ToListAsync();
        }
    }
}
