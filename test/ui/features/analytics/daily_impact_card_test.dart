import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/utils/eco_impact_calculator.dart';
import 'package:dwaar/ui/features/analytics/widgets/daily_impact_card.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('DailyImpactCard shows order count, weight, and impact values',
      (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(
        DailyImpactCard(
          impact: const EcoImpactResult(
            co2SavedKg: 45.0,
            waterSavedLiters: 15.0,
            energySavedKwh: 140.0,
          ),
          orderCount: 3,
          weightKg: 60,
          date: DateTime(2026, 6, 29), // Monday
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('60 كغ'), findsOneWidget);
    expect(find.text('45.0 كغ'), findsOneWidget);
    expect(find.text('15 ل'), findsOneWidget);
    expect(find.text('140.0 kWh'), findsOneWidget);
    expect(find.textContaining('الإثنين'), findsOneWidget);
  });

  testWidgets('DailyImpactCard renders zero state without overflow',
      (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(
        DailyImpactCard(
          impact: const EcoImpactResult(
            co2SavedKg: 0,
            waterSavedLiters: 0,
            energySavedKwh: 0,
          ),
          orderCount: 0,
          weightKg: 0,
          date: DateTime(2026, 6, 28), // Sunday
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
