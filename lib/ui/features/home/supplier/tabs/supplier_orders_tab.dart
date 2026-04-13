import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_details_view.dart';

class SupplierOrdersTab extends StatelessWidget {
  final List<Order> activeOrders;
  final List<Order> completedOrders;
  final List<Order> cancelledOrders;
  final String? Function(String orderId) onCancelOrder;

  const SupplierOrdersTab({
    super.key,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context) {
    final hasOrders = activeOrders.isNotEmpty || completedOrders.isNotEmpty || cancelledOrders.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 16),
            child: Text(
              'طلباتي',
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
          ),
        ),
        if (!hasOrders)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E5C35).withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFF1E5C35)),
                  ),
                  const SizedBox(height: 24),
                  Text('لا توجد طلبات بعد', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
                  const SizedBox(height: 8),
                  Text('أنشئ طلب استلام جديد من الصفحة الرئيسية', style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF717973))),
                ],
              ),
            ),
          )
        else ...[
          if (activeOrders.isNotEmpty) ...[
            _buildSectionHeader('الطلبات النشطة', activeOrders.length, const Color(0xFF1E5C35)),
            _buildOrdersList(context, activeOrders, canCancel: true),
          ],
          if (completedOrders.isNotEmpty) ...[
            _buildSectionHeader('الطلبات المكتملة', completedOrders.length, const Color(0xFF166534)),
            _buildOrdersList(context, completedOrders),
          ],
          if (cancelledOrders.isNotEmpty) ...[
            _buildSectionHeader('الطلبات الملغاة', cancelledOrders.length, const Color(0xFF991B1B)),
            _buildOrdersList(context, cancelledOrders),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ],
    );
  }

  static SliverToBoxAdapter _buildSectionHeader(String title, int count, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildOrdersList(BuildContext context, List<Order> orders, {bool canCancel = false}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SupplierOrderCard(
              order: orders[i],
              canCancel: canCancel && orders[i].status == OrderStatus.pending,
              onCancelOrder: onCancelOrder,
            ),
          ),
          childCount: orders.length,
        ),
      ),
    );
  }
}

// ── Supplier Order Card ──────────────────────────────────────────────────────

class _SupplierOrderCard extends StatelessWidget {
  final Order order;
  final bool canCancel;
  final String? Function(String orderId) onCancelOrder;

  const _SupplierOrderCard({required this.order, this.canCancel = false, required this.onCancelOrder});

  Color get _statusColor {
    return switch (order.status) {
      OrderStatus.pending => const Color(0xFFC8860A),
      OrderStatus.accepted => const Color(0xFF1E5C35),
      OrderStatus.inTransit => const Color(0xFF1E40AF),
      OrderStatus.completed => const Color(0xFF166534),
      OrderStatus.cancelled => const Color(0xFF991B1B),
    };
  }

  Color get _statusBg {
    return switch (order.status) {
      OrderStatus.pending => const Color(0xFFFEF3C7),
      OrderStatus.accepted => const Color(0xFFD1FAE5),
      OrderStatus.inTransit => const Color(0xFFDBEAFE),
      OrderStatus.completed => const Color(0xFFDCFCE7),
      OrderStatus.cancelled => const Color(0xFFFEE2E2),
    };
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('إلغاء الطلب', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد أنك تريد إلغاء هذا الطلب؟', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('لا', style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final error = onCancelOrder(order.id);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error, style: GoogleFonts.cairo()),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('نعم، إلغاء', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OrderDetailsView(order: order)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // Top row: status badge + order ID + date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.label,
                    style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _statusColor),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.id,
                      style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Waste types
            Row(
              children: [
                const Spacer(),
                Wrap(
                  spacing: 6,
                  children: order.wasteTypes.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t.label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF404943))),
                  )).toList(),
                ),
              ],
            ),

            // Driver info (if assigned)
            if (order.driverName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (order.eta != null)
                      Text(
                        order.eta!,
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF)),
                      ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          order.driverName!,
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
                        ),
                        if (order.driverRating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                order.driverRating.toString(),
                                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF717973)),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 13),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1E5C35).withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF1E5C35), size: 18),
                    ),
                  ],
                ),
              ),
            ],

            // Cancel button for pending orders
            if (canCancel) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text('إلغاء الطلب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
