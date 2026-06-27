import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/mock/order_mock_data.dart';
import '../../../../../data/models/hub.dart';
import '../../../../../data/models/order/order.dart';
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
import '../../../../core/components/dwaar_skeleton.dart';
import '../views/order_preview_view.dart';

class DriverHomeTab extends StatelessWidget {
  final String userName;
  final bool isAvailable;
  final ValueChanged<bool> onToggleAvailability;
  final List<Order> available;
  final List<Order> history;
  final Order? active;
  final Future<String?> Function(Order) onAcceptOrder;
  final ValueChanged<Order>? onCompleteOrder;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;

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
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
  });

  @override
  Widget build(BuildContext context) {
    final driverVm = context.watch<DriverHomeViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();
    final myListings = marketVm.myListings(driverVm.user.name);
    final activeOrders = [if (driverVm.active != null) driverVm.active!];
    final loading = driverVm.isLoading;
    final displayAvailable = loading ? OrderMockData.skeletonOrders() : available;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DriverHomeHeader(
            userName: userName,
            isOnline: isAvailable,
            onStatusToggle: (val) {
              // Handle toggle here — context is inside the Scaffold subtree so
              // ScaffoldMessenger finds the right messenger for the snackbar.
              final error = driverVm.toggleAvailability(val);
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error, style: GoogleFonts.cairo()),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            totalEarnings: driverVm.totalEarnings,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // KPI row
        SliverToBoxAdapter(
          child: DwaarSkeleton(
            enabled: loading,
            child: DriverKpiRow(
              earnings: driverVm.totalEarnings,
              completedCount: driverVm.totalCompletedRides,
              rating: 5.0,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // ── Hubs ──
        if (driverVm.hubsError != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _HubsErrorBanner(message: driverVm.hubsError!),
            ),
          )
        else if (driverVm.hubs.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: 'مراكز التسليم المتاحة',
              count: driverVm.hubs.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: driverVm.hubs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _HubChip(hub: driverVm.hubs[i]),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],

        // ── Active Orders ──
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: activeOrders.isNotEmpty
                ? Column(
                    key: const ValueKey('active_orders_list'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: HomeSectionHeader(
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
                                        onMarkArrivedAtPickup: onMarkArrivedAtPickup,
                                        onMarkArrivedAtDropoff: onMarkArrivedAtDropoff,
                                        hideStatus: true,
                                        isDriverView: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ).animate().scale(
                              begin: const Offset(0.95, 0.95),
                              duration: 400.ms,
                              curve: Curves.easeOutCubic)),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),

        // ── My Listings ──
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
                  builder: (_) => OrderDetailsView(order: myListings[i], isDriverView: true),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],

        // ── Offline / Available orders ──
        if (!isAvailable)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: _OfflineStateCard(onEnable: () => onToggleAvailability(true)),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: HomeSectionHeader(
              title: context.l10n.driverAvailableOrders,
              count: loading ? 0 : available.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          if (!loading && available.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _EmptyOrdersCard(),
              ),
            )
          else
            SliverToBoxAdapter(
              child: DwaarSkeleton(
                enabled: loading,
                child: Column(
                  children: [
                    for (int i = 0; i < displayAvailable.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      loading
                          ? DriverAvailableOrderCard(
                              order: displayAvailable[i],
                              onAccept: () async => null,
                            )
                          : Hero(
                              tag: 'order_${displayAvailable[i].id}',
                              child: DriverAvailableOrderCard(
                                order: displayAvailable[i],
                                onAccept: () => onAcceptOrder(displayAvailable[i]),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderPreviewView(
                                      order: displayAvailable[i],
                                      onAccept: onAcceptOrder,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ],
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
        title: Text(context.l10n.withdrawListing,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(context.l10n.withdrawListingConfirm,
            textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.no,
                style: GoogleFonts.cairo(color: AppColors.mutedText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              marketVm.removeListing(orderId);
            },
            child: Text(context.l10n.yesWithdraw,
                style: GoogleFonts.cairo(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Hub widgets ──

class _HubsErrorBanner extends StatelessWidget {
  const _HubsErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusCancelledBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.statusCancelledText.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.triangleAlert,
              size: 16, color: AppColors.statusCancelledText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'مراكز التسليم غير متاحة — تحقق من الاتصال',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.statusCancelledText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubChip extends StatelessWidget {
  const _HubChip({required this.hub});
  final Hub hub;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (hub.status) {
      'ready' => AppColors.statusActiveText,
      'collecting' => AppColors.statusInTransitText,
      _ => AppColors.mutedText,
    };
    final statusBg = switch (hub.status) {
      'ready' => AppColors.statusActiveBg,
      'collecting' => AppColors.statusInTransitBg,
      _ => AppColors.borderSubtle,
    };

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.warehouse,
                  size: 13, color: AppColors.primaryGreen),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  hub.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
          Text(
            hub.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: AppColors.mutedText,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hub.status == 'ready'
                  ? 'جاهز'
                  : hub.status == 'collecting'
                      ? 'يجمع'
                      : hub.status,
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Offline state cards ──

class _OfflineStateCard extends StatelessWidget {
  const _OfflineStateCard({required this.onEnable});
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderSubtle,
          style: BorderStyle.solid,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.amberContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              LucideIcons.wifiOff,
              size: 30,
              color: AppColors.accentAmber,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'غير متاح للعمل',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'فعّل وضع التوفر لاستقبال الطلبات الجديدة',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onEnable,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'تفعيل الآن',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0, duration: 300.ms);
  }
}

class _EmptyOrdersCard extends StatelessWidget {
  const _EmptyOrdersCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.inbox,
              size: 26,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد طلبات متاحة حالياً',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ستصلك إشعارات عند توفر طلبات جديدة',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
