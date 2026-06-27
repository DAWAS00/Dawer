import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import '../../../common/app_nav_item.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../supplier/views/new_pickup_request_view.dart';
import 'tabs/recycling_home_tab.dart';
import 'tabs/recycling_orders_tab.dart';
import 'tabs/recycling_profile_tab.dart';
import 'viewmodels/recycling_home_viewmodel.dart';
import 'package:dwaar/ui/common/widgets/dev_testing_panel.dart';
import '../../../../l10n/l10n.dart';

class RecyclingHomeView extends StatelessWidget {
  final String userName;
  final List<String> aiSuggestedCategories;

  const RecyclingHomeView({
    super.key,
    required this.userName,
    this.aiSuggestedCategories = const [],
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => RecyclingHomeViewModel(ctx.read<AppOrderStore>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MarketplaceViewModel(
            ctx.read<AppOrderStore>(),
            isBusiness: true,
            initialSuggestions: aiSuggestedCategories,
          ),
        ),
      ],
      child: _RecyclingHomeBody(userName: userName),
    );
  }
}

class _RecyclingHomeBody extends StatelessWidget {
  final String userName;
  const _RecyclingHomeBody({required this.userName});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<RecyclingHomeViewModel>();

    final tabs = [
      RecyclingHomeTab(
        userName: userName,
        isOpen: vm.isOpen,
        onToggleOpen: vm.toggleOpen,
        incoming: vm.incoming,
        jobs: vm.jobs,
      ),
      MarketplaceTab(role: UserRole.recyclingCo, currentUserName: userName),
      RecyclingOrdersTab(incoming: vm.incoming, jobs: vm.jobs, salesForJob: vm.salesForJob),
      RecyclingProfileTab(userName: userName),
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
                if (!marketVm.canAddListing(vm.companyName)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      l10n.recyclingMaxListingsReached(marketVm.maxListings),
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
                l10n.postMarketTitle,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: _buildBottomNav(context, vm),
    );
  }

  void _showPostToMarketSheet(
    BuildContext context,
    RecyclingHomeViewModel recyclingVm,
    MarketplaceViewModel marketVm,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewPickupRequestView(
          role: UserRole.recyclingCo,
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
            final order = recyclingVm.createListing(
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

  Widget _buildBottomNav(BuildContext context, RecyclingHomeViewModel vm) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AppNavItem(icon: Icons.home_rounded, label: l10n.navHome, isSelected: vm.currentTab == 0, onTap: () => vm.setTab(0)),
              AppNavItem(icon: Icons.storefront_rounded, label: l10n.navMarket, isSelected: vm.currentTab == 1, onTap: () => vm.setTab(1)),
              AppNavItem(icon: Icons.receipt_long_rounded, label: l10n.navOrders, isSelected: vm.currentTab == 2, onTap: () => vm.setTab(2)),
              AppNavItem(icon: Icons.business_rounded, label: l10n.navAccount, isSelected: vm.currentTab == 3, onTap: () => vm.setTab(3)),
            ],
          ),
        ),
      ),
    );
  }
}

