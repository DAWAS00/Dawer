import 'package:latlong2/latlong.dart';
import 'package:dwaar/core/constants/map_tokens.dart';

class MapConstants {
  MapConstants._();

  static const ammanCenter = LatLng(31.9539, 35.9106);
  static const defaultZoom = 13.0;
  static const routeZoom = 12.0;
  static const pickupZoom = 15.5;

  static String get tileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/{z}/{x}/{y}'
      '?access_token=${MapTokens.mapbox}';

  static const tileAttribution = '© Mapbox  © OpenStreetMap';

  /// Mapbox Directions API — returns road-snapped GeoJSON route
  static String directionsUrl(
          double fromLat, double fromLng, double toLat, double toLng) =>
      'https://api.mapbox.com/directions/v5/mapbox/driving'
      '/$fromLng,$fromLat;$toLng,$toLat'
      '?geometries=geojson&access_token=${MapTokens.mapbox}';
}
