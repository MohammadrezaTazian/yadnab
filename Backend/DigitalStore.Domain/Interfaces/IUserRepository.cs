using System.Collections.Generic;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;

namespace DigitalStore.Domain.Interfaces
{
    public interface IUserRepository
    {
        Task<User?> GetByIdAsync(int id);
        Task UpdateAsync(User user);
        Task<IEnumerable<Grade>> GetGradesAsync();
    }
}
