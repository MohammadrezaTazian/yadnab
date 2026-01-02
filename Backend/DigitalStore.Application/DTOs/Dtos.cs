namespace DigitalStore.Application.DTOs
{
    public class LoginRequestDto
    {
        public string PhoneNumber { get; set; }
        public string? Otp { get; set; } // For verification step
    }

    public class UserDto
    {
        public int Id { get; set; }
        public string PhoneNumber { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Grade { get; set; }
        public string? ProfilePicture { get; set; }
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
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
        public string Name { get; set; }
    }

    public class ProductDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Category { get; set; }
        public string ImageUrl { get; set; }
        public decimal Price { get; set; }
    }

    public class SettingsDto
    {
        public string Theme { get; set; }
        public string Language { get; set; }
        public double FontSize { get; set; }
    }

    public class UpdateProfilePictureDto
    {
        public string Base64Image { get; set; }
    }
}
