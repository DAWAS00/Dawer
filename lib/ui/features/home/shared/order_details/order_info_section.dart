import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';

class OrderInfoSection extends StatelessWidget {
  final Order order;

  const OrderInfoSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderDetailsTitle,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: order.wasteTypes
                .map(
                  (w) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF06402B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      w.labelFor(locale),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.radio_button_checked,
            iconColor: const Color(0xFF06402B),
            label: l10n.orderFromLabel,
            value: order.pickupAddress,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 7, top: 2, bottom: 2),
            child: Container(
                width: 1, height: 14, color: const Color(0xFFC0C9C1)),
          ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red.shade400,
            label: l10n.orderToLabel,
            value: order.dropoffAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (order.distanceKm != null) ...[
                _MetaChip(
                  icon: Icons.straighten_rounded,
                  value: l10n.orderDistKm(order.distanceKm!.toStringAsFixed(1)),
                ),
                const SizedBox(width: 8),
              ],
              if (order.weightKg != null) ...[
                _MetaChip(
                  icon: Icons.scale_rounded,
                  value: l10n.orderWeightKgLabel(order.weightKg!.toStringAsFixed(0)),
                ),
                const SizedBox(width: 8),
              ],
              if (order.reward > 0)
                _MetaChip(
                  icon: Icons.monetization_on_outlined,
                  value: l10n.orderRewardJD(order.reward.toStringAsFixed(1)),
                  highlight: true,
                ),
              if ((order.itemPrice ?? 0) > 0) ...[
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.receipt_long_rounded,
                  value: '${order.itemPrice!.toStringAsFixed(1)} ${l10n.orderCurrencyJD}',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF717973),
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF404943),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Meta Chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool highlight;

  const _MetaChip({
    required this.icon,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? AppColors.statusActiveText : const Color(0xFF717973);
    final bg =
        highlight ? AppColors.statusActiveBg : const Color(0xFFF2F4F2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
