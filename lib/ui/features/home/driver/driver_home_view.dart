import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dwaar/ui/common/widgets/dev_testing_panel.dart';

import '../../../../../data/models/order/order.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../core/constants/app_colors.dart';
import 'viewmodels/driver_home_viewmodel.dart';
import 'tabs/driver_home_tab.dart';
import 'tabs/driver_orders_tab.dart';
import 'tabs/driver_profile_tab.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/views/collection_sale_detail_view.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../supplier/views/new_pickup_request_view.dart';
import 'views/pickup_proof_view.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import '../../../../../domain/repositories/i_hub_repository.dart';
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
    final hubRepo = context.read<IHubRepository>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DriverHomeViewModel(store, hubRepository: hubRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketplaceViewModel(
            store,
            isBusiness: false,
            initialSuggestions: aiSuggestedCategories,
          ),
        ),
      ],
      child: _DriverHomeBody(userName: userName),
    );
  }
}

class _DriverHomeBody extends StatelessWidget {
  final String userName;
  const _DriverHomeBody({required this.userName});

  Future<String?> _handleAcceptOrder(
      BuildContext context, DriverHomeViewModel vm, order) async {
    final error = await vm.acceptOrder(order, context.l10n);
    if (error != null && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(context.l10n.alert,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(error,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.ok,
                  style: GoogleFonts.cairo(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
    return error;
  }

  void _handleToggleAvailability(
      BuildContext context, DriverHomeViewModel vm, bool value) {
    final error = vm.toggleAvailability(value, context.l10n);
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
        onAcceptOrder: (order) => _handleAcceptOrder(context, vm, order),
        onCompleteOrder: vm.completeOrder,
        onMarkArrivedAtPickup: (order) async {
          final l10n = context.l10n;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PickupProofView(
                order: order,
                onConfirm: (proof) =>
                    vm.markArrivedAtPickup(order, l10n, pickupProof: proof),
              ),
            ),
          );
          return null;
        },
        onMarkArrivedAtDropoff: (order) => vm.markArrivedAtDropoff(order, context.l10n),
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
        onMarkArrivedAtPickup: (order) async {
          final l10n = context.l10n;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PickupProofView(
                order: order,
                onConfirm: (proof) =>
                    vm.markArrivedAtPickup(order, l10n, pickupProof: proof),
              ),
            ),
          );
          return null;
        },
        onMarkArrivedAtDropoff: (order) => vm.markArrivedAtDropoff(order, context.l10n),
      ),
      const DriverProfileTab(),
    ];

    final marketVm = context.watch<MarketplaceViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          ? FloatingActionButton.extended(
              onPressed: () {
                if (!marketVm.canAddListing(vm.user.name)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'وصلت للحد الأقصى (${marketVm.maxListings} إعلانات نشطة)',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: const Color(0xFFB91C1C),
                    behavior: SnackBarBehavior.floating,
                  ));
                  return;
                }
                _showPostToMarketSheet(context, vm, marketVm);
              },
              backgroundColor: const Color(0xFF1E40AF),
              icon: const Icon(Icons.storefront_rounded, color: Colors.white),
              label: Text(
                context.l10n.driverPublishToMarket,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, color: Colors.white),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPickupRequestView(
          role: UserRole.driver,
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

  Widget _buildBottomNav(BuildContext context, DriverHomeViewModel vm) {
    return NavigationBar(
      selectedIndex: vm.currentTab,
      onDestinationSelected: vm.setTab,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.12),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primaryGreen),
          label: context.l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.store),
          selectedIcon: const Icon(LucideIcons.store, color: AppColors.primaryGreen),
          label: context.l10n.navMarket,
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: vm.active != null,
            backgroundColor: Colors.red,
            child: const Icon(Icons.receipt_long_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: vm.active != null,
            backgroundColor: Colors.red,
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryGreen),
          ),
          label: context.l10n.navMyOrders,
        ),
        NavigationDestination(
          icon: const Icon(LucideIcons.user),
          selectedIcon: const Icon(LucideIcons.user, color: AppColors.primaryGreen),
          label: context.l10n.navProfile,
        ),
      ],
    );
  }
}
