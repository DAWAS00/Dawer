import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../domain/repositories/i_report_request_repository.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';
import '../../analytics/analytics_tab.dart';
import 'viewmodels/individual_supplier_viewmodel.dart';
import 'tabs/individual_supplier_home_tab.dart';
import 'tabs/supplier_orders_tab.dart';
import 'tabs/supplier_profile_tab.dart';
import 'widgets/supplier_bottom_nav.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/viewmodels/base_supplier_viewmodel.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/widgets/pickup_fab.dart';
import 'views/new_pickup_request_view.dart';
import 'package:dwaar/ui/common/widgets/dev_testing_panel.dart';

class IndividualSupplierHomeView extends StatelessWidget {
  final String userName;
  final List<String> aiSuggestedCategories;

  const IndividualSupplierHomeView({
    super.key,
    required this.userName,
    this.aiSuggestedCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BaseSupplierViewModel>(
          create: (ctx) {
            final vm = IndividualSupplierViewModel(ctx.read<AppOrderStore>());
            final session = ctx.read<IAuthRepository>().currentSession;
            if (session != null) vm.setAuthUserId(session.userId);
            return vm;
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) => MarketplaceViewModel(
            ctx.read<AppOrderStore>(),
            isBusiness: false,
            initialSuggestions: aiSuggestedCategories,
          ),
        ),
      ],
      child: _IndividualSupplierHomeBody(userName: userName),
    );
  }
}

class _IndividualSupplierHomeBody extends StatelessWidget {
  final String userName;

  const _IndividualSupplierHomeBody({required this.userName});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BaseSupplierViewModel>();

    final tabs = [
      IndividualSupplierHomeTab(userName: userName),
      MarketplaceTab(
        role: UserRole.supplier,
        currentUserName: userName,
        onSupplierPurchaseConfirmed: (purchasedOrder) {
          vm.addOrder(purchasedOrder);
          vm.setTab(2);
        },
        onJobAccepted: (sale) {
          vm.setTab(2);
          if (sale != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CollectionSaleDetailView(sale: sale),
            ));
          }
        },
      ),
      SupplierOrdersTab(
        activeOrders: vm.activeOrders,
        completedOrders: vm.completedOrders,
        cancelledOrders: vm.cancelledOrders,
        collectionSaleOrders: vm.collectionSaleOrders,
        onCancelOrder: vm.cancelOrder,
        onStartTransit: vm.startCollectionSaleTransit,
        onComplete: vm.completeCollectionSale,
      ),
      AnalyticsTab(
        userId: context.read<IAuthRepository>().currentSession?.userId ?? '',
        allOrders: context.read<AppOrderStore>().supplierCompletedOrdersFor(vm.user.name),
        reportRepository: context.read<IReportRequestRepository>(),
        showMilestones: true,
        showReportCenter: true,
        showProfitability: true,
      ),
      SupplierProfileTab(
        user: vm.user,
        totalPoints: vm.totalPoints,
        totalOrders: vm.totalOrders,
        supplierType: SupplierType.individual,
        onUpdateProfile: vm.updateProfile,
      ),
    ];

    final marketVm = context.watch<MarketplaceViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: vm.currentTab,
            children: tabs,
          ),
          if (kDebugMode) const DevTestingPanel(),
        ],
      ),
      floatingActionButton: vm.currentTab == 0
          ? PickupFab(onPressed: () {
              if (!marketVm.canAddListing(vm.user.name)) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    'وصلت للحد الأقصى (${marketVm.maxListings} إعلانات نشطة)',
                  ),
                  backgroundColor: const Color(0xFFB91C1C),
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              }
              _showPostToMarketSheet(context, vm, marketVm);
            })
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: SupplierBottomNav(
        currentTab: vm.currentTab,
        onTabChanged: vm.setTab,
      ),
    );
  }

  void _showPostToMarketSheet(
    BuildContext context,
    BaseSupplierViewModel vm,
    MarketplaceViewModel marketVm,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPickupRequestView(
          role: UserRole.supplier,
          initialMode: OrderMode.marketplace,
          onSubmit: ({
            required List<WasteType> wasteTypes,
            required String pickupAddress,
            List<String> images = const [],
            String? notes,
            WasteForm? wasteForm,
            WeightCategory? weightCategory,
            double? itemPrice,
            double? pickupLat,
            double? pickupLng,
          }) {
            final order = vm.createListing(
              wasteTypes: wasteTypes,
              pickupAddress: pickupAddress,
              images: images,
              notes: notes,
              wasteForm: wasteForm,
              weightCategory: weightCategory,
              itemPrice: itemPrice,
              pickupLat: pickupLat,
              pickupLng: pickupLng,
            );
            marketVm.addListing(order);
          },
        ),
      ),
    );
  }

}
