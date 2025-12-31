import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tickdose/core/utils/logger.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permission
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        final granted = await requestPermission();
        if (!granted) {
          Logger.warning('Location permission denied', tag: 'Location');
          return null;
        }
      }

      // Get location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      Logger.info('Location obtained: ${position.latitude}, ${position.longitude}', tag: 'Location');
      return position;
    } catch (e, stackTrace) {
      Logger.error('Failed to get location', tag: 'Location', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Check location permission
  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Request location permission
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Calculate distance between two points (in meters)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
