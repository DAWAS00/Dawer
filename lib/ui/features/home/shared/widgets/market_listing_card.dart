import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';

class MarketListingCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const MarketListingCard({
    super.key,
    required this.order,
    this.onDelete,
    this.onTap,
  });

  Color get _statusColor => switch (order.status) {
        OrderStatus.pending => const Color(0xFFC8860A),
        OrderStatus.accepted => const Color(0xFF1E5C35),
        OrderStatus.inTransit => const Color(0xFF1E40AF),
        OrderStatus.completed => const Color(0xFF166534),
        OrderStatus.cancelled => const Color(0xFF991B1B),
      };

  Color get _statusBg => switch (order.status) {
        OrderStatus.pending => const Color(0xFFFEF3C7),
        OrderStatus.accepted => const Color(0xFFD1FAE5),
        OrderStatus.inTransit => const Color(0xFFDBEAFE),
        OrderStatus.completed => const Color(0xFFDCFCE7),
        OrderStatus.cancelled => const Color(0xFFFEE2E2),
      };

  String get _statusLabel => switch (order.status) {
        OrderStatus.pending => 'بانتظار مشتري',
        OrderStatus.accepted => 'تم الشراء',
        OrderStatus.inTransit => 'قيد التوصيل',
        OrderStatus.completed => 'مكتمل',
        OrderStatus.cancelled => 'ملغي',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                if (order.status == OrderStatus.pending && onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.id,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002819),
                      ),
                    ),
                    Text(
                      _formatAge(order.createdAt),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: order.wasteTypes
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.label,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF404943),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (order.itemPrice != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (order.weightCategory != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.weightCategory!.shortLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF717973),
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${order.itemPrice!.toStringAsFixed(1)} د.أ',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF06402B),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.sell_rounded,
                    size: 15,
                    color: Color(0xFF06402B),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAge(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inMinutes} دقيقة';
  }
}
