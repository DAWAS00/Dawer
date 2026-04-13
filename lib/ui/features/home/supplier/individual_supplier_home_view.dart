import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';
import 'viewmodels/individual_supplier_viewmodel.dart';
import 'tabs/individual_supplier_home_tab.dart';
import 'tabs/supplier_orders_tab.dart';
import 'tabs/supplier_profile_tab.dart';
import 'widgets/supplier_nav_item.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/widgets/pickup_fab.dart';
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
        onSupplierPurchaseConfirmed: (purchasedOrder) {
          vm.addOrder(purchasedOrder);
          vm.setTab(2);
        },
      ),
      SupplierOrdersTab(
        activeOrders: vm.activeOrders,
        completedOrders: vm.completedOrders,
        cancelledOrders: vm.cancelledOrders,
        onCancelOrder: vm.cancelOrder,
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
          ? PickupFab(onPressed: () => _showPostToMarketSheet(context, vm, marketVm))
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: _buildBottomNav(context, vm),
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

  Widget _buildBottomNav(BuildContext context, IndividualSupplierViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SupplierNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isSelected: vm.currentTab == 0,
                onTap: () => vm.setTab(0),
              ),
              SupplierNavItem(
                icon: Icons.storefront_rounded,
                label: 'السوق',
                isSelected: vm.currentTab == 1,
                onTap: () => vm.setTab(1),
              ),
              SupplierNavItem(
                icon: Icons.receipt_long_rounded,
                label: 'طلباتي',
                isSelected: vm.currentTab == 2,
                onTap: () => vm.setTab(2),
              ),
              SupplierNavItem(
                icon: Icons.person_rounded,
                label: 'حسابي',
                isSelected: vm.currentTab == 3,
                onTap: () => vm.setTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
