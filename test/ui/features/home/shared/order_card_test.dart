import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/theme/app_theme.dart';
import 'package:dwaar/data/mock/order_mock_data.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/home/shared/order_card.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/supplier_order_card.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    theme: AppTheme.lightTheme,
    home: ChangeNotifierProvider<AppOrderStore>(
      create: (_) => AppOrderStore(),
      child: Scaffold(
        body: SafeArea(child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

Order _pendingOrder() => OrderMockData.skeletonOrders().first.copyWith(
  status: OrderStatus.pending,
  type: OrderType.pickup,
  reward: 12.5,
  wasteTypes: [WasteType.paper, WasteType.plastic],
  pickupAddress: 'عمّان - الجبيهة',
  dropoffAddress: 'الزرقاء - المحطة',
);

Order _activeOrder() => OrderMockData.skeletonOrders().first.copyWith(
  status: OrderStatus.accepted,
  type: OrderType.pickup,
  reward: 8.0,
  acceptedAt: DateTime.now().subtract(const Duration(minutes: 3)),
  wasteTypes: [WasteType.metal],
);

Order _completedOrder() => OrderMockData.skeletonOrders().first.copyWith(
  status: OrderStatus.completed,
  type: OrderType.pickup,
  reward: 15.0,
  wasteTypes: [WasteType.glass],
);

Order _supplierOrder() => OrderMockData.skeletonOrders().first.copyWith(
  status: OrderStatus.accepted,
  type: OrderType.pickup,
  driverName: 'أحمد الخالد',
  driverRating: 4.8,
  eta: '15 دقيقة',
  wasteTypes: [WasteType.paper],
);

// ── OrderCard Tests ───────────────────────────────────────────────────────────

void main() {
  group('OrderCard – driverAvailable mode', () {
    testWidgets('renders pickup address', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('عمّان'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders dropoff address', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('الزرقاء'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders reward amount', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('12.5'), findsOneWidget);
    });

    testWidgets('renders waste type chips', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('has accept button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onAction when button tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
            onAction: () => called = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      expect(called, isTrue);
    });

    testWidgets('status-colored left accent strip rendered', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Pending order accent is accentAmber — outer container uses it
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration)
              return deco.color == AppColors.accentAmber;
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });
  });

  group('OrderCard – driverActive mode', () {
    testWidgets('shows live timer when acceptedAt set', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(order: _activeOrder(), mode: OrderCardMode.driverActive),
        ),
      );
      await tester.pumpAndSettle();
      // StreamBuilder shows timer in MM:SS format
      expect(find.byType(StreamBuilder<void>), findsOneWidget);
    });

    testWidgets('shows active status badge', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(order: _activeOrder(), mode: OrderCardMode.driverActive),
        ),
      );
      await tester.pumpAndSettle();
      // Active order has green status chip
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration)
              return deco.color == AppColors.statusActiveBg;
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });
  });

  group('OrderCard – driverHistory mode', () {
    testWidgets('shows outlined details button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _completedOrder(),
            mode: OrderCardMode.driverHistory,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('completed accent uses completed color', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _completedOrder(),
            mode: OrderCardMode.driverHistory,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration)
              return deco.color == AppColors.statusCompletedText;
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });
  });

  group('OrderCard – route visualization', () {
    testWidgets('renders green pickup dot', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration) {
              return deco.shape == BoxShape.circle &&
                  deco.color == AppColors.primaryGreen;
            }
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });

    testWidgets('renders red dropoff dot', (tester) async {
      await tester.pumpWidget(
        _wrap(
          OrderCard(
            order: _pendingOrder(),
            mode: OrderCardMode.driverAvailable,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration) {
              return deco.shape == BoxShape.circle &&
                  deco.color == const Color(0xFFE53935);
            }
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });
  });

  // ── SupplierOrderCard Tests ────────────────────────────────────────────────

  group('SupplierOrderCard', () {
    testWidgets('renders waste type chips', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: _supplierOrder(),
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('renders driver name', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: _supplierOrder(),
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('أحمد'), findsOneWidget);
    });

    testWidgets('renders ETA when driver assigned', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: _supplierOrder(),
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('15'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows cancel button when canCancel is true', (tester) async {
      final pendingOrder = _pendingOrder();
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: pendingOrder,
            canCancel: true,
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('hides cancel button when canCancel is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: _supplierOrder(),
            canCancel: false,
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('accent left strip matches status', (tester) async {
      // accepted → statusActiveText
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: _supplierOrder(),
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration)
              return deco.color == AppColors.statusActiveText;
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });

    testWidgets('navigates to details on tap', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SupplierOrderCard(
            order: _supplierOrder(),
            onCancelOrder: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      // OrderDetailsView contains looping pulse animations
      // (order_arrival_section.dart, order_status_timeline.dart) that never
      // settle, so pumpAndSettle() here would hang forever. Pump past the
      // route transition in discrete steps instead of settling fully.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      // Navigation happened (widget tree changed)
      expect(find.byType(SupplierOrderCard), findsNothing);
    });
  });
}
