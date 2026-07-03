import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/hub.dart';
import 'package:dwaar/domain/repositories/i_hub_repository.dart';
import 'package:dwaar/ui/common/widgets/hubs/hubs_section.dart';
import 'package:dwaar/ui/common/widgets/hubs/hubs_map_view.dart';
import 'package:dwaar/ui/common/widgets/hubs/hub_details_sheet.dart';
import 'package:dwaar/ui/common/widgets/hubs/viewmodels/hubs_viewmodel.dart';
import '../../helpers/test_app.dart';

class _FakeHubRepository implements IHubRepository {
  final StreamController<List<Hub>> _ctrl =
      StreamController<List<Hub>>.broadcast();
  List<Hub> currentHubs = [];

  void emit(List<Hub> list) {
    currentHubs = list;
    _ctrl.add(list);
  }

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async => Success(currentHubs);

  @override
  Stream<List<Hub>> watchActiveHubs() {
    Future.microtask(() => _ctrl.add(currentHubs));
    return _ctrl.stream;
  }

  void dispose() => _ctrl.close();
}

void main() {
  late _FakeHubRepository repo;

  setUp(() {
    repo = _FakeHubRepository();
  });

  tearDown(() {
    repo.dispose();
  });

  Widget pumpWidget(Widget child) {
    return MultiProvider(
      providers: [
        Provider<IHubRepository>.value(value: repo),
        ChangeNotifierProvider<HubsViewModel>(
          create: (ctx) => HubsViewModel(repo),
        ),
      ],
      child: wrapWithL10n(child, locale: 'ar'),
    );
  }

  group('HubsSection tests', () {
    testWidgets('renders skeletons when loading', (tester) async {
      repo.currentHubs = [];
      await tester.pumpWidget(pumpWidget(const HubsSection()));

      // Initially ViewModel is in loading state
      expect(find.text('مراكز التسليم المتاحة'), findsOneWidget);
      // Skeletons are rendered as children of DwaarSkeleton
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders active hubs after loading success', (tester) async {
      final mockHubs = [
        Hub(
          id: 'h1',
          name: 'مركز سويدفية',
          address: 'عمان، السويدفية',
          lat: 31.944,
          lng: 35.871,
          active: true,
          capacityKg: 1000,
          currentLoad: const {'cookingOil': 100, 'plastic': 200},
          schedule: 'weekly',
          nextShipmentDate: '2026-07-10',
          lastShipmentDate: '2026-07-03',
          status: 'collecting',
          createdAt: DateTime.now(),
        ),
      ];
      repo.emit(mockHubs);

      await tester.pumpWidget(pumpWidget(const HubsSection()));
      await tester.pumpAndSettle();

      // Skeletons should hide, and actual hub chip show up
      expect(find.text('مركز سويدفية'), findsOneWidget);
      expect(find.text('عمان، السويدفية'), findsOneWidget);
      expect(find.text('قيد الجمع'), findsOneWidget); // Localized status text
    });

    testWidgets('hides section when no hubs are active', (tester) async {
      repo.emit([]);
      await tester.pumpWidget(pumpWidget(const HubsSection()));
      await tester.pumpAndSettle();

      // Section header should not render
      expect(find.text('مراكز التسليم المتاحة'), findsNothing);
    });
  });

  group('HubDetailsBottomSheet tests', () {
    testWidgets('renders progress bar math and breakdown chips correctly', (
      tester,
    ) async {
      final hub = Hub(
        id: 'h1',
        name: 'مركز البلد',
        address: 'وسط البلد',
        lat: 31.952,
        lng: 35.934,
        active: true,
        capacityKg: 1000,
        currentLoad: const {'cookingOil': 250, 'plastic': 150, 'paper': 300},
        schedule: 'weekly',
        nextShipmentDate: '2026-07-10',
        lastShipmentDate: '2026-07-03',
        status: 'ready',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(pumpWidget(HubDetailsBottomSheet(hub: hub)));
      await tester.pumpAndSettle();

      // Check text contents
      expect(find.text('مركز البلد'), findsOneWidget);
      expect(find.text('سعة مركز التجميع'), findsOneWidget);
      expect(find.text('تفاصيل المواد'), findsOneWidget);

      // Verify LTR fractional ratio output: "700 / 1000" (cookingOil 250 + plastic 150 + paper 300 = 700)
      expect(find.text('700 / 1000'), findsOneWidget);

      // Verify category breakdown chips weights
      expect(find.text('250'), findsOneWidget); // Cooking Oil
      expect(find.text('150'), findsOneWidget); // Plastic
      expect(find.text('300'), findsOneWidget); // Paper
      expect(
        find.text('0'),
        findsOneWidget,
      ); // Electronics (not set, default 0)
    });
  });

  group('HubsMapView tests', () {
    testWidgets('renders GoogleMap widget and responds to marker interactions', (
      tester,
    ) async {
      final hubs = [
        Hub(
          id: 'h1',
          name: 'مركز سويدفية',
          address: 'عمان، السويدفية',
          lat: 31.944,
          lng: 35.871,
          active: true,
          capacityKg: 1000,
          currentLoad: const {'cookingOil': 100},
          schedule: 'weekly',
          nextShipmentDate: '2026-07-10',
          lastShipmentDate: '2026-07-03',
          status: 'collecting',
          createdAt: DateTime.now(),
        ),
      ];
      repo.emit(hubs);

      await tester.pumpWidget(pumpWidget(const HubsMapView()));
      // Allow async custom markers generation to complete and trigger setState
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Verify GoogleMap exists
      final mapFinder = find.byType(GoogleMap);
      expect(mapFinder, findsOneWidget);

      final GoogleMap mapWidget = tester.widget(mapFinder);
      expect(mapWidget.markers, isNotEmpty);

      // Verify target marker ID exists in map configuration
      final targetId = const MarkerId('h1');
      final marker = mapWidget.markers.firstWhere(
        (m) => m.markerId == targetId,
      );
      expect(marker, isNotNull);

      // Simulate programmatic tap on marker to trigger bottom sheet details overlay
      expect(marker.onTap, isNotNull);
      marker.onTap!();
      await tester.pumpAndSettle();

      // Bottom sheet details card should render now
      expect(find.byType(HubDetailsBottomSheet), findsOneWidget);
      expect(find.text('مركز سويدفية'), findsOneWidget); // Inside sheet
    });
  });
}
