import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';

import 'viewmodels/supplier_home_viewmodel.dart';
import 'tabs/supplier_home_tab.dart';
import 'tabs/supplier_orders_tab.dart';
import 'tabs/supplier_profile_tab.dart';
import 'widgets/supplier_bottom_nav.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/widgets/pickup_fab.dart';
import 'views/new_pickup_request_view.dart';

class SupplierHomeView extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;
  final List<String> aiSuggestedCategories;

  const SupplierHomeView({
    super.key,
    required this.userName,
    required this.supplierType,
    this.aiSuggestedCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => SupplierHomeViewModel(ctx.read<AppOrderStore>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MarketplaceViewModel(
            ctx.read<AppOrderStore>(),
            isBusiness: supplierType == SupplierType.storeBusiness,
            initialSuggestions: aiSuggestedCategories,
          ),
        ),
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
      SupplierHomeTab(userName: userName),
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
      SupplierProfileTab(
        user: vm.user,
        totalPoints: vm.totalPoints,
        totalOrders: vm.totalOrders,
        supplierType: supplierType,
        onUpdateProfile: vm.updateProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: vm.currentTab,
        children: tabs,
      ),
      floatingActionButton: vm.currentTab == 0
          ? PickupFab(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: vm,
                  child: const NewPickupRequestView(),
                ),
              ));
            })
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: SupplierBottomNav(
        currentTab: vm.currentTab,
        onTabChanged: vm.setTab,
      ),
    );
  }
}
