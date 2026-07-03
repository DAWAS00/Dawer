import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/mock/order_mock_data.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/home/shared/order_details/order_eta_section.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    home: Scaffold(body: SafeArea(child: child)),
  );
}

Order _order({required OrderStatus status, int? etaMinutes}) =>
    OrderMockData.skeletonOrders().first.copyWith(
      status: status,
      etaMinutes: etaMinutes,
      pickupAddress:
          'حي النزهة، شارع المدينة المنورة، عمارة 12، الطابق 3، عمّان',
    );

void main() {
  testWidgets('shows the ETA card while accepted with a live ETA', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        OrderEtaSection(
          order: _order(status: OrderStatus.accepted, etaMinutes: 12),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('12'), findsOneWidget);
  });

  testWidgets('shows the ETA card while in transit', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OrderEtaSection(
          order: _order(status: OrderStatus.inTransit, etaMinutes: 8),
          isDriverView: true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('8'), findsOneWidget);
  });

  testWidgets('hides when order is pending (no driver yet)', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OrderEtaSection(
          order: _order(status: OrderStatus.pending, etaMinutes: 12),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(OrderEtaSection), findsOneWidget);
    expect(find.textContaining('12'), findsNothing);
  });

  testWidgets('hides when order is completed', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OrderEtaSection(
          order: _order(status: OrderStatus.completed, etaMinutes: 12),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('12'), findsNothing);
  });

  testWidgets('hides when etaMinutes is null even if status is active', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        OrderEtaSection(
          order: _order(status: OrderStatus.accepted, etaMinutes: null),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SizedBox), findsWidgets);
  });
}
