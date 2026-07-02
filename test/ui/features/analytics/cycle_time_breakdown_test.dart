import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/analytics_viewmodel.dart';
import 'package:dwaar/ui/features/analytics/widgets/cycle_time_breakdown.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('CycleTimeBreakdownChart shows empty state when data isEmpty',
      (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(const CycleTimeBreakdownChart(data: CycleTimeBreakdown())),
    );
    expect(find.byType(ClipRRect), findsNothing);
  });

  testWidgets('CycleTimeBreakdownChart renders stacked bar + legend when data present',
      (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(
        const CycleTimeBreakdownChart(
          data: CycleTimeBreakdown(
            avgAcceptMinutes: 10,
            avgPickupMinutes: 30,
            avgTransitMinutes: 60,
            avgDropoffMinutes: 20,
            avgTotalMinutes: 120,
          ),
        ),
      ),
    );
    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
