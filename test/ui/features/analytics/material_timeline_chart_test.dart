import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/widgets/material_timeline_chart.dart';
import 'package:dwaar/data/models/order/order.dart';

Order makeTimedOrder({
  required DateTime start,
  required DateTime end,
  WasteType wasteType = WasteType.plastic,
}) => Order(
  id: 'ORD-${start.millisecondsSinceEpoch}',
  type: OrderType.pickup,
  wasteTypes: [wasteType],
  pickupAddress: 'test',
  dropoffAddress: 'test',
  status: OrderStatus.completed,
  reward: 10,
  createdAt: start,
  completedAt: end,
);

void main() {
  testWidgets('MaterialTimelineChart renders with orders', (tester) async {
    final orders = [
      makeTimedOrder(
        start: DateTime(2026, 6, 21, 8),
        end: DateTime(2026, 6, 21, 10),
        wasteType: WasteType.oil,
      ),
      makeTimedOrder(
        start: DateTime(2026, 6, 23, 9),
        end: DateTime(2026, 6, 23, 11),
        wasteType: WasteType.plastic,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: MaterialTimelineChart(
              orders: orders,
              periodStart: DateTime(2026, 6, 21),
              periodEnd: DateTime(2026, 6, 28),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(MaterialTimelineChart), findsOneWidget);
  });

  testWidgets('MaterialTimelineChart shows empty state when no orders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MaterialTimelineChart(
            orders: const [],
            periodStart: DateTime(2026, 6, 21),
            periodEnd: DateTime(2026, 6, 28),
          ),
        ),
      ),
    );
    expect(find.text('لا يوجد نشاط في هذه الفترة'), findsOneWidget);
  });
}
