import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../data/models/order.dart';
import '../../../../../data/services/app_order_store.dart';
import 'viewmodels/driver_home_viewmodel.dart';
import 'tabs/driver_home_tab.dart';
import 'tabs/driver_orders_tab.dart';
import 'tabs/driver_profile_tab.dart';
import 'widgets/driver_nav_item.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import 'tabs/driver_earnings_tab.dart';
import 'viewmodels/driver_earnings_viewmodel.dart';
import '../shared/widgets/post_to_market_sheet.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import '../../../../../l10n/l10n.dart';

class DriverHomeView extends StatelessWidget {
  final String userName;
  final List<String> aiSuggestedCategories;

  const DriverHomeView({
    super.key,
    required this.userName,
    this.aiSuggestedCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppOrderStore>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriverHomeViewModel(store, userName: userName)),
        ChangeNotifierProvider(
          create: (_) => MarketplaceViewModel(
            store,
            initialSuggestions: aiSuggestedCategories,
          ),
        ),
        ChangeNotifierProvider(create: (_) => DriverEarningsViewModel(store)),
      ],
      child: _DriverHomeBody(userName: userName),
    );
  }
}

class _DriverHomeBody extends StatelessWidget {
  final String userName;
  const _DriverHomeBody({required this.userName});

  void _handleAcceptOrder(
      BuildContext context, DriverHomeViewModel vm, order) {
    vm.acceptOrder(order).then((error) {
      if (error != null && context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(context.l10n.alert,
                textAlign: TextAlign.right,
                style:
                    GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            content: Text(error,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.ok,
                    style: GoogleFonts.cairo(
                        color: const Color(0xFF06402B),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    });
  }

  void _handleToggleAvailability(
      BuildContext context, DriverHomeViewModel vm, bool value) {
    final error = vm.toggleAvailability(value);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverHomeViewModel>();

    final tabs = [
      DriverHomeTab(
        userName: userName,
        isAvailable: vm.isAvailable,
        onToggleAvailability: (val) =>
            _handleToggleAvailability(context, vm, val),
        available: vm.available,
        history: vm.history,
        active: vm.active,
        onAcceptOrder: (order) =>
            _handleAcceptOrder(context, vm, order),
        onCompleteOrder: vm.completeOrder,
      ),
      MarketplaceTab(
        role: UserRole.driver,
        currentUserName: userName,
        onJobAccepted: (sale) {
          vm.setTab(2);
          if (sale != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CollectionSaleDetailView(sale: sale),
            ));
          }
        },
      ),
      DriverOrdersTab(
        history: vm.history,
        active: vm.active,
        collectionSaleOrders: vm.collectionSaleOrders,
        onCompleteOrder: vm.completeOrder,
        onCancelSale: (id) => vm.cancelCollectionSale(id),
        onStartTransit: vm.startCollectionSaleTransit,
        onComplete: vm.completeCollectionSale,
      ),
      const DriverEarningsTab(),
      const DriverProfileTab(),
    ];

    final marketVm = context.watch<MarketplaceViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: vm.currentTab,
        children: tabs,
      ),
      floatingActionButton: vm.currentTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showPostToMarketSheet(context, vm, marketVm),
              backgroundColor: const Color(0xFF1E40AF),
              icon: const Icon(Icons.storefront_rounded, color: Colors.white),
              label: Text(
                context.l10n.driverPublishToMarket,
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: _buildBottomNav(context, vm),
    );
  }

  void _showPostToMarketSheet(
    BuildContext context,
    DriverHomeViewModel vm,
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
    );
  }

  Widget _buildBottomNav(
      BuildContext context, DriverHomeViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DriverNavItem(
                icon: Icons.home_rounded,
                label: context.l10n.navHome,
                isSelected: vm.currentTab == 0,
                onTap: () => vm.setTab(0),
              ),
              DriverNavItem(
                icon: Icons.storefront_rounded,
                label: context.l10n.navMarket,
                isSelected: vm.currentTab == 1,
                onTap: () => vm.setTab(1),
              ),
              DriverNavItem(
                icon: Icons.receipt_long_rounded,
                label: context.l10n.navMyOrders,
                isSelected: vm.currentTab == 2,
                onTap: () => vm.setTab(2),
              ),
              DriverNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'أرباحي',
                isSelected: vm.currentTab == 3,
                onTap: () => vm.setTab(3),
              ),
              DriverNavItem(
                icon: Icons.person_rounded,
                label: context.l10n.navProfile,
                isSelected: vm.currentTab == 4,
                onTap: () => vm.setTab(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
