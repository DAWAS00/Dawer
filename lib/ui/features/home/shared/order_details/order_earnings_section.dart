import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';

class OrderEarningsSection extends StatelessWidget {
  final Order order;

  const OrderEarningsSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final breakdown = order.rewardBreakdown;
    
    // Only show if there's a reward, breakdown or item price
    if (order.reward <= 0 && breakdown == null && (order.itemPrice ?? 0) <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Potential Earnings Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.03),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Color(0xFF06402B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status == OrderStatus.pending || order.status == OrderStatus.accepted
                            ? l10n.orderPotentialEarnings
                            : l10n.orderEarningsBreakdown,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      if (order.status == OrderStatus.pending || order.status == OrderStatus.accepted)
                        Text(
                          l10n.orderPayout,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${order.reward.toStringAsFixed(2)} ${l10n.orderCurrencyJD}',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF06402B),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (breakdown != null) ...[
                  _BreakdownRow(label: l10n.orderBaseFee, value: breakdown.base),
                  _BreakdownRow(label: l10n.orderDistanceFee, value: breakdown.distance),
                  if (breakdown.material > 0)
                    _BreakdownRow(label: l10n.orderMaterialFee, value: breakdown.material),
                  if (breakdown.urgency > 0)
                    _BreakdownRow(label: l10n.orderUrgencyFee, value: breakdown.urgency),
                ],

                // Invoices / Item Cost Section
                if ((order.itemPrice ?? 0) > 0) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, size: 16, color: Color(0xFF4B5563)),
                      const SizedBox(width: 8),
                      Text(
                        l10n.orderInvoices,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const Spacer(),
                      if (order.invoices != null)
                        Text(
                          '${order.invoices!.length} ${l10n.navOrders}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Invoice Items with Receipt Style
                  if (order.invoices != null && order.invoices!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        children: [
                          ...order.invoices!.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: const Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                                Text(
                                  'x${item.quantity}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${item.total.toStringAsFixed(2)}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: const Color(0xFF1F2937),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Divider(height: 1, color: Color(0xFFE5E7EB), thickness: 0.5),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.orderTotalCost,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: const Color(0xFF111827),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${order.itemPrice!.toStringAsFixed(2)} ${l10n.orderCurrencyJD}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    // Simple total price if no detailed invoices
                    _BreakdownRow(
                      label: l10n.orderTotalCost,
                      value: order.itemPrice!,
                      isBold: true,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: isBold ? const Color(0xFF374151) : const Color(0xFF6B7280),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} ${context.l10n.orderCurrencyJD}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: isBold ? const Color(0xFF111827) : const Color(0xFF4B5563),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

