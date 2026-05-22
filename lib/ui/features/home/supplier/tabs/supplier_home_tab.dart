import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';
import '../../shared/widgets/market_listing_card.dart';
import '../../../../../l10n/l10n.dart';
import '../viewmodels/supplier_home_viewmodel.dart';

class SupplierHomeTab extends StatelessWidget {
  final String userName;
  final SupplierType supplierType;

  const SupplierHomeTab({
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
    final vm = context.watch<SupplierHomeViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();
    final tracked = vm.trackedOrder;
    final active = vm.activeOrders;
    final myListings = marketVm.myListings(vm.user.name);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        if (tracked != null)
          SliverToBoxAdapter(child: _buildTrackedOrderBanner(context, tracked)),
        if (myListings.isNotEmpty) ..._buildMyListingsSection(context, myListings),
        if (active.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${active.length}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.supplierActiveOrders,
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
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderCard(
                    order: active[i],
                    mode: OrderCardMode.supplierActive,
                    onAction: () => Navigator.of(context).push(
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
                ),
                childCount: active.length,
              ),
            ),
          ),
        ] else
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

  Widget _buildHeader(BuildContext context) {
    final isStore = supplierType == SupplierType.storeBusiness;
    final vm = context.read<SupplierHomeViewModel>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E5C35), Color(0xFF2D8052)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Icon(
              isStore ? Icons.storefront_rounded : Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.supplierGreeting(userName.split(' ').first),
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
              ),
              Text(
                isStore ? context.l10n.supplierStoreType : context.l10n.supplierIndividualType,
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amberContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  vm.totalPoints.toString(),
                  style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentAmber),
                ),
                Text(
                  context.l10n.supplierPoints,
                  style: GoogleFonts.cairo(fontSize: 10, color: AppColors.accentAmber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackedOrderBanner(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderDetailsView(
            order: order,
            onSupplierConfirmArrival: (available) {
              final store = context.read<AppOrderStore>();
              if (available) {
                store.handleSupplierAvailable(order.id);
              } else {
                store.handleSupplierUnavailable(order.id);
              }
            },
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (order.eta != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.eta!,
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.supplierDriverOnWay,
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order.driverName ?? '',
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(width: 8),
                    if (order.driverRating != null) ...[
                      Text(
                        order.driverRating.toString(),
                        style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

}
