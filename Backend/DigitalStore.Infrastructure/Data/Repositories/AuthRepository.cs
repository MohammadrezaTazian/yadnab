using System;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace DigitalStore.Infrastructure.Data.Repositories
{
    public class AuthRepository : IAuthRepository
    {
        private readonly ApplicationDbContext _context;

        public AuthRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<User?> GetUserByPhoneNumberAsync(string phoneNumber)
        {
            var param = new SqlParameter("@PhoneNumber", phoneNumber);
            var users = await _context.Users
                .FromSqlRaw("EXEC sp_GetUserByPhoneNumber @PhoneNumber", param)
                .ToListAsync();
            
            return users.FirstOrDefault();
        }

        public async Task<User?> CreateUserAsync(User user)
        {
            var phoneParam = new SqlParameter("@PhoneNumber", user.PhoneNumber);
            var users = await _context.Users
                .FromSqlRaw("EXEC sp_CreateUser @PhoneNumber", phoneParam)
                .ToListAsync();
            return users.FirstOrDefault();
        }

        public async Task UpdateUserAsync(User user)
        {
            var idParam = new SqlParameter("@Id", user.Id);
            var firstParam = new SqlParameter("@FirstName", (object?)user.FirstName ?? DBNull.Value);
            var lastParam = new SqlParameter("@LastName", (object?)user.LastName ?? DBNull.Value);
            var levelParam = new SqlParameter("@EducationalLevelId", (object?)user.EducationalLevelId ?? DBNull.Value);
            var refreshParam = new SqlParameter("@RefreshToken", (object?)user.RefreshToken ?? DBNull.Value);
            var expiryParam = new SqlParameter("@RefreshTokenExpiryTime", (object?)user.RefreshTokenExpiryTime ?? DBNull.Value);

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC sp_UpdateUser @Id, @FirstName, @LastName, @EducationalLevelId, @RefreshToken, @RefreshTokenExpiryTime",
                idParam, firstParam, lastParam, levelParam, refreshParam, expiryParam);
        }

        public async Task<User?> GetUserByRefreshTokenAsync(string refreshToken)
        {
            var param = new SqlParameter("@RefreshToken", refreshToken);
            var users = await _context.Users
                .FromSqlRaw("EXEC sp_GetUserByRefreshToken @RefreshToken", param)
                .ToListAsync();
            return users.FirstOrDefault();
        }

        public async Task<User?> UpdateProfilePictureAsync(int userId, string base64Image)
        {
            var userIdParam = new SqlParameter("@UserId", userId);
            var pictureParam = new SqlParameter("@ProfilePicture", (object)base64Image ?? DBNull.Value);
            
            var users = await _context.Users
                .FromSqlRaw("EXEC sp_UpdateProfilePicture @UserId, @ProfilePicture", userIdParam, pictureParam)
                .ToListAsync();
            
            return users.FirstOrDefault();
        }
    }
}
