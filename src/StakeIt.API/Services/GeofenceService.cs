using Microsoft.EntityFrameworkCore;
using StakeIt.Core.Entities;
using StakeIt.Infrastructure.Data;

namespace StakeIt.API.Services;

public class GeofenceService : IGeofenceService
{
    private readonly StakeItDbContext _context;
    private readonly ILogger<GeofenceService> _logger;

    public GeofenceService(StakeItDbContext context, ILogger<GeofenceService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<List<Geofence>> GetPublicGeofencesAsync(string? city = null, string? category = null)
    {
        var query = _context.Geofences.Where(g => g.IsPublic);

        if (!string.IsNullOrEmpty(city))
        {
            query = query.Where(g => g.City != null && g.City.ToLower().Contains(city.ToLower()));
        }

        if (!string.IsNullOrEmpty(category))
        {
            query = query.Where(g => g.Category != null && g.Category.ToLower() == category.ToLower());
        }

        return await query.OrderBy(g => g.City).ThenBy(g => g.Name).ToListAsync();
    }

    public async Task<Geofence?> GetGeofenceByIdAsync(int id)
    {
        return await _context.Geofences.FindAsync(id);
    }

    public async Task<bool> IsWithinGeofenceAsync(int geofenceId, decimal latitude, decimal longitude)
    {
        var geofence = await _context.Geofences.FindAsync(geofenceId);
        if (geofence == null)
        {
            return false;
        }

        var distance = CalculateDistance(
            (double)latitude,
            (double)longitude,
            (double)geofence.Latitude,
            (double)geofence.Longitude
        );

        bool isWithin = distance <= geofence.RadiusMeters;

        _logger.LogInformation(
            "GPS check for geofence {GeofenceId} ({Name}): distance {Distance}m, radius {Radius}m, within: {IsWithin}",
            geofenceId, geofence.Name, distance, geofence.RadiusMeters, isWithin);

        return isWithin;
    }

    public async Task<List<Geofence>> FindNearbyGeofencesAsync(decimal latitude, decimal longitude, int radiusKm = 5)
    {
        // Get all public geofences (in production, you'd want to optimize this with spatial queries)
        var allGeofences = await _context.Geofences.Where(g => g.IsPublic).ToListAsync();

        var nearbyGeofences = allGeofences
            .Select(g => new
            {
                Geofence = g,
                Distance = CalculateDistance(
                    (double)latitude,
                    (double)longitude,
                    (double)g.Latitude,
                    (double)g.Longitude
                )
            })
            .Where(x => x.Distance <= radiusKm * 1000) // Convert km to meters
            .OrderBy(x => x.Distance)
            .Select(x => x.Geofence)
            .ToList();

        return nearbyGeofences;
    }

    /// <summary>
    /// Calculate distance between two GPS coordinates using Haversine formula
    /// Returns distance in meters
    /// </summary>
    private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371000; // Earth's radius in meters

        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        var distance = R * c;

        return distance;
    }

    private double DegreesToRadians(double degrees)
    {
        return degrees * Math.PI / 180.0;
    }
}
