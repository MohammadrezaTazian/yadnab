using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;

namespace DigitalStore.Domain.Interfaces
{
    public interface IPackageRepository
    {
        Task<IEnumerable<Package>> GetPackagesByCategoryAsync(string category);
        Task<IEnumerable<Package>> GetAllPackagesAsync();
    }
}
