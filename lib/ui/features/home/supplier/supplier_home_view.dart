import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../../ui/features/auth/viewmodels/login_viewmodel.dart';
import 'viewmodels/supplier_home_viewmodel.dart';
import 'tabs/supplier_home_tab.dart';
import 'tabs/supplier_orders_tab.dart';
import 'tabs/supplier_profile_tab.dart';
import 'widgets/new_order_sheet.dart';
import 'widgets/supplier_bottom_nav.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/widgets/post_to_market_sheet.dart';

class SupplierHomeView extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const SupplierHomeView({
    super.key,
    required this.userName,
    required this.supplierType,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => SupplierHomeViewModel(ctx.read<AppOrderStore>())),
        ChangeNotifierProvider(create: (ctx) => MarketplaceViewModel(ctx.read<AppOrderStore>())),
      ],
      child: _SupplierHomeBody(userName: userName, supplierType: supplierType),
    );
  }
}

class _SupplierHomeBody extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const _SupplierHomeBody({required this.userName, required this.supplierType});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SupplierHomeViewModel>();

    final tabs = [
      SupplierHomeTab(userName: userName, supplierType: supplierType),
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
        supplierType: supplierType,
        onUpdateProfile: vm.updateProfile,
      ),
    ];

    final marketVm = context.watch<MarketplaceViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    SupplierHomeViewModel vm,
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
    SupplierHomeViewModel vm,
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
