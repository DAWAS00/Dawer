import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';

import 'viewmodels/restaurant_home_viewmodel.dart';
import 'tabs/restaurant_home_tab.dart';
import '../supplier/tabs/supplier_orders_tab.dart';
import '../supplier/tabs/supplier_profile_tab.dart';
import '../supplier/widgets/supplier_bottom_nav.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/widgets/home/new_request_fab.dart';
import '../supplier/views/new_pickup_request_view.dart';

class RestaurantHomeView extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;
  final List<String> aiSuggestedCategories;

  const RestaurantHomeView({
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
          create: (ctx) => RestaurantHomeViewModel(ctx.read<AppOrderStore>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MarketplaceViewModel(
            ctx.read<AppOrderStore>(),
            isBusiness: true,
            initialSuggestions: aiSuggestedCategories,
          ),
        ),
      ],
      child: _RestaurantHomeBody(userName: userName, supplierType: supplierType),
    );
  }
}

class _RestaurantHomeBody extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const _RestaurantHomeBody({required this.userName, required this.supplierType});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantHomeViewModel>();

    final tabs = [
      RestaurantHomeTab(userName: userName, supplierType: supplierType),
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
          ? HomeNewRequestFab(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: vm,
                  child: const NewPickupRequestView(initialMode: OrderMode.marketplace),
                ),
              ));
            }, label: 'إضافة عرض في السوق')
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: SupplierBottomNav(
        currentTab: vm.currentTab,
        onTabChanged: vm.setTab,
      ),
    );
  }
}
