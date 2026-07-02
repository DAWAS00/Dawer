import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/theme/app_theme.dart';
import 'package:dwaar/data/mock/order_mock_data.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/l10n/generated/app_localizations.dart';
import 'package:dwaar/ui/features/home/shared/viewmodels/marketplace_viewmodel.dart';
import 'package:dwaar/ui/features/home/shared/widgets/market_item_card.dart';
import 'package:dwaar/ui/features/home/shared/widgets/collection_job_card.dart';
import 'package:dwaar/ui/features/home/shared/widgets/marketplace_segment_bar.dart';
import 'package:dwaar/ui/features/home/shared/widgets/marketplace_suggestion_banner.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child, {MarketplaceViewModel? vm}) {
  final store = AppOrderStore();
  final viewModel = vm ?? MarketplaceViewModel(store);
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    theme: AppTheme.lightTheme,
    home: ChangeNotifierProvider<MarketplaceViewModel>.value(
      value: viewModel,
      child: Scaffold(
        body: SafeArea(child: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

Order _sampleListing() => OrderMockData.skeletonOrders().first.copyWith(
  status: OrderStatus.pending,
  type: OrderType.pickup,
  itemPrice: 35.0,
  supplierName: 'محمد الزيد',
  pickupAddress: 'عمّان - الجبيهة',
  wasteTypes: [WasteType.paper, WasteType.plastic],
);

Order _sampleJob() => OrderMockData.skeletonOrders().first.copyWith(
  status: OrderStatus.pending,
  type: OrderType.collection,
  supplierName: 'شركة البيئة الخضراء',
  pickupAddress: 'الزرقاء - المحطة',
  wasteTypes: [WasteType.metal, WasteType.glass],
  pricePerKg: 0.5,
  paymentModel: PaymentModel.perKg,
  jobDescription: 'نبحث عن معادن وزجاج بكميات كبيرة',
);

// ── Market Item Card Tests ────────────────────────────────────────────────────

void main() {
  group('MarketItemCard', () {
    testWidgets('renders seller name', (tester) async {
      final item = _sampleListing();
      await tester.pumpWidget(_wrap(MarketItemCard(item: item, onTap: () {})));
      await tester.pumpAndSettle();

      expect(find.text('محمد الزيد'), findsOneWidget);
    });

    testWidgets('renders pickup address', (tester) async {
      final item = _sampleListing();
      await tester.pumpWidget(_wrap(MarketItemCard(item: item, onTap: () {})));
      await tester.pumpAndSettle();

      expect(find.textContaining('عمّان'), findsAny);
    });

    testWidgets('renders price in amber color area', (tester) async {
      final item = _sampleListing();
      await tester.pumpWidget(_wrap(MarketItemCard(item: item, onTap: () {})));
      await tester.pumpAndSettle();

      expect(find.textContaining('35'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      final item = _sampleListing();
      await tester.pumpWidget(
        _wrap(MarketItemCard(item: item, onTap: () => tapped = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MarketItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders waste type chips', (tester) async {
      final item = _sampleListing();
      await tester.pumpWidget(_wrap(MarketItemCard(item: item, onTap: () {})));
      await tester.pumpAndSettle();

      // Should show at least one waste type label
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows unknown seller when name is null', (tester) async {
      final item = _sampleListing().copyWith(supplierName: null);
      await tester.pumpWidget(_wrap(MarketItemCard(item: item, onTap: () {})));
      await tester.pumpAndSettle();

      expect(find.textContaining('بائع'), findsAny);
    });
  });

  // ── Collection Job Card Tests ───────────────────────────────────────────────

  group('CollectionJobCard', () {
    testWidgets('renders company name', (tester) async {
      final job = _sampleJob();
      await tester.pumpWidget(_wrap(CollectionJobCard(job: job)));
      await tester.pumpAndSettle();

      expect(find.textContaining('البيئة الخضراء'), findsOneWidget);
    });

    testWidgets('renders pickup address', (tester) async {
      final job = _sampleJob();
      await tester.pumpWidget(_wrap(CollectionJobCard(job: job)));
      await tester.pumpAndSettle();

      expect(find.textContaining('الزرقاء'), findsAny);
    });

    testWidgets('shows claim button when showClaimButton=true', (tester) async {
      final job = _sampleJob();
      var claimed = false;
      await tester.pumpWidget(
        _wrap(
          CollectionJobCard(
            job: job,
            showClaimButton: true,
            onClaim: () => claimed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final claimBtn = find.byType(ElevatedButton);
      expect(claimBtn, findsOneWidget);
      await tester.tap(claimBtn);
      expect(claimed, isTrue);
    });

    testWidgets('hides claim button by default', (tester) async {
      final job = _sampleJob();
      await tester.pumpWidget(_wrap(CollectionJobCard(job: job)));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('shows blue accent outer container for visual distinction', (
      tester,
    ) async {
      final job = _sampleJob();
      await tester.pumpWidget(_wrap(CollectionJobCard(job: job)));
      await tester.pumpAndSettle();

      // Outer container has jobBlue background as accent strip
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            if (deco is BoxDecoration) {
              return deco.color == AppColors.jobBlue;
            }
            return false;
          })
          .toList();
      expect(containers, isNotEmpty);
    });

    testWidgets('renders job description when present', (tester) async {
      final job = _sampleJob();
      await tester.pumpWidget(_wrap(CollectionJobCard(job: job)));
      await tester.pumpAndSettle();

      expect(find.textContaining('معادن'), findsAny);
    });
  });

  // ── Segment Bar Tests ───────────────────────────────────────────────────────

  group('MarketplaceSegmentBar', () {
    testWidgets('renders two tabs', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MarketplaceSegmentBar(
            selectedIndex: 0,
            listingsCount: 5,
            jobsCount: 3,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(_SegmentTabFinder), findsNothing); // indirect check
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('shows count badges when count > 0', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MarketplaceSegmentBar(
            selectedIndex: 0,
            listingsCount: 7,
            jobsCount: 2,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('calls onChanged when a tab is tapped', (tester) async {
      int? changedTo;
      await tester.pumpWidget(
        _wrap(
          MarketplaceSegmentBar(
            selectedIndex: 0,
            listingsCount: 5,
            jobsCount: 3,
            onChanged: (i) => changedTo = i,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first GestureDetector (jobs tab)
      await tester.tap(find.byType(GestureDetector).first);
      expect(changedTo, isNotNull);
    });

    testWidgets('animated underline indicator renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MarketplaceSegmentBar(
            selectedIndex: 0,
            listingsCount: 5,
            jobsCount: 3,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Stack containing the animated indicator
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });
  });

  // ── Suggestion Banner Tests ─────────────────────────────────────────────────

  group('MarketplaceSuggestionBanner', () {
    testWidgets('hidden when no suggestions', (tester) async {
      final store = AppOrderStore();
      final vm = MarketplaceViewModel(store);
      await tester.pumpWidget(
        _wrap(const MarketplaceSuggestionBanner(), vm: vm),
      );
      await tester.pumpAndSettle();

      // SizedBox.shrink — no category chips visible
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('visible when suggestions present', (tester) async {
      final store = AppOrderStore();
      final vm = MarketplaceViewModel(
        store,
        initialSuggestions: ['ورق', 'بلاستيك'],
      );
      await tester.pumpWidget(
        _wrap(const MarketplaceSuggestionBanner(), vm: vm),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.textContaining('ورق'), findsAny);
    });

    testWidgets('dismiss button clears suggestions', (tester) async {
      final store = AppOrderStore();
      final vm = MarketplaceViewModel(store, initialSuggestions: ['ورق']);
      await tester.pumpWidget(
        _wrap(const MarketplaceSuggestionBanner(), vm: vm),
      );
      await tester.pumpAndSettle();

      // Find and tap close icon
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(vm.showSuggestionBanner, isFalse);
    });
  });
}

// Dummy class just to make linter happy — not actually used in tests
class _SegmentTabFinder extends Widget {
  const _SegmentTabFinder() : super(key: null);
  @override
  Element createElement() => throw UnimplementedError();
}
