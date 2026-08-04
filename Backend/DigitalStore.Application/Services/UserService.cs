using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Interfaces;

namespace DigitalStore.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IAuthRepository _authRepository;

        public UserService(IUserRepository userRepository, IAuthRepository authRepository)
        {
            _userRepository = userRepository;
            _authRepository = authRepository;
        }

        public async Task<UserDto> GetProfileAsync(int userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                throw new System.Exception("User not found");
            }

            return new UserDto
            {
                Id = user.Id,
                PhoneNumber = user.PhoneNumber,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                EducationalLevelId = user.EducationalLevelId,
                EducationalLevelName = user.EducationalLevel?.Name,
                ProfilePicture = user.ProfilePicture,
                AccessToken = string.Empty, // Not needed for profile retrieval
                RefreshToken = string.Empty
            };
        }

        public async Task<UserDto> UpdateProfileAsync(int userId, UpdateProfileDto updateDto)
        {
            var user = await _userRepository.GetByIdAsync(userId);
            if (user == null)
            {
                throw new System.Exception("User not found");
            }

            // Update user properties
            if (updateDto.FirstName != null)
                user.FirstName = updateDto.FirstName;
            
            if (updateDto.LastName != null)
                user.LastName = updateDto.LastName;
            
            if (updateDto.Email != null)
                user.Email = updateDto.Email;
            
            if (updateDto.EducationalLevelId != null)
                user.EducationalLevelId = updateDto.EducationalLevelId;

            await _userRepository.UpdateAsync(user);

            // Re-fetch user to include newly associated EducationalLevel navigation info
            user = await _userRepository.GetByIdAsync(userId) ?? user;

            return new UserDto
            {
                Id = user.Id,
                PhoneNumber = user.PhoneNumber,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                EducationalLevelId = user.EducationalLevelId,
                EducationalLevelName = user.EducationalLevel?.Name,
                ProfilePicture = user.ProfilePicture,
                AccessToken = string.Empty,
                RefreshToken = string.Empty
            };
        }

        public async Task<IEnumerable<EducationalLevelDto>> GetEducationalLevelsAsync()
        {
            var levels = await _userRepository.GetEducationalLevelsAsync();

            return levels.Select(l => new EducationalLevelDto
            {
                Id = l.Id,
                Name = l.Name
            }).ToList();
        }

        public async Task<UserDto> UpdateProfilePictureAsync(int userId, string base64Image)
        {
            var updatedUser = await _authRepository.UpdateProfilePictureAsync(userId, base64Image);
            
            if (updatedUser == null)
            {
                throw new System.Exception("Failed to update profile picture");
            }

            // Fetch complete user profile with navigation property
            var user = await _userRepository.GetByIdAsync(userId) ?? updatedUser;

            return new UserDto
            {
                Id = user.Id,
                PhoneNumber = user.PhoneNumber,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                EducationalLevelId = user.EducationalLevelId,
                EducationalLevelName = user.EducationalLevel?.Name,
                ProfilePicture = user.ProfilePicture,
                AccessToken = string.Empty,
                RefreshToken = string.Empty
            };
        }
    }
}
