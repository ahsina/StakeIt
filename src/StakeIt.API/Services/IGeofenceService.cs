using StakeIt.Core.Entities;

namespace StakeIt.API.Services;

public interface IGeofenceService
{
    Task<List<Geofence>> GetPublicGeofencesAsync(string? city = null, string? category = null);
    Task<Geofence?> GetGeofenceByIdAsync(int id);
    Task<bool> IsWithinGeofenceAsync(int geofenceId, decimal latitude, decimal longitude);
    Task<List<Geofence>> FindNearbyGeofencesAsync(decimal latitude, decimal longitude, int radiusKm = 5);
}
