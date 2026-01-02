using DigitalStore.Domain.Entities;
using DigitalStore.Infrastructure.Data;
using System.Linq;

namespace DigitalStore.Infrastructure.Data
{
    public static class GradeSeeder
    {
        public static void SeedGrades(ApplicationDbContext context)
        {
            if (!context.Grades.Any())
            {
                var grades = new[]
                {
                    new Grade { Name = "پایه اول" },
                    new Grade { Name = "پایه دوم" },
                    new Grade { Name = "پایه سوم" },
                    new Grade { Name = "پایه چهارم" },
                    new Grade { Name = "پایه پنجم" },
                    new Grade { Name = "پایه ششم" },
                    new Grade { Name = "پایه هفتم" },
                    new Grade { Name = "پایه هشتم" },
                    new Grade { Name = "پایه نهم" },
                    new Grade { Name = "پایه دهم" },
                    new Grade { Name = "پایه یازدهم" },
                    new Grade { Name = "پایه دوازدهم" }
                };

                context.Grades.AddRange(grades);
                context.SaveChanges();
            }
        }
    }
}
