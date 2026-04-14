import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_card.dart';
import '../../shared/order_tracking_card.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';
import '../../shared/widgets/market_listing_card.dart';
import '../viewmodels/recycling_home_viewmodel.dart';
import '../widgets/post_job_sheet.dart';

class RecyclingHomeTab extends StatelessWidget {
  final String userName;
  final bool isOpen;
  final ValueChanged<bool> onToggleOpen;
  final List<Order> incoming;
  final List<Order> jobs;

  const RecyclingHomeTab({
    super.key,
    required this.userName,
    required this.isOpen,
    required this.onToggleOpen,
    required this.incoming,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecyclingHomeViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();
    final myListings = marketVm.myListings(vm.companyName);

    final Order? tracked = incoming
        .where((o) => o.status == OrderStatus.inTransit && o.driverName != null)
        .firstOrNull;

    return CustomScrollView(
      slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            if (tracked != null)
              SliverToBoxAdapter(child: OrderTrackingCard(order: tracked)),
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildActionCards(context)),
            if (myListings.isNotEmpty) ..._buildMyListingsSection(context, myListings, marketVm),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'الشحنات القادمة',
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(order: incoming[i], mode: OrderCardMode.companyIncoming),
                  ),
                  childCount: incoming.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'وظائف التجميع النشطة',
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(order: jobs[i], mode: OrderCardMode.companyJob),
                  ),
                  childCount: jobs.length,
                ),
              ),
            ),
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
                'منشوراتي في السوق',
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
                    ? () => _confirmDelete(context, listings[i].id, marketVm)
                    : null,
              ),
            ),
            childCount: listings.length,
          ),
        ),
      ),
    ];
  }

  void _confirmDelete(BuildContext context, String orderId, MarketplaceViewModel marketVm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('سحب الإعلان', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل تريد سحب هذا الإعلان من السوق؟', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('لا', style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              marketVm.removeListing(orderId);
            },
            child: Text('نعم، سحب', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPostJobSheet(BuildContext context) {
    final vm = context.read<RecyclingHomeViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PostJobSheet(
        onSubmit: ({
          required List<WasteType> wasteTypes,
          required PaymentModel paymentModel,
          required double price,
          required String collectionArea,
          required String jobDescription,
          double? minQuantityKg,
        }) {
          vm.postCollectionJob(
            wasteTypes: wasteTypes,
            collectionArea: collectionArea,
            jobDescription: jobDescription,
            paymentModel: paymentModel,
            price: price,
            minQuantityKg: minQuantityKg,
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: const Icon(Icons.recycling_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'شركة إعادة تدوير',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onToggleOpen(!isOpen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isOpen
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
                          color: isOpen ? Colors.white : Colors.white54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOpen ? 'مفتوح للاستلام' : 'مغلق مؤقتاً',
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

  Widget _buildStatsRow() {
    final inTransitCount = incoming.where((o) => o.status == OrderStatus.inTransit).length;
    final totalWeight = incoming.fold<double>(0, (sum, o) => sum + (o.weightKg ?? 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(child: _StatCard(value: '${incoming.length}', label: 'شحنات اليوم', icon: Icons.local_shipping_rounded, color: AppColors.statusInTransitText)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${totalWeight.toStringAsFixed(0)}كغ', label: 'الوزن الكلي', icon: Icons.scale_rounded, color: AppColors.accentAmber)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${jobs.length}', label: 'وظائف نشطة', icon: Icons.work_rounded, color: AppColors.statusCompletedText)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '$inTransitCount', label: 'سائقون قيد التنفيذ', icon: Icons.directions_car_rounded, color: const Color(0xFF7C3AED))),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () => _showPostJobSheet(context),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD4EBAB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3D7A1F).withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D7A1F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_circle_outline_rounded,
                    color: Color(0xFF14401F), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'نشر وظيفة تجميع',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF14401F),
                      ),
                    ),
                    Text(
                      'أطلب من سائق جمع المخلفات من منطقة محددة',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF14401F).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 9,
              color: const Color(0xFF717973),
            ),
          ),
        ],
      ),
    );
  }
}
