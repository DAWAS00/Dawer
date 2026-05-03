import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<({double lat, double lng})?> getCurrentLocation() async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        return (lat: position.latitude, lng: position.longitude);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error getting location: $e');
        }
        // If high accuracy fails or times out, try last known
        try {
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return (lat: lastPosition.latitude, lng: lastPosition.longitude);
          }
        } catch (_) {}
      }
    }

    return null;
  }
}
