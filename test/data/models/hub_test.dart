import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';

void main() {
  group('Hub.fromJson', () {
    const validJson = {
      'id': 'abc-123-def',
      'name': 'Hub Al-Sweifieh',
      'address': 'Sweifieh Commercial District, Amman',
      'lat': 31.944,
      'lng': 35.871,
      'active': true,
      'capacity_kg': 1200.0,
      'current_load': {
        'cookingOil': 312,
        'plastic': 156,
        'paper': 94,
        'electronics': 37,
      },
      'schedule': 'weekly',
      'next_shipment_date': '2026-06-27',
      'last_shipment_date': '2026-06-20',
      'status': 'collecting',
      'created_at': '2026-06-26T10:00:00Z',
    };

    test('parses all fields correctly', () {
      final hub = Hub.fromJson(validJson);
      expect(hub.id, 'abc-123-def');
      expect(hub.name, 'Hub Al-Sweifieh');
      expect(hub.lat, closeTo(31.944, 0.001));
      expect(hub.lng, closeTo(35.871, 0.001));
      expect(hub.active, isTrue);
      expect(hub.capacityKg, 1200.0);
      expect(hub.currentLoad['cookingOil'], 312);
      expect(hub.schedule, 'weekly');
      expect(hub.status, 'collecting');
      expect(hub.nextShipmentDate, '2026-06-27');
      expect(hub.createdAt, isA<DateTime>());
    });

    test('handles null optional date fields', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['next_shipment_date'] = null
        ..['last_shipment_date'] = null;
      final hub = Hub.fromJson(json);
      expect(hub.nextShipmentDate, isNull);
      expect(hub.lastShipmentDate, isNull);
    });

    test('handles integer lat/lng from Supabase numeric type', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['lat'] = 31
        ..['lng'] = 35;
      final hub = Hub.fromJson(json);
      expect(hub.lat, 31.0);
      expect(hub.lng, 35.0);
    });
  });
}
