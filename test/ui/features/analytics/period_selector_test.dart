import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/widgets/period_selector.dart';
import 'package:dwaar/ui/features/analytics/models/analytics_period.dart';

void main() {
  testWidgets('PeriodSelector renders all three options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PeriodSelector(
            selected: AnalyticsPeriod.week,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('أسبوع'), findsOneWidget);
    expect(find.text('شهر'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
  });

  testWidgets('PeriodSelector calls onChanged when tapped', (tester) async {
    AnalyticsPeriod? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PeriodSelector(
            selected: AnalyticsPeriod.week,
            onChanged: (p) => selected = p,
          ),
        ),
      ),
    );
    await tester.tap(find.text('شهر'));
    expect(selected, AnalyticsPeriod.month);
  });
}
