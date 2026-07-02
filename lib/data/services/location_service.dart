import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

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

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        // Build a readable address string
        final parts = [
          if (pm.subLocality != null && pm.subLocality!.isNotEmpty)
            pm.subLocality,
          if (pm.locality != null && pm.locality!.isNotEmpty) pm.locality,
          if (pm.street != null &&
              pm.street!.isNotEmpty &&
              pm.street != pm.locality)
            pm.street,
        ];
        if (parts.isEmpty) return 'موقع محدد ($lat, $lng)';
        return parts.join('، ');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Reverse geocoding error: $e');
      }
    }
    return 'عمّان، الأردن ($lat, $lng)';
  }
}
