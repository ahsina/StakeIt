import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for location service
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<LocationPermissionStatus> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    return LocationPermissionStatus.granted;
  }

  /// Get current location
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled');
      }

      // Check permissions
      final permissionStatus = await checkAndRequestPermission();
      if (permissionStatus != LocationPermissionStatus.granted) {
        throw LocationException('Location permission not granted');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    } on LocationServiceDisabledException {
      throw LocationException('Location services are disabled');
    } on PermissionDeniedException {
      throw LocationException('Location permission denied');
    } on TimeoutException {
      throw LocationException('Location request timed out');
    } catch (e) {
      throw LocationException('Failed to get location: $e');
    }
  }

  /// Check if current location is within radius of target location
  Future<bool> isWithinRadius({
    required double targetLat,
    required double targetLng,
    required double radiusMeters,
  }) async {
    try {
      final location = await getCurrentLocation();
      if (location == null) {
        return false;
      }

      final distance = Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        targetLat,
        targetLng,
      );

      return distance <= radiusMeters;
    } catch (e) {
      return false;
    }
  }

  /// Get distance to target location in meters
  Future<double?> getDistanceToLocation({
    required double targetLat,
    required double targetLng,
  }) async {
    try {
      final location = await getCurrentLocation();
      if (location == null) {
        return null;
      }

      return Geolocator.distanceBetween(
        location.latitude,
        location.longitude,
        targetLat,
        targetLng,
      );
    } catch (e) {
      return null;
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

// Models
class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
}

class LocationException implements Exception {
  final String message;

  LocationException(this.message);

  @override
  String toString() => message;
}
