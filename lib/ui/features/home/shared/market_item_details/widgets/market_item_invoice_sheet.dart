import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'package:dwaar/data/models/order/order.dart';

class MarketItemInvoiceSheet extends StatelessWidget {
  final Order item;
  final VoidCallback onConfirm;

  const MarketItemInvoiceSheet({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = item.itemPrice ?? 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '#${item.id}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF717973),
                ),
              ),
              const Spacer(),
              Text(
                l10n.marketInvoiceTitle,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE6E9E7)),
            ),
            child: Column(
              children: [
                if (item.invoices != null && item.invoices!.isNotEmpty) ...[
                  for (var i = 0; i < item.invoices!.length; i++) ...[
                    if (i > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                    _InvoiceRow(
                      label: item.invoices![i].name,
                      value: item.invoices![i].price > 0
                          ? '${(item.invoices![i].price * item.invoices![i].quantity).toStringAsFixed(2)} د.أ'
                          : '-',
                      isBold: item.invoices![i].price > 0,
                    ),
                  ],
                ] else ...[
                  _InvoiceRow(
                    label: item.wasteTypes.map((e) => e.label).join(' + '),
                    value: '${total.toStringAsFixed(2)} د.أ',
                    isBold: true,
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _InvoiceRow(
                  label: l10n.marketInvoiceTotal,
                  value: '${total.toStringAsFixed(2)} د.أ',
                  isBold: true,
                  color: const Color(0xFF06402B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.marketInvoicePickupLocation,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Color(0xFF06402B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.pickupAddress,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF404943),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06402B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.marketInvoiceConfirm,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? const Color(0xFF191C1B),
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF404943),
          ),
        ),
      ],
    );
  }
}
