using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Application.Interfaces;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;

namespace DigitalStore.Infrastructure.Services
{
    public class FileStorageService : IFileStorageService
    {
        private readonly IWebHostEnvironment _environment;

        private static readonly Dictionary<string, List<byte[]>> AllowedFileSignatures = new(StringComparer.OrdinalIgnoreCase)
        {
            { ".jpeg", new List<byte[]> { new byte[] { 0xFF, 0xD8, 0xFF } } },
            { ".jpg",  new List<byte[]> { new byte[] { 0xFF, 0xD8, 0xFF } } },
            { ".png",  new List<byte[]> { new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A } } },
            { ".gif",  new List<byte[]> { new byte[] { 0x47, 0x49, 0x46, 0x38 } } },
            { ".webp", new List<byte[]> { new byte[] { 0x52, 0x49, 0x46, 0x46 } } } // 'RIFF'
        };

        private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".webp", ".gif" };
        private static readonly string[] AllowedMimeTypes = { "image/jpeg", "image/png", "image/webp", "image/gif" };
        private const long MaxFileSize = 15 * 1024 * 1024; // 15 MB

        public FileStorageService(IWebHostEnvironment environment)
        {
            _environment = environment;
        }

        public bool IsValidImageFile(IFormFile file)
        {
            if (file == null || file.Length == 0 || file.Length > MaxFileSize)
                return false;

            var ext = Path.GetExtension(file.FileName);
            if (string.IsNullOrEmpty(ext) || !AllowedExtensions.Contains(ext, StringComparer.OrdinalIgnoreCase))
                return false;

            if (!AllowedMimeTypes.Contains(file.ContentType, StringComparer.OrdinalIgnoreCase))
                return false;

            // Magic Bytes Signature Check
            try
            {
                using var reader = new BinaryReader(file.OpenReadStream());
                var signatures = AllowedFileSignatures[ext];
                var headerBytes = reader.ReadBytes(signatures.Max(s => s.Length));

                return signatures.Any(sig => headerBytes.Take(sig.Length).SequenceEqual(sig));
            }
            catch
            {
                return false;
            }
        }

        public async Task<string> SaveFileAsync(IFormFile file, string subFolder)
        {
            if (!IsValidImageFile(file))
                throw new ArgumentException("فایل نامعتبر است یا فرمت آن پشتیبانی نمی‌شود.");

            var webRoot = _environment.WebRootPath;
            if (string.IsNullOrEmpty(webRoot))
            {
                webRoot = Path.Combine(_environment.ContentRootPath, "wwwroot");
            }

            // Sanitize subfolder to prevent Path Traversal
            var cleanSubFolder = subFolder.Replace("..", "").Trim('/', '\\');
            var targetDir = Path.Combine(webRoot, "images", cleanSubFolder);

            if (!Directory.Exists(targetDir))
            {
                Directory.CreateDirectory(targetDir);
            }

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var uniqueFileName = $"{Guid.NewGuid():N}{extension}";
            var fullPath = Path.Combine(targetDir, uniqueFileName);

            using (var stream = new FileStream(fullPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var relativePath = $"/images/{cleanSubFolder.Replace('\\', '/')}/{uniqueFileName}";
            return relativePath;
        }

        public Task<bool> DeleteFileAsync(string relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
                return Task.FromResult(false);

            var webRoot = _environment.WebRootPath;
            if (string.IsNullOrEmpty(webRoot))
            {
                webRoot = Path.Combine(_environment.ContentRootPath, "wwwroot");
            }

            var cleanPath = relativePath.TrimStart('/', '\\').Replace('/', Path.DirectorySeparatorChar);
            var fullPath = Path.Combine(webRoot, cleanPath);

            // Ensure the target is within webRoot to prevent path traversal
            var fullPathResolved = Path.GetFullPath(fullPath);
            var webRootResolved = Path.GetFullPath(webRoot);

            if (!fullPathResolved.StartsWith(webRootResolved, StringComparison.OrdinalIgnoreCase))
                return Task.FromResult(false);

            if (File.Exists(fullPathResolved))
            {
                File.Delete(fullPathResolved);
                return Task.FromResult(true);
            }

            return Task.FromResult(false);
        }
    }
}
