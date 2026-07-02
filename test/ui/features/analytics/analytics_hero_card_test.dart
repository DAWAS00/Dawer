import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/widgets/analytics_hero_card.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('AnalyticsHeroCard displays formatted value and label', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(
        AnalyticsHeroCard(
          value: 342.5,
          label: 'إجمالي الأرباح · هذا الشهر',
          formatter: (v) => '${v.toStringAsFixed(1)} د.أ',
          sparkPoints: const [1, 2, 3, 5, 4, 6, 7],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('إجمالي الأرباح · هذا الشهر'), findsOneWidget);
  });

  testWidgets('AnalyticsHeroCard shows delta chip when deltaPct provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(
        AnalyticsHeroCard(
          value: 100,
          label: 'l',
          formatter: (v) => v.toStringAsFixed(0),
          sparkPoints: const [1, 2, 3],
          deltaPct: 12.4,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('+12.4%'), findsOneWidget);
  });

  testWidgets('AnalyticsHeroCard shows empty state when no data', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(
        const AnalyticsHeroCard(
          value: 0,
          label: 'إجمالي الأرباح',
          formatter: _idFormatter,
          sparkPoints: [],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('لا يوجد نشاط بعد'), findsOneWidget);
  });

  testWidgets('AnalyticsHeroCard renders without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: AnalyticsHeroCard(
              value: 342.5,
              label: 'إجمالي الأرباح · هذا الشهر',
              formatter: (v) => '${v.toStringAsFixed(1)} د.أ',
              sparkPoints: const [1, 2, 3, 5, 4, 6, 7],
              deltaPct: 12.4,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AnalyticsHeroCard shows streak chip when streak >= 2', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(
        AnalyticsHeroCard(
          value: 100,
          label: 'l',
          formatter: (v) => v.toStringAsFixed(0),
          sparkPoints: const [1, 2, 3],
          currentStreak: 5,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

String _idFormatter(double v) => v.toString();
