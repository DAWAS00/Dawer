import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import '../../../common/app_nav_item.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/widgets/post_to_market_sheet.dart';
import 'tabs/recycling_home_tab.dart';
import 'tabs/recycling_orders_tab.dart';
import 'tabs/recycling_profile_tab.dart';
import 'viewmodels/recycling_home_viewmodel.dart';

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
    );
  }

  Widget _buildBottomNav(BuildContext context, RecyclingHomeViewModel vm) {
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
              AppNavItem(icon: Icons.home_rounded, label: 'الرئيسية', isSelected: vm.currentTab == 0, onTap: () => vm.setTab(0)),
              AppNavItem(icon: Icons.storefront_rounded, label: 'السوق', isSelected: vm.currentTab == 1, onTap: () => vm.setTab(1)),
              AppNavItem(icon: Icons.receipt_long_rounded, label: 'الطلبات', isSelected: vm.currentTab == 2, onTap: () => vm.setTab(2)),
              AppNavItem(icon: Icons.business_rounded, label: 'حسابي', isSelected: vm.currentTab == 3, onTap: () => vm.setTab(3)),
            ],
          ),
        ),
      ),
    );
  }
}

