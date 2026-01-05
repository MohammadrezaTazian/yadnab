using DigitalStore.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;

namespace DigitalStore.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<Setting> Settings { get; set; }
        public DbSet<Grade> Grades { get; set; }
        public DbSet<CourseTopic> CourseTopics { get; set; } // Ensure CourseTopics is here
        public DbSet<TopicItem> TopicItems { get; set; }
        public DbSet<DifficultyLevel> DifficultyLevels { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<DetailedAnswer> DetailedAnswers { get; set; }
        public DbSet<EducationContent> EducationContents { get; set; }
        public DbSet<ContentImage> ContentImages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // JSON conversion for CourseTopic.Topics removed as it is now normalized
            // Note: Course topics data will be seeded via SQL scripts
            // See: Backend/DigitalStore.Database/MasterDatabaseSetup.sql
        }
    }
}
