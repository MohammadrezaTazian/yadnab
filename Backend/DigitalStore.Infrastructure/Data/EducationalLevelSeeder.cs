using DigitalStore.Domain.Entities;
using System.Linq;

namespace DigitalStore.Infrastructure.Data
{
    public static class EducationalLevelSeeder
    {
        public static void SeedEducationalLevels(ApplicationDbContext context)
        {
            if (!context.EducationalLevels.Any())
            {
                var levels = new[]
                {
                    new EducationalLevel { Name = "پایه اول" },
                    new EducationalLevel { Name = "پایه دوم" },
                    new EducationalLevel { Name = "پایه سوم" },
                    new EducationalLevel { Name = "پایه چهارم" },
                    new EducationalLevel { Name = "پایه پنجم" },
                    new EducationalLevel { Name = "پایه ششم" },
                    new EducationalLevel { Name = "پایه هفتم" },
                    new EducationalLevel { Name = "پایه هشتم" },
                    new EducationalLevel { Name = "پایه نهم" },
                    new EducationalLevel { Name = "پایه دهم" },
                    new EducationalLevel { Name = "پایه یازدهم" },
                    new EducationalLevel { Name = "پایه دوازدهم" }
                };

                context.EducationalLevels.AddRange(levels);
                context.SaveChanges();
            }
        }
    }
}
