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
import '../shared/widgets/post_to_market_sheet.dart';
import '../../auth/viewmodels/login_viewmodel.dart';

class DriverHomeView extends StatelessWidget {
  final String userName;
  const DriverHomeView({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppOrderStore>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => DriverHomeViewModel(store)),
        ChangeNotifierProvider(
            create: (_) => MarketplaceViewModel(store)),
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
    final error = vm.acceptOrder(order);
    if (error != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('تنبيه',
              textAlign: TextAlign.right,
              style:
                  GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(error,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('حسناً',
                  style: GoogleFonts.cairo(
                      color: const Color(0xFF06402B),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
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
      const DriverOrdersTab(),
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
                'نشر في السوق',
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
                label: 'الرئيسية',
                isSelected: vm.currentTab == 0,
                onTap: () => vm.setTab(0),
              ),
              DriverNavItem(
                icon: Icons.storefront_rounded,
                label: 'السوق',
                isSelected: vm.currentTab == 1,
                onTap: () => vm.setTab(1),
              ),
              DriverNavItem(
                icon: Icons.receipt_long_rounded,
                label: 'طلباتي',
                isSelected: vm.currentTab == 2,
                onTap: () => vm.setTab(2),
              ),
              DriverNavItem(
                icon: Icons.person_rounded,
                label: 'الملف',
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
