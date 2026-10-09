using System.Text;
using DigitalStore.Application.Interfaces;
using DigitalStore.Application.Services;
using DigitalStore.Domain.Interfaces;
using DigitalStore.Infrastructure.Data;
using DigitalStore.Infrastructure.Data.Repositories;
using DigitalStore.Infrastructure.Security;
using DigitalStore.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder
    .Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System
            .Text
            .Json
            .JsonNamingPolicy
            .CamelCase;
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddCors(options =>
{
    options.AddPolicy(
        "AllowAll",
        policy =>
        {
            policy
                .WithOrigins(
                    "https://yadnab.ir",
                    "https://www.yadnab.ir",
                    "https://app.yadnab.ir",
                    "http://localhost:5200",
                    "http://localhost:3000",
                    "http://localhost:8080"
                )
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
        }
    );
});

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "DigitalStore API", Version = "v1" });
    c.AddSecurityDefinition(
        "Bearer",
        new OpenApiSecurityScheme
        {
            Description = "JWT Authorization header using the Bearer scheme.",
            Name = "Authorization",
            In = ParameterLocation.Header,
            Type = SecuritySchemeType.ApiKey,
            Scheme = "Bearer",
        }
    );
    c.AddSecurityRequirement(
        new OpenApiSecurityRequirement
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference
                    {
                        Type = ReferenceType.SecurityScheme,
                        Id = "Bearer",
                    },
                },
                new string[] { }
            },
        }
    );
});

// Database Context
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
);

// Dependency Injection
builder.Services.AddScoped<IAuthRepository, AuthRepository>();
builder.Services.AddScoped<IPackageRepository, PackageRepository>();
builder.Services.AddScoped<ISettingsRepository, SettingsRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<ITopicRepository, TopicRepository>();

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IPackageService, PackageService>();
builder.Services.AddScoped<ISettingsService, SettingsService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ITopicService, TopicService>();
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IQuestionRepository, QuestionRepository>();
builder.Services.AddScoped<IQuestionService, QuestionService>();
builder.Services.AddScoped<IEducationContentRepository, EducationContentRepository>();
builder.Services.AddScoped<IEducationContentService, EducationContentService>();
builder.Services.AddScoped<ICommentRepository, CommentRepository>();
builder.Services.AddScoped<ICommentService, CommentService>();
builder.Services.AddScoped<ILikeRepository, LikeRepository>();
builder.Services.AddScoped<ILikeService, LikeService>();
builder.Services.AddScoped<IContentManagementRepository, ContentManagementRepository>();
builder.Services.AddScoped<IContentManagementService, ContentManagementService>();
builder.Services.AddScoped<IFileStorageService, FileStorageService>();

// JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey =
    jwtSettings.GetValue<string>("SecretKey")
    ?? throw new InvalidOperationException("JWT SecretKey is not configured");
var issuer = jwtSettings.GetValue<string>("Issuer");
var expiryInMinutes = jwtSettings.GetValue<int>("ExpiryInMinutes");
Console.WriteLine($"JWT ExpiryInMinutes = {expiryInMinutes}");
var audience = jwtSettings.GetValue<string>("Audience");

builder
    .Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = issuer,
            ValidAudience = audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        };

        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var requestPath = context.HttpContext.Request.Path.Value;

                // Read the session cookie only for the session endpoint.
                if (
                    string.Equals(
                        requestPath,
                        "/api/Auth/session",
                        StringComparison.OrdinalIgnoreCase
                    )
                )
                {
                    context.Token = context.Request.Cookies["yadnab_session"];
                }

                return Task.CompletedTask;
            },
        };
    });

var app = builder.Build();

// Seed grades
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    EducationalLevelSeeder.SeedEducationalLevels(context);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection(); // Disabled for local testing

app.UseCors("AllowAll");

// Configure static files with MIME types
var provider = new Microsoft.AspNetCore.StaticFiles.FileExtensionContentTypeProvider();
provider.Mappings[".svg"] = "image/svg+xml";

app.UseStaticFiles(
    new StaticFileOptions
    {
        ContentTypeProvider = provider,
        OnPrepareResponse = ctx =>
        {
            // CORS headers are handled by the configured CORS middleware.
        },
    }
);

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
