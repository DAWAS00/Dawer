import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/ui/features/analytics/analytics_viewmodel.dart';
import 'package:dwaar/ui/features/analytics/widgets/earnings_efficiency_card.dart';

import '../../../helpers/test_app.dart';

void main() {
  Order makeOrder({
    required double reward,
    required double distanceKm,
    required DateTime completedAt,
  }) =>
      Order(
        id: 'ORD-$reward-$distanceKm',
        type: OrderType.pickup,
        wasteTypes: const [WasteType.plastic],
        pickupAddress: 'a',
        dropoffAddress: 'b',
        status: OrderStatus.completed,
        reward: reward,
        createdAt: completedAt.subtract(const Duration(hours: 2)),
        completedAt: completedAt,
        distanceKm: distanceKm,
      );

  testWidgets('EarningsEfficiencyCard shows empty state when ratio null',
      (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(
        const EarningsEfficiencyCard(earningsPerKm: null, bestJobs: []),
      ),
    );
    expect(find.text('2.50'), findsNothing);
  });

  testWidgets('EarningsEfficiencyCard shows ratio and top jobs', (tester) async {
    final jobs = [
      EfficientJob(
        order: makeOrder(
            reward: 10, distanceKm: 5, completedAt: DateTime(2026, 6, 25)),
        jodPerKm: 2.0,
      ),
    ];
    await tester.pumpWidget(
      wrapWithL10n(
        EarningsEfficiencyCard(earningsPerKm: 2.5, bestJobs: jobs),
      ),
    );
    expect(find.text('2.50'), findsOneWidget);
    // Job ratio is embedded in the localized "{value} د.أ/كم" template.
    expect(find.textContaining('2.00'), findsOneWidget);
  });
}
