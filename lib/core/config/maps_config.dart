import 'package:flutter/foundation.dart';

/// Holds the Google Maps Platform API key for server-side calls
/// (Directions API, Distance Matrix API).
///
/// The same key is used by the Android Maps SDK (via local.properties
/// `MAPS_API_KEY`). Add it to `.env.local` so the Dart runtime can read it:
///
///   MAPS_API_KEY=AIza...
///
/// Call [init] once in `main()` after loading dotenv.
/// When the key is absent all route/ETA features degrade gracefully —
/// the map still shows driver markers without a polyline.
class MapsConfig {
  MapsConfig._();

  static String _key = '';

  static bool get hasDirectionsKey => _key.isNotEmpty;
  static String get directionsKey => _key;

  static void init(String key) {
    _key = key;
    debugPrint('[MapsConfig] Directions API key loaded (length=${key.length}).');
  }
}
