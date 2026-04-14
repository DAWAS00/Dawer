import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/mock/order_mock_data.dart';
import 'package:dwaar/data/models/order.dart';

void main() {
  group('OrderMockData.seedOrders', () {
    test('returns non-empty list', () {
      expect(OrderMockData.seedOrders().isNotEmpty, isTrue);
    });

    test('all orders have non-empty IDs', () {
      for (final order in OrderMockData.seedOrders()) {
        expect(order.id.isNotEmpty, isTrue);
      }
    });

    test('supplier seed orders are present', () {
      final ids = OrderMockData.seedOrders().map((o) => o.id).toSet();
      expect(ids.contains('ORD-S01'), isTrue);
      expect(ids.contains('ORD-S02'), isTrue);
    });

    test('history seeds have completed status', () {
      final history = OrderMockData.seedOrders()
          .where((o) => o.id.startsWith('ORD-H'))
          .toList();
      expect(history.isNotEmpty, isTrue);
      for (final o in history) {
        expect(o.status, OrderStatus.completed);
      }
    });
  });

  group('OrderMockData.seedMarketItems', () {
    test('returns non-empty list', () {
      expect(OrderMockData.seedMarketItems().isNotEmpty, isTrue);
    });

    test('all items have riderBuy pickup target', () {
      for (final item in OrderMockData.seedMarketItems()) {
        expect(item.pickupTarget, PickupTarget.riderBuy);
      }
    });
  });
}
