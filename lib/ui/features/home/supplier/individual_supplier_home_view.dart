import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';
import 'viewmodels/individual_supplier_viewmodel.dart';
import 'tabs/individual_supplier_home_tab.dart';
import 'tabs/supplier_orders_tab.dart';
import 'tabs/supplier_profile_tab.dart';
import 'widgets/new_order_sheet.dart';
import 'widgets/supplier_bottom_nav.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/widgets/post_to_market_sheet.dart';

class IndividualSupplierHomeView extends StatelessWidget {
  final String userName;

  const IndividualSupplierHomeView({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => IndividualSupplierViewModel(ctx.read<AppOrderStore>())),
        ChangeNotifierProvider(create: (ctx) => MarketplaceViewModel(ctx.read<AppOrderStore>())),
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
    final vm = context.watch<IndividualSupplierViewModel>();

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
        onCancelSale: (id) => vm.cancelCollectionSale(id),
        onStartTransit: vm.startCollectionSaleTransit,
        onComplete: vm.completeCollectionSale,
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
      body: IndexedStack(
        index: vm.currentTab,
        children: tabs,
      ),
      floatingActionButton: vm.currentTab == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_new_order',
                  onPressed: () => _showNewOrderSheet(context, vm),
                  backgroundColor: const Color(0xFF06402B),
                  elevation: 4,
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text('طلب استلام',
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'fab_market',
                  onPressed: () => _showPostToMarketSheet(context, vm, marketVm),
                  backgroundColor: const Color(0xFF1E40AF),
                  elevation: 4,
                  icon: const Icon(Icons.store_rounded, color: Colors.white),
                  label: Text('نشر في السوق',
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: SupplierBottomNav(
        currentTab: vm.currentTab,
        onTabChanged: vm.setTab,
      ),
    );
  }

  void _showNewOrderSheet(
    BuildContext context,
    IndividualSupplierViewModel vm,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => NewOrderSheet(
        preselected: const {},
        onSubmit: ({
          required List<WasteType> wasteTypes,
          required String pickupAddress,
          List<String> images = const [],
          String? notes,
          double? estimatedWeightKg,
          WasteForm? wasteForm,
          WeightCategory? weightCategory,
          PickupTarget? pickupTarget,
          double? itemPrice,
        }) {
          vm.createOrder(
            wasteTypes: wasteTypes,
            pickupAddress: pickupAddress,
            images: images,
            notes: notes,
            wasteForm: wasteForm,
            weightCategory: weightCategory,
            pickupTarget: pickupTarget ?? PickupTarget.company,
            itemPrice: itemPrice,
          );
        },
      ),
    );
  }

  void _showPostToMarketSheet(
    BuildContext context,
    IndividualSupplierViewModel vm,
    MarketplaceViewModel marketVm,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PostToMarketSheet(
        onSubmit: ({
          required List<WasteType> wasteTypes,
          required String pickupAddress,
          List<String> images = const [],
          String? notes,
          WasteForm? wasteForm,
          WeightCategory? weightCategory,
          double? itemPrice,
        }) {
          final order = vm.createListing(
            wasteTypes: wasteTypes,
            pickupAddress: pickupAddress,
            images: images,
            notes: notes,
            wasteForm: wasteForm,
            weightCategory: weightCategory,
            itemPrice: itemPrice,
          );
          marketVm.addListing(order);
        },
      ),
    );
  }

}
