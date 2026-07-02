import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/models/order_supabase_ext.dart';

void main() {
  const baseJson = <String, dynamic>{
    'id': '550e8400-e29b-41d4-a716-446655440000',
    'type': 'pickup',
    'status': 'pending',
    'waste_types': ['plastic'],
    'reward_jd': 5.0,
    'created_at': '2026-06-23T10:00:00.000Z',
    'is_marketplace_shared': false,
    'requires_rider': false,
    'requires_chemical_permit': false,
    'is_vat_applicable': false,
    'admin_approval_status': 'notRequired',
  };

  group('orderFromSupabaseJson', () {
    test('parses a minimal row without proof columns', () {
      final order = orderFromSupabaseJson(baseJson);
      expect(order.id, '550e8400-e29b-41d4-a716-446655440000');
      expect(order.proof, isNull);
      expect(order.pickupProof, isNull);
    });

    test('parses dropoff proof columns', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..addAll({
          'proof_image_path': 'https://example.com/proof.jpg',
          'proof_captured_at': '2026-06-23T12:00:00.000Z',
          'proof_lat': 31.9554,
          'proof_lng': 35.9454,
          'proof_checksum': 'abc123' * 10 + 'abcd', // 64 chars
          'proof_weight_kg': 22.5,
        });

      final order = orderFromSupabaseJson(json);
      expect(order.proof, isNotNull);
      expect(order.proof!.imagePath, 'https://example.com/proof.jpg');
      expect(order.proof!.weightKg, 22.5);
      expect(order.proof!.lat, 31.9554);
      expect(order.pickupProof, isNull);
    });

    test('parses pickup proof columns', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..addAll({
          'pickup_proof_photo_url': 'https://example.com/pickup.jpg',
          'pickup_proof_captured_at': '2026-06-23T11:00:00.000Z',
          'pickup_proof_lat': 32.0,
          'pickup_proof_lng': 36.0,
          'pickup_proof_checksum': 'def456' * 10 + 'defg',
          'pickup_proof_weight_kg': 15.0,
        });

      final order = orderFromSupabaseJson(json);
      expect(order.pickupProof, isNotNull);
      expect(order.pickupProof!.imagePath, 'https://example.com/pickup.jpg');
      expect(order.pickupProof!.weightKg, 15.0);
      expect(order.proof, isNull);
    });

    test('parses both proof and pickupProof simultaneously', () {
      final json = Map<String, dynamic>.from(baseJson)
        ..addAll({
          'proof_image_path': 'https://example.com/proof.jpg',
          'proof_captured_at': '2026-06-23T12:00:00.000Z',
          'proof_lat': 31.9554,
          'proof_lng': 35.9454,
          'proof_checksum': 'abc123' * 10 + 'abcd',
          'pickup_proof_photo_url': 'https://example.com/pickup.jpg',
          'pickup_proof_captured_at': '2026-06-23T11:00:00.000Z',
          'pickup_proof_lat': 32.0,
          'pickup_proof_lng': 36.0,
          'pickup_proof_checksum': 'def456' * 10 + 'defg',
        });

      final order = orderFromSupabaseJson(json);
      expect(order.proof, isNotNull);
      expect(order.pickupProof, isNotNull);
      expect(order.proof!.imagePath, 'https://example.com/proof.jpg');
      expect(order.pickupProof!.imagePath, 'https://example.com/pickup.jpg');
    });
  });

  group('Order.toSupabaseMap', () {
    test('omits proof columns when proof is null', () {
      final order = Order(
        id: '550e8400-e29b-41d4-a716-446655440000',
        type: OrderType.pickup,
        wasteTypes: const [WasteType.plastic],
        pickupAddress: 'عمّان',
        dropoffAddress: '',
        status: OrderStatus.pending,
        reward: 0,
        createdAt: DateTime(2026, 6, 23),
      );

      final map = order.toSupabaseMap(null);
      expect(map.containsKey('proof_image_path'), isFalse);
      expect(map.containsKey('pickup_proof_photo_url'), isFalse);
    });

    test('includes pickupProof columns when set', () {
      final proof = OrderProof(
        imagePath: 'https://storage.example.com/pickup.jpg',
        capturedAt: DateTime(2026, 6, 23, 11),
        lat: 32.0,
        lng: 36.0,
        checksum: 'deadbeef',
        weightKg: 20.0,
      );
      final order = Order(
        id: '550e8400-e29b-41d4-a716-446655440000',
        type: OrderType.pickup,
        wasteTypes: const [WasteType.plastic],
        pickupAddress: 'عمّان',
        dropoffAddress: '',
        status: OrderStatus.arrivedAtPickup,
        reward: 0,
        createdAt: DateTime(2026, 6, 23),
        pickupProof: proof,
      );

      final map = order.toSupabaseMap(null);
      expect(
        map['pickup_proof_photo_url'],
        'https://storage.example.com/pickup.jpg',
      );
      expect(map['pickup_proof_weight_kg'], 20.0);
      expect(map['pickup_proof_checksum'], 'deadbeef');
      expect(map.containsKey('proof_image_path'), isFalse);
    });
  });
}
