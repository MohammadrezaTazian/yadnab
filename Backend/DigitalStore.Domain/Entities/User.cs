using System;
using DigitalStore.Domain.Common;

namespace DigitalStore.Domain.Entities
{
    public class User : BaseEntity
    {
        public required string PhoneNumber { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public int? EducationalLevelId { get; set; }
        public EducationalLevel? EducationalLevel { get; set; }
        public string? ProfilePicture { get; set; } // Base64 encoded image
        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiryTime { get; set; }
    }
}
