using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;

namespace DigitalStore.Application.Services
{
    public class PackageService : IPackageService
    {
        private readonly IPackageRepository _packageRepository;

        public PackageService(IPackageRepository packageRepository)
        {
            _packageRepository = packageRepository;
        }

        public async Task<IEnumerable<PackageDto>> GetPackagesAsync(string category)
        {
            var packages = await _packageRepository.GetPackagesByCategoryAsync(category);
            return packages.Select(p => new PackageDto
            {
                Id = p.Id,
                Title = p.Title,
                Description = p.Description ?? string.Empty,
                Category = p.Category ?? string.Empty,
                ImageUrl = p.ImageUrl ?? string.Empty,
                Price = p.Price
            });
        }

        public async Task<IEnumerable<PackageDto>> GetAllPackagesAsync()
        {
            var packages = await _packageRepository.GetAllPackagesAsync();
            return packages.Select(p => new PackageDto
            {
                Id = p.Id,
                Title = p.Title,
                Description = p.Description ?? string.Empty,
                Category = p.Category ?? string.Empty,
                ImageUrl = p.ImageUrl ?? string.Empty,
                Price = p.Price
            });
        }
    }
}
