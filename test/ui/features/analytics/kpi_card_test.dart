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

  testWidgets('KpiCard calls onTap when tapped', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 150,
            child: KpiCard(
              value: '5',
              label: 'طلبات',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF2563EB),
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(KpiCard));
    expect(tapped, isTrue);
  });

  testWidgets('KpiCard does not overflow in a 2-up row at phone width',
      (tester) async {
    // Realistic phone: 360dp wide. Two cards side by side is the grid case.
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: KpiCard(
                    value: '342.5 د.أ',
                    label: 'إجمالي الأرباح',
                    icon: Icons.monetization_on_rounded,
                    color: const Color(0xFF0F5A34),
                    delta: '+12%',
                    deltaPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KpiCard(
                    value: '120 كغ',
                    label: 'وزن معالج',
                    icon: Icons.scale_rounded,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(KpiCard), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
