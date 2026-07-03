import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../ui/core/components/dwaar_detail_card.dart';

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

    return DwaarDetailCard(
      elevation: DwaarCardElevation.highlighted,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: EdgeInsets.zero,
      accentColor: AppColors.primaryGreen,
      animationIndex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient accent bar at top
          const ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: DwaarDetailGradientBar(
              startColor: AppColors.ctaGradientStart,
              endColor: AppColors.ctaGradientEnd,
              height: 4,
            ),
          ),

          // Earnings Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // Total earnings on left
                Text(
                  '${order.reward.toStringAsFixed(2)} ${l10n.orderCurrencyJD}',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                // Header title + icon on right (RTL)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.status == OrderStatus.pending ||
                                order.status == OrderStatus.accepted
                            ? l10n.orderPotentialEarnings
                            : l10n.orderEarningsBreakdown,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.end,
                      ),
                      if (order.status == OrderStatus.pending ||
                          order.status == OrderStatus.accepted)
                        Text(
                          l10n.orderPayout,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: AppColors.mutedText,
                          ),
                          textAlign: TextAlign.end,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.wallet,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // Breakdown Rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                if (breakdown != null) ...[
                  const DwaarDetailDivider(verticalPadding: 10),
                  _BreakdownRow(
                    label: l10n.orderBaseFee,
                    value: breakdown.base,
                  ),
                  _BreakdownRow(
                    label: l10n.orderDistanceFee,
                    value: breakdown.distance,
                  ),
                  if (breakdown.material > 0)
                    _BreakdownRow(
                      label: l10n.orderMaterialFee,
                      value: breakdown.material,
                    ),
                  if (breakdown.urgency > 0)
                    _BreakdownRow(
                      label: l10n.orderUrgencyFee,
                      value: breakdown.urgency,
                    ),
                ],

                // Invoices / Item Cost Section
                if ((order.itemPrice ?? 0) > 0) ...[
                  const DwaarDetailDivider(verticalPadding: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 16,
                        color: Color(0xFF4B5563),
                      ),
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
                            color: AppColors.mutedText,
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          ...order.invoices!.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.total.toStringAsFixed(2),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: const Color(0xFF1F2937),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const DwaarDetailDivider(verticalPadding: 4),
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
              color: isBold ? const Color(0xFF374151) : AppColors.mutedText,
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
