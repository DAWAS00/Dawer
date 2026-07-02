import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/core/theme/app_theme.dart';
import 'package:dwaar/data/mock/order_mock_data.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/home/driver/views/order_preview_view.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    theme: AppTheme.lightTheme,
    home: ChangeNotifierProvider<AppOrderStore>(
      create: (_) => AppOrderStore(),
      child: child,
    ),
  );
}

Order _pendingOrder() => OrderMockData.seedOrders().first.copyWith(
  status: OrderStatus.pending,
  type: OrderType.pickup,
  reward: 12.5,
  wasteTypes: [WasteType.paper, WasteType.plastic],
  pickupAddress: 'عمّان - الجبيهة',
  dropoffAddress: 'الزرقاء - المحطة',
  pickupLat: 31.9753,
  pickupLng: 35.8562,
  dropoffLat: 31.9992,
  dropoffLng: 36.0025,
);

void main() {
  testWidgets(
    'OrderPreviewView renders order details, map, and accept button',
    (tester) async {
      final order = _pendingOrder();
      var acceptCalled = false;

      await tester.pumpWidget(
        _wrap(
          OrderPreviewView(
            order: order,
            onAccept: (o) async {
              acceptCalled = true;
              return null;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify pickup and dropoff addresses are visible
      expect(find.text(order.pickupAddress), findsOneWidget);
      expect(find.text(order.dropoffAddress), findsOneWidget);

      // Verify Accept button is visible
      final acceptButtonFinder = find.byType(ElevatedButton);
      expect(acceptButtonFinder, findsOneWidget);

      // Tap Accept button and verify it triggers callback
      await tester.tap(acceptButtonFinder);
      await tester.pumpAndSettle();

      expect(acceptCalled, isTrue);
    },
  );
}
