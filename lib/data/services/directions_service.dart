import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteResult {
  final List<LatLng> polylinePoints;
  final int etaMinutes;
  const RouteResult({required this.polylinePoints, required this.etaMinutes});
}

/// Thin wrapper around the Google Directions API.
/// Returns null on any error (network, quota, bad key) so callers can degrade
/// gracefully — the map still works without a route overlay.
class DirectionsService {
  DirectionsService._();

  static const _timeout = Duration(seconds: 8);

  static Future<RouteResult?> fetchRoute({
    required LatLng origin,
    required LatLng destination,
    required String apiKey,
  }) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': apiKey,
    });

    try {
      final client = HttpClient()..connectionTimeout = _timeout;
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(_timeout);
      final body = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode != 200) {
        debugPrint('[DirectionsService] HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        debugPrint('[DirectionsService] API status: ${data["status"]}');
        return null;
      }

      final routes = (data['routes'] as List?)?.cast<Map<String, dynamic>>();
      if (routes == null || routes.isEmpty) return null;

      final route = routes.first;
      final legs = (route['legs'] as List).cast<Map<String, dynamic>>();
      final etaSeconds =
          (legs.first['duration'] as Map<String, dynamic>)['value'] as int;
      final encoded =
          (route['overview_polyline'] as Map<String, dynamic>)['points']
              as String;

      return RouteResult(
        polylinePoints: _decodePolyline(encoded),
        etaMinutes: (etaSeconds / 60).ceil(),
      );
    } catch (e, st) {
      debugPrint('[DirectionsService] Error: $e\n$st');
      return null;
    }
  }

  /// Reverse geocodes [point] to a human-readable Arabic address string.
  /// Returns null on any error (network, quota, missing key).
  static Future<String?> reverseGeocode({
    required LatLng point,
    required String apiKey,
  }) async {
    if (apiKey.isEmpty) return null;

    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${point.latitude},${point.longitude}',
      'language': 'ar',
      'key': apiKey,
    });

    try {
      final client = HttpClient()..connectionTimeout = _timeout;
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(_timeout);
      final body = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode != 200) {
        debugPrint(
          '[DirectionsService] reverseGeocode HTTP ${response.statusCode}',
        );
        return null;
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        debugPrint(
          '[DirectionsService] reverseGeocode status: ${data["status"]}',
        );
        return null;
      }

      final results = (data['results'] as List?)?.cast<Map<String, dynamic>>();
      if (results == null || results.isEmpty) return null;

      // Prefer a result covering a named route/neighbourhood over a plus-code.
      final best = results.firstWhere((r) {
        final types = (r['types'] as List?)?.cast<String>() ?? [];
        return types.contains('route') ||
            types.contains('neighborhood') ||
            types.contains('sublocality') ||
            types.contains('premise');
      }, orElse: () => results.first);

      return best['formatted_address'] as String?;
    } catch (e, st) {
      debugPrint('[DirectionsService] reverseGeocode error: $e\n$st');
      return null;
    }
  }

  // Standard Google encoded-polyline algorithm.
  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
