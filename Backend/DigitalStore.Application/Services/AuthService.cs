using System;
using System.Threading.Tasks;
using DigitalStore.Application.DTOs;
using DigitalStore.Application.Interfaces;
using DigitalStore.Domain.Entities;
using DigitalStore.Domain.Interfaces;

namespace DigitalStore.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAuthRepository _authRepository;
        private readonly IJwtService _jwtService;

        public AuthService(
            IAuthRepository authRepository, 
            IJwtService jwtService)
        {
            _authRepository = authRepository;
            _jwtService = jwtService;
        }

        public async Task<string> SendOtpAsync(string phoneNumber)
        {
            // Mock OTP generation
            await Task.CompletedTask;
            return "12345";
        }

        public async Task<UserDto> VerifyOtpAsync(string phoneNumber, string otp)
        {
            if (otp != "12345")
            {
                throw new Exception("Invalid OTP");
            }

            var user = await _authRepository.GetUserByPhoneNumberAsync(phoneNumber);
            
            if (user == null)
            {
                user = new User { PhoneNumber = phoneNumber };
                user = await _authRepository.CreateUserAsync(user);
            }

            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.Now.AddDays(7);
            await _authRepository.UpdateUserAsync(user);

            return new UserDto
            {
                Id = user.Id,
                PhoneNumber = user.PhoneNumber,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Grade = user.Grade,
                AccessToken = accessToken,
                RefreshToken = refreshToken
            };
        }

        public async Task<UserDto> RefreshTokenAsync(string refreshToken)
        {
            var user = await _authRepository.GetUserByRefreshTokenAsync(refreshToken);
            if (user == null || user.RefreshTokenExpiryTime <= DateTime.Now)
            {
                throw new Exception("Invalid or expired refresh token");
            }

            var newAccessToken = _jwtService.GenerateAccessToken(user);
            var newRefreshToken = _jwtService.GenerateRefreshToken();

            user.RefreshToken = newRefreshToken;
            await _authRepository.UpdateUserAsync(user);

            return new UserDto
            {
                Id = user.Id,
                PhoneNumber = user.PhoneNumber,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Grade = user.Grade,
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken
            };
        }
    }
}
