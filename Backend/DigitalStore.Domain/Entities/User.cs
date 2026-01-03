using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class User : BaseEntity
    {
        public required string PhoneNumber { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Grade { get; set; } // e.g., "Grade 6", "Math Exam"
        public string? ProfilePicture { get; set; } // Base64 encoded image
        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiryTime { get; set; }
    }
}
