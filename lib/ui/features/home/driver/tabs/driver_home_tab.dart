import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';
import '../viewmodels/driver_home_viewmodel.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';
import '../widgets/driver_home_header.dart';
import '../widgets/driver_kpi_row.dart';
import '../widgets/driver_active_order_card.dart';
import '../widgets/driver_available_order_card.dart';
import '../widgets/driver_listing_card.dart';
import '../../shared/widgets/home/section_header.dart';
import '../../shared/order_details_view.dart';

class DriverHomeTab extends StatelessWidget {
  final String userName;
  final bool isAvailable;
  final ValueChanged<bool> onToggleAvailability;
  final List<Order> available;
  final List<Order> history;
  final Order? active; 
  final ValueChanged<Order> onAcceptOrder;
  final ValueChanged<Order>? onCompleteOrder;

  const DriverHomeTab({
    super.key,
    required this.userName,
    required this.isAvailable,
    required this.onToggleAvailability,
    required this.available,
    required this.history,
    required this.active,
    required this.onAcceptOrder,
    this.onCompleteOrder,
  });

  @override
  Widget build(BuildContext context) {
    final driverVm = context.watch<DriverHomeViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();
    final myListings = marketVm.myListings(driverVm.user.name);
    final activeOrders = [if (driverVm.active != null) driverVm.active!];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DriverHomeHeader(
            userName: userName,
            isOnline: isAvailable,
            onStatusToggle: onToggleAvailability,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child: DriverKpiRow(
            earnings: driverVm.totalEarnings,
            completedCount: driverVm.totalCompletedRides,
            activeCount: activeOrders.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // --- Active Orders Section (Animated List) ---
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: activeOrders.isNotEmpty
                ? Column(
                    key: const ValueKey('active_orders_list'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: const HomeSectionHeader(
                          title: 'الطلب النشط الحالي',
                          count: 1,
                        ),
                      ),
                      ...activeOrders.map((order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Hero(
                          tag: 'order_${order.id}',
                          child: DriverActiveOrderCard(
                            order: order,
                            onConfirmArrival: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsView(
                                    order: order,
                                    onCompleteOrder: onCompleteOrder,
                                    hideStatus: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ).animate().scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOutCubic),
                      )),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),

        if (myListings.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: 'منشوراتي في السوق',
              count: myListings.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverList.separated(
            itemCount: myListings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => DriverListingCard(
              order: myListings[i],
              onDelete: myListings[i].status == OrderStatus.pending
                  ? () => _confirmDeleteListing(context, myListings[i].id, marketVm)
                  : null,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsView(order: myListings[i]),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],

        if (!isAvailable)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.driverUnavailableTitle,
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF404943)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.driverUnavailableSubtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF717973)),
                  ),
                ],
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: context.l10n.driverAvailableOrders,
              count: available.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (available.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    context.l10n.driverNoAvailableOrders,
                    style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF717973)),
                  ),
                ),
              ),
            )
          else
            SliverList.separated(
              itemCount: available.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => Hero(
                tag: 'order_${available[i].id}',
                child: DriverAvailableOrderCard(
                  order: available[i],
                  onAccept: () => onAcceptOrder(available[i]),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsView(order: available[i]),
                    ),
                  ),
                ),
              ),
            ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  void _confirmDeleteListing(
    BuildContext context,
    String orderId,
    MarketplaceViewModel marketVm,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.withdrawListing, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(context.l10n.withdrawListingConfirm, textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.no, style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              marketVm.removeListing(orderId);
            },
            child: Text(context.l10n.yesWithdraw, style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
