import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/widgets/kpi_card.dart';

void main() {
  testWidgets('KpiCard displays value and label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            value: '342.5 د.أ',
            label: 'إجمالي الأرباح',
            icon: Icons.monetization_on_rounded,
            color: Color(0xFF0F5A34),
          ),
        ),
      ),
    );
    expect(find.text('342.5 د.أ'), findsOneWidget);
    expect(find.text('إجمالي الأرباح'), findsOneWidget);
  });

  testWidgets('KpiCard shows delta when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            value: '342.5 د.أ',
            label: 'أرباح',
            icon: Icons.monetization_on_rounded,
            color: Color(0xFF0F5A34),
            delta: '+12%',
            deltaPositive: true,
          ),
        ),
      ),
    );
    expect(find.text('+12%'), findsOneWidget);
  });

  testWidgets('KpiCard hides delta when not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(
            value: '5',
            label: 'طلبات',
            icon: Icons.receipt_long_rounded,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
  });
}
