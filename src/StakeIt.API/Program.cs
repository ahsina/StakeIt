using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using StakeIt.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

// ========================================
// DATABASE CONFIGURATION
// ========================================

// PostgreSQL Database (you can switch to SQL Server if needed)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? "Host=localhost;Database=stakeit;Username=postgres;Password=postgres";

builder.Services.AddDbContext<StakeItDbContext>(options =>
{
    // Use PostgreSQL
    options.UseNpgsql(connectionString);

    // Or use SQL Server (comment PostgreSQL and uncomment this)
    // options.UseSqlServer(connectionString);

    // Enable detailed errors in development
    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.EnableDetailedErrors();
    }
});

// ========================================
// AUTHENTICATION & JWT
// ========================================

var jwtSecret = builder.Configuration["Jwt:Secret"] ?? "YourSuperSecretKeyThatIsAtLeast32CharactersLong!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "StakeItAPI";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "StakeItApp";

builder.Services.AddAuthentication(options =>
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
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret)),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// ========================================
// CORS CONFIGURATION
// ========================================

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });

    // More restrictive policy for production
    options.AddPolicy("Production", policy =>
    {
        policy.WithOrigins("https://stakeit.app", "https://www.stakeit.app")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// ========================================
// CONTROLLERS & API
// ========================================

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// ========================================
// SWAGGER CONFIGURATION
// ========================================

builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "StakeIt API",
        Version = "v1",
        Description = "API for StakeIt - Motivation app with real money stakes",
        Contact = new Microsoft.OpenApi.Models.OpenApiContact
        {
            Name = "StakeIt Team",
            Email = "contact@stakeit.app"
        }
    });

    // Add JWT Authentication to Swagger
    options.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token.",
        Name = "Authorization",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// ========================================
// SIGNALR (for real-time challenges)
// ========================================

builder.Services.AddSignalR();

// ========================================
// APPLICATION SERVICES
// ========================================

using StakeIt.API.Services;
using StakeIt.Infrastructure.Services;

// Authentication Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IJwtService, JwtService>();

// Stakes Services
builder.Services.AddScoped<IStakeService, StakeService>();

// Payment Services
builder.Services.AddScoped<IPaymentService, PaymentService>();

// Geofence Services
builder.Services.AddScoped<IGeofenceService, GeofenceService>();

// Challenge Services
builder.Services.AddScoped<IChallengeService, ChallengeService>();

// ========================================
// BUILD APP
// ========================================

var app = builder.Build();

// ========================================
// DATABASE SEEDING
// ========================================

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<StakeItDbContext>();

        // Apply migrations in development
        if (app.Environment.IsDevelopment())
        {
            await context.Database.MigrateAsync();
        }

        // Seed initial data
        await DbSeeder.SeedAsync(context);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database.");
    }
}

// ========================================
// MIDDLEWARE PIPELINE
// ========================================

// Swagger (Development only)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "StakeIt API v1");
        options.RoutePrefix = string.Empty; // Swagger at root
    });
}

app.UseHttpsRedirection();

// CORS
app.UseCors(app.Environment.IsDevelopment() ? "AllowAll" : "Production");

// Authentication & Authorization
app.UseAuthentication();
app.UseAuthorization();

// Controllers
app.MapControllers();

// SignalR Hubs
// app.MapHub<ChallengeHub>("/hubs/challenge");

// Health check endpoint
app.MapGet("/health", () => Results.Ok(new
{
    Status = "Healthy",
    Timestamp = DateTime.UtcNow,
    Version = "1.0.0"
}))
.WithName("HealthCheck")
.WithOpenApi();

// ========================================
// RUN APPLICATION
// ========================================

app.Run();
