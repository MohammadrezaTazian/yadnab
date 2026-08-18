using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace DigitalStore.Application.Interfaces
{
    public interface IFileStorageService
    {
        Task<string> SaveFileAsync(IFormFile file, string subFolder);
        Task<bool> DeleteFileAsync(string relativePath);
        bool IsValidImageFile(IFormFile file);
    }
}
