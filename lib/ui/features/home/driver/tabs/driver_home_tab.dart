import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import 'package:provider/provider.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';
import '../../shared/widgets/market_listing_card.dart';
import '../viewmodels/driver_home_viewmodel.dart';
import '../widgets/driver_stat_card.dart';

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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverToBoxAdapter(child: _buildStatsRow()),
        if (active != null)
          SliverToBoxAdapter(child: _buildActiveBanner(context)),
        if (myListings.isNotEmpty) ..._buildMyListingsSection(context, myListings, marketVm),
        if (!isAvailable)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 64, color: Color(0xFFC0C9C1)),
                  const SizedBox(height: 16),
                  Text(
                    'أنت غير متاح حالياً',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF404943),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بتغيير حالتك إلى متاح بالأعلى لاستقبال طلبات جديدة',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF717973),
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'الطلبات المتاحة',
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: available.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'لا توجد طلبات متاحة حالياً',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: const Color(0xFF717973),
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OrderCard(
                          order: available[i],
                          mode: OrderCardMode.driverAvailable,
                          onAction: () => onAcceptOrder(available[i]),
                        ),
                      ),
                      childCount: available.length,
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildMyListingsSection(
    BuildContext context,
    List<Order> listings,
    MarketplaceViewModel marketVm,
  ) {
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
                '\u0645\u0646\u0634\u0648\u0631\u0627\u062a\u064a \u0641\u064a \u0627\u0644\u0633\u0648\u0642',
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
                    ? () => _confirmDeleteListing(context, listings[i].id, marketVm)
                    : null,
              ),
            ),
            childCount: listings.length,
          ),
        ),
      ),
    ];
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
        title: Text('\u0633\u062d\u0628 \u0627\u0644\u0625\u0639\u0644\u0627\u0646', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('\u0647\u0644 \u062a\u0631\u064a\u062f \u0633\u062d\u0628 \u0647\u0630\u0627 \u0627\u0644\u0625\u0639\u0644\u0627\u0646 \u0645\u0646 \u0627\u0644\u0633\u0648\u0642\u061f', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('\u0644\u0627', style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              marketVm.removeListing(orderId);
            },
            child: Text('\u0646\u0639\u0645\u060c \u0633\u062d\u0628', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06402B), Color(0xFF0A5E3E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: Text(
                  userName.isNotEmpty ? userName[0] : 'س',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً، ${userName.split(' ').first}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'سائق دوّر',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onToggleAvailability(!isAvailable),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.shade300
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isAvailable ? Colors.white : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAvailable ? 'متاح' : 'غير متاح',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getActiveOrdersCount() {
    int count = active != null ? 1 : 0;
    count += history.where((o) => o.status == OrderStatus.accepted).length;
    return count;
  }

  int _getCompletedOrdersCount() {
    return history.where((o) => o.status == OrderStatus.completed).length;
  }

  double _getTotalEarnings() {
    double total = 0.0;
    for (final order in history) {
      if (order.status == OrderStatus.completed) {
        total += order.reward;
      }
    }
    return total;
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
              child: DriverStatCard(
                  value: _getActiveOrdersCount().toString(),
                  label: 'طلب نشط',
                  icon: Icons.local_shipping_rounded,
                  color: AppColors.statusInTransitText)),
          const SizedBox(width: 10),
          Expanded(
              child: DriverStatCard(
                  value: _getCompletedOrdersCount().toString(),
                  label: 'الطلبات المكتملة',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.statusCompletedText)),
          const SizedBox(width: 10),
          Expanded(
              child: DriverStatCard(
                  value: _getTotalEarnings().toStringAsFixed(1),
                  label: 'الأرباح (د.أ)',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.accentAmber)),
        ],
      ),
    );
  }

  Widget _buildActiveBanner(BuildContext context) {
    final order = active!;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                'رحلتك الحالية',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      order.eta ?? '--',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.pickupAddress,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 6),
              Container(width: 1, height: 16, color: Colors.white38),
            ],
          ),
          Text(
            order.dropoffAddress,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsView(
                    order: order,
                    onCompleteOrder: onCompleteOrder,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'عرض التفاصيل',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
