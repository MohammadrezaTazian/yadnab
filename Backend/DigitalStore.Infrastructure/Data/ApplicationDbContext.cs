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
        public DbSet<Package> Packages { get; set; }
        public DbSet<Setting> Settings { get; set; }
        public DbSet<EducationalLevel> EducationalLevels { get; set; }
        public DbSet<Topic> Topics { get; set; }
        public DbSet<PackageTopic> PackageTopics { get; set; }
        public DbSet<DifficultyLevel> DifficultyLevels { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<DetailedAnswer> DetailedAnswers { get; set; }
        public DbSet<EducationContent> EducationContents { get; set; }
        public DbSet<ContentImage> ContentImages { get; set; }
        public DbSet<EntityType> EntityTypes { get; set; }
        public DbSet<ImageType> ImageTypes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            // JSON conversion for Topic.Children removed as it is now normalized
            // Note: Topics data will be seeded via SQL scripts
            // See: Backend/DigitalStore.Database/MasterDatabaseSetup.sql
        }
    }
}
