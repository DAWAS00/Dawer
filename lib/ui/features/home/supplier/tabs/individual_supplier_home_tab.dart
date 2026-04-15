import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../viewmodels/individual_supplier_viewmodel.dart';

class IndividualSupplierHomeTab extends StatelessWidget {
  final String userName;

  const IndividualSupplierHomeTab({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IndividualSupplierViewModel>();
    final tracked = vm.trackedOrder;
    final active = vm.activeOrders;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, vm)),
        if (tracked != null)
          SliverToBoxAdapter(child: _buildTrackingCard(context, tracked)),
        if (active.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.ctaGradientStart.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${active.length}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ctaGradientStart,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'طلباتي النشطة',
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
                        builder: (_) => OrderDetailsView(order: active[i]),
                      ),
                    ),
                  ),
                ),
                childCount: active.length,
              ),
            ),
          ),
        ] else
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طلبات نشطة',
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اضغط على زر + أسفل الشاشة لإنشاء طلب جديد',
                    style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, IndividualSupplierViewModel vm) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.headerGradientEnd],
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
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً، ${userName.split(' ').first}',
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
              ),
              Text(
                'مورد فردي',
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
                  'نقطة',
                  style: GoogleFonts.cairo(fontSize: 10, color: AppColors.accentAmber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailsView(order: order)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              'تتبع',
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.statusInTransitText),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppColors.statusInTransitText, size: 20),
            const Spacer(),
            Flexible(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (order.eta != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.statusInTransitBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.eta!,
                          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.statusInTransitText),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      'السائق في الطريق إليك',
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      order.driverName ?? '',
                      style: GoogleFonts.cairo(fontSize: 13, color: AppColors.mutedText),
                    ),
                    const SizedBox(width: 8),
                    if (order.driverRating != null) ...[
                      Text(
                        order.driverRating.toString(),
                        style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedText),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                    ],
                  ],
                ),
              ],
            ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.statusInTransitBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: AppColors.statusInTransitText, size: 24),
            ),
          ],
        ),
      ),
    );
  }

}
