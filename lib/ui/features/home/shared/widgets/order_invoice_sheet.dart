import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/services/fee_calculator.dart';

class OrderInvoiceSheet extends StatelessWidget {
  final Order order;
  final VoidCallback onConfirm;
  final String confirmLabel;

  const OrderInvoiceSheet({
    super.key,
    required this.order,
    required this.onConfirm,
    this.confirmLabel = 'تأكيد وإتمام الطلب',
  });

  static Future<void> show(
    BuildContext context, {
    required Order order,
    required VoidCallback onConfirm,
    String confirmLabel = 'تأكيد وإتمام الطلب',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => OrderInvoiceSheet(
        order: order,
        onConfirm: onConfirm,
        confirmLabel: confirmLabel,
      ),
    );
  }

  List<_InvoiceLine> _buildLines() {
    final lines = <_InvoiceLine>[];

    if ((order.itemPrice ?? 0) > 0) {
      final typeNames = order.wasteTypes.map((e) => e.label).join('، ');
      lines.add(_InvoiceLine(
        label: typeNames.isNotEmpty ? 'سعر المواد ($typeNames)' : 'سعر المواد',
        amount: order.itemPrice!,
        icon: Icons.recycling_rounded,
        iconColor: const Color(0xFF06402B),
      ));
    }

    lines.add(const _InvoiceLine(
      label: 'رسوم التوصيل الأساسية',
      amount: FeeCalculator.base,
      icon: Icons.local_shipping_rounded,
      iconColor: Color(0xFF1E40AF),
    ));

    final dist = FeeCalculator.distanceFee(order.distanceKm ?? 0.0);
    if (dist > 0) {
      lines.add(_InvoiceLine(
        label: 'رسوم المسافة (${order.distanceKm!.toStringAsFixed(1)} كم)',
        amount: dist,
        icon: Icons.route_rounded,
        iconColor: const Color(0xFF7C3AED),
      ));
    }

    final surcharge = FeeCalculator.weightSurcharge(order.weightCategory);
    if (surcharge > 0) {
      final weightLabel = order.weightCategory?.shortLabel ?? '';
      lines.add(_InvoiceLine(
        label: 'رسوم الوزن${weightLabel.isNotEmpty ? ' ($weightLabel)' : ''}',
        amount: surcharge,
        icon: Icons.scale_rounded,
        iconColor: const Color(0xFFD97706),
      ));
    }

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final lines = _buildLines();
    final total = lines.fold(0.0, (s, l) => s + l.amount);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(children: [
            Text('#${order.id.substring(0, 8)}',
                style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF717973))),
            const Spacer(),
            Text('فاتورة الطلب',
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF06402B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 18, color: Color(0xFF06402B)),
            ),
          ]),
          const SizedBox(height: 20),

          // Line items
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6E9E7)),
            ),
            child: Column(
              children: [
                for (int i = 0; i < lines.length; i++) ...[
                  _LineRow(line: lines[i]),
                  if (i < lines.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFEEF0EE)),
                    ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFD0D5D0), thickness: 1.5),
                ),
                Row(children: [
                  Text('${total.toStringAsFixed(2)} د.أ',
                      style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold,
                          color: const Color(0xFF06402B))),
                  const Spacer(),
                  Text('الإجمالي',
                      style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold,
                          color: const Color(0xFF002819))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pickup address
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF06402B)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(order.pickupAddress, textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF404943))),
            ),
            const SizedBox(width: 4),
            Text('موقع الاستلام',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819))),
          ]),
          const SizedBox(height: 24),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06402B),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(confirmLabel,
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data + sub-widgets ────────────────────────────────────────────────────────

class _InvoiceLine {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;

  const _InvoiceLine({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });
}

class _LineRow extends StatelessWidget {
  final _InvoiceLine line;
  const _LineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text('${line.amount.toStringAsFixed(2)} د.أ',
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600,
              color: const Color(0xFF191C1B))),
      const Spacer(),
      Text(line.label, textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF404943))),
      const SizedBox(width: 8),
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: line.iconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(line.icon, size: 14, color: line.iconColor),
      ),
    ]);
  }
}
