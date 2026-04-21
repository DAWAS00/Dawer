import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/order_labels.dart'; // labelFor extensions
import '../../../../../l10n/l10n.dart';
import '../../shared/order_details_view.dart';

/// Extracted from [SupplierOrdersTab] — renders a single supplier order card
/// with status badge, waste-type chips, driver info, and cancel action.
class SupplierOrderCard extends StatelessWidget {
  final Order order;
  final bool canCancel;
  final String? Function(String orderId) onCancelOrder;

  const SupplierOrderCard({
    super.key,
    required this.order,
    this.canCancel = false,
    required this.onCancelOrder,
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

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ctx.l10n.cancelOrderTitle,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(ctx.l10n.cancelOrderConfirm,
            textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.no,
                style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final error = onCancelOrder(order.id);
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.orange.shade700,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: Text(ctx.l10n.yesCancelOrder,
                style: GoogleFonts.cairo(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
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
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _statusBg,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(order.status.labelFor(locale),
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _statusColor)),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order.id,
                        style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF002819))),
                    Text(DateFormatter.relative(order.createdAt),
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: const Color(0xFF717973))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                Wrap(
                  spacing: 6,
                  children: order.wasteTypes
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F2),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(t.labelFor(locale),
                                style: GoogleFonts.cairo(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF404943))),
                          ))
                      .toList(),
                ),
              ],
            ),
            if (order.scheduledAt != null) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${context.l10n.orderScheduledAt}: ${DateFormatter.date(order.scheduledAt!)} ${DateFormatter.time(order.scheduledAt!)}',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: const Color(0xFF1E40AF)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.schedule_rounded,
                      size: 13, color: Color(0xFF1E40AF)),
                ],
              ),
            ],
            if (order.driverName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF8),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    if (order.eta != null)
                      Text(order.eta!,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E40AF))),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(order.driverName!,
                            style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF002819))),
                        if (order.driverRating != null)
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(order.driverRating.toString(),
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF717973))),
                            const SizedBox(width: 2),
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFC107), size: 13),
                          ]),
                      ],
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          const Color(0xFF1E5C35).withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded,
                          color: Color(0xFF1E5C35), size: 18),
                    ),
                  ],
                ),
              ),
            ],
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text(context.l10n.cancelOrderTitle,
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
