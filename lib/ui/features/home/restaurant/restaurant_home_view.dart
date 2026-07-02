import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';
import '../shared/viewmodels/base_supplier_viewmodel.dart';
import 'viewmodels/restaurant_home_viewmodel.dart';
import 'tabs/restaurant_home_tab.dart';
import '../supplier/tabs/supplier_orders_tab.dart';
import '../supplier/tabs/supplier_profile_tab.dart';
import '../supplier/widgets/supplier_bottom_nav.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../supplier/views/new_pickup_request_view.dart';
import 'package:dwaar/ui/common/widgets/dev_testing_panel.dart';

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
        ChangeNotifierProvider<BaseSupplierViewModel>(
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
      child: _RestaurantHomeBody(
        userName: userName,
        supplierType: supplierType,
      ),
    );
  }
}

class _RestaurantHomeBody extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const _RestaurantHomeBody({
    required this.userName,
    required this.supplierType,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BaseSupplierViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();

    final tabs = [
      RestaurantHomeTab(userName: userName),
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
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CollectionSaleDetailView(sale: sale),
              ),
            );
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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(index: vm.currentTab, children: tabs),
          if (kDebugMode) const DevTestingPanel(),
        ],
      ),
      floatingActionButton: vm.currentTab == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!marketVm.canAddListing(vm.user.name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'وصلت للحد الأقصى (${marketVm.maxListings} إعلانات نشطة)',
                      ),
                      backgroundColor: const Color(0xFFB91C1C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewPickupRequestView(
                      role: UserRole.supplier,
                      initialMode: OrderMode.marketplace,
                      onSubmit:
                          ({
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
              },
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'إضافة عرض',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: SupplierBottomNav(
        currentTab: vm.currentTab,
        onTabChanged: vm.setTab,
      ),
    );
  }
}
