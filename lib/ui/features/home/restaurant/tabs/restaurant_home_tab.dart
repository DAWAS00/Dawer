import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../shared/order_details_view.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';
import '../../shared/widgets/market_listing_card.dart';
import '../../../../../l10n/l10n.dart';
import '../viewmodels/restaurant_home_viewmodel.dart';

import '../../shared/widgets/home/app_header.dart';
import '../../shared/widgets/home/kpi_row.dart';
import '../../shared/widgets/home/driver_bar.dart';
import '../../shared/widgets/home/order_card.dart';
import '../../shared/widgets/home/section_header.dart';

class RestaurantHomeTab extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const RestaurantHomeTab({
    super.key,
    required this.userName,
    required this.supplierType,
  });

  void _deleteMarketListing(BuildContext context, String orderId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ctx.l10n.withdrawListing, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(ctx.l10n.withdrawListingConfirm, textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.no, style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MarketplaceViewModel>().removeListing(orderId);
            },
            child: Text(ctx.l10n.yesWithdraw, style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantHomeViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();
    final tracked = vm.trackedOrder;
    final active = vm.activeOrders;
    final myListings = marketVm.myListings(vm.user.name);

    return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HomeAppHeader(
              userName: userName,
              subtitle: 'مورد تجاري (مطعم)',
              points: vm.totalPoints,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: HomeKpiRow(
              activeCount: active.length,
              earnings: 12.5, // Mock
              avgEta: 15, // Mock
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (tracked != null)
            SliverToBoxAdapter(
              child: HomeDriverBar(
                name: tracked.driverName ?? 'سائق دوّر',
                rating: tracked.driverRating ?? 4.8,
                etaMinutes: tracked.etaMinutes?.toString() ?? '١٥',
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          if (myListings.isNotEmpty) ..._buildMyListingsSection(context, myListings),
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: context.l10n.supplierActiveOrders,
              count: active.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (active.isNotEmpty)
            SliverList.separated(
              itemCount: active.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => HomeOrderCard(
                order: active[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsView(
                      order: active[i],
                      onSupplierConfirmArrival: (available) {
                        final store = context.read<AppOrderStore>();
                        if (available) {
                          store.handleSupplierAvailable(active[i].id);
                        } else {
                          store.handleSupplierUnavailable(active[i].id);
                        }
                      },
                    ),
                  ),
                ),
              ),
            )
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.supplierNoOrdersYet,
                      style: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF717973)),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      );
  }

  List<Widget> _buildMyListingsSection(BuildContext context, List<Order> listings) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${listings.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.supplierMyListings,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MarketListingCard(
                order: listings[i],
                onDelete: listings[i].status == OrderStatus.pending
                    ? () => _deleteMarketListing(context, listings[i].id)
                    : null,
              ),
            ),
            childCount: listings.length,
          ),
        ),
      ),
    ];
  }
}
