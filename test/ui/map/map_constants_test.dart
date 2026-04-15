import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/common/map/map_constants.dart';

void main() {
  group('MapConstants', () {
    test('ammanCenter is roughly Amman', () {
      expect(MapConstants.ammanCenter.latitude, closeTo(31.95, 0.1));
      expect(MapConstants.ammanCenter.longitude, closeTo(35.91, 0.1));
    });

    test('defaultZoom is positive', () {
      expect(MapConstants.defaultZoom, greaterThan(0));
    });

    test('routeZoom is positive', () {
      expect(MapConstants.routeZoom, greaterThan(0));
    });

    test('pickupZoom is greater than routeZoom', () {
      expect(MapConstants.pickupZoom, greaterThan(MapConstants.routeZoom));
    });

    test('tileUrl contains mapbox domain', () {
      expect(MapConstants.tileUrl, contains('api.mapbox.com'));
    });

    test('directionsUrl builds correct URL', () {
      final url = MapConstants.directionsUrl(31.95, 35.91, 32.0, 36.0);
      expect(url, contains('api.mapbox.com/directions'));
      expect(url, contains('35.91,31.95'));
      expect(url, contains('36.0,32.0'));
      expect(url, contains('geometries=geojson'));
    });

    test('tileAttribution is non-empty', () {
      expect(MapConstants.tileAttribution.isNotEmpty, isTrue);
    });
  });
}
