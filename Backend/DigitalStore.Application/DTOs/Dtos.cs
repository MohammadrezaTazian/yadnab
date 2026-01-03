namespace DigitalStore.Application.DTOs
{
    public class LoginRequestDto
    {
        public required string PhoneNumber { get; set; }
        public string? Otp { get; set; } // For verification step
    }

    public class UserDto
    {
        public int Id { get; set; }
        public required string PhoneNumber { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Grade { get; set; }
        public string? ProfilePicture { get; set; }
        public required string AccessToken { get; set; }
        public required string RefreshToken { get; set; }
    }

    public class UpdateProfileDto
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Grade { get; set; }
    }

    public class GradeDto
    {
        public int Id { get; set; }
        public required string Name { get; set; }
    }

    public class ProductDto
    {
        public int Id { get; set; }
        public required string Title { get; set; }
        public required string Description { get; set; }
        public required string Category { get; set; }
        public required string ImageUrl { get; set; }
        public decimal Price { get; set; }
    }

    public class SettingsDto
    {
        public required string Theme { get; set; }
        public required string Language { get; set; }
        public double FontSize { get; set; }
    }

    public class UpdateProfilePictureDto
    {
        public required string Base64Image { get; set; }
    }
}
