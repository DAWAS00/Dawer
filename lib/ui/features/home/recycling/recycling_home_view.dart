import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import '../../auth/viewmodels/login_viewmodel.dart';
import '../shared/tabs/marketplace_tab.dart';
import '../shared/viewmodels/marketplace_viewmodel.dart';
import '../shared/widgets/post_to_market_sheet.dart';
import 'tabs/recycling_home_tab.dart';
import 'tabs/recycling_orders_tab.dart';
import 'tabs/recycling_profile_tab.dart';
import 'viewmodels/recycling_home_viewmodel.dart';

class RecyclingHomeView extends StatelessWidget {
  final String userName;
  const RecyclingHomeView({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => RecyclingHomeViewModel(ctx.read<AppOrderStore>())),
        ChangeNotifierProvider(create: (ctx) => MarketplaceViewModel(ctx.read<AppOrderStore>())),
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
      RecyclingOrdersTab(incoming: vm.incoming, jobs: vm.jobs),
      RecyclingProfileTab(userName: userName),
    ];

    final marketVm = context.watch<MarketplaceViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
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
      bottomNavigationBar: _buildBottomNav(vm),
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
        }) {
          final order = recyclingVm.createListing(
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

  Widget _buildBottomNav(RecyclingHomeViewModel vm) {
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'الرئيسية', isSelected: vm.currentTab == 0, onTap: () => vm.setTab(0)),
              _NavItem(icon: Icons.storefront_rounded, label: 'السوق', isSelected: vm.currentTab == 1, onTap: () => vm.setTab(1)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'الطلبات', isSelected: vm.currentTab == 2, onTap: () => vm.setTab(2)),
              _NavItem(icon: Icons.business_rounded, label: 'حسابي', isSelected: vm.currentTab == 3, onTap: () => vm.setTab(3)),
            ],
          ),
        ),
      ),
    );
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF14401F).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF14401F)
                  : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF14401F)
                  : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
