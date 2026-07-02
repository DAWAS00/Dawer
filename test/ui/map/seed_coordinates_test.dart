import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/mock/order_mock_data.dart';

void main() {
  group('Seed order coordinates', () {
    final orders = OrderMockData.seedOrders();

    test('all seed orders have pickup coordinates', () {
      for (final order in orders) {
        expect(
          order.pickupLat,
          isNotNull,
          reason: '${order.id} missing pickupLat',
        );
        expect(
          order.pickupLng,
          isNotNull,
          reason: '${order.id} missing pickupLng',
        );
      }
    });

    test('all seed orders have dropoff coordinates', () {
      for (final order in orders) {
        expect(
          order.dropoffLat,
          isNotNull,
          reason: '${order.id} missing dropoffLat',
        );
        expect(
          order.dropoffLng,
          isNotNull,
          reason: '${order.id} missing dropoffLng',
        );
      }
    });

    test('coordinates are in valid Jordan range', () {
      for (final order in orders) {
        expect(
          order.pickupLat!,
          inInclusiveRange(29.0, 33.5),
          reason: '${order.id} pickupLat out of Jordan range',
        );
        expect(
          order.pickupLng!,
          inInclusiveRange(34.5, 39.5),
          reason: '${order.id} pickupLng out of Jordan range',
        );
        expect(
          order.dropoffLat!,
          inInclusiveRange(29.0, 33.5),
          reason: '${order.id} dropoffLat out of Jordan range',
        );
        expect(
          order.dropoffLng!,
          inInclusiveRange(34.5, 39.5),
          reason: '${order.id} dropoffLng out of Jordan range',
        );
      }
    });

    test('DRV-TRANSIT-01 inTransit order has inTransitAt set', () {
      final ordS01 = orders.firstWhere((o) => o.id == 'DRV-TRANSIT-01');
      expect(ordS01.inTransitAt, isNotNull);
    });
  });
}
