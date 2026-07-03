import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../core/components/dwaar_detail_card.dart';

class OrderInfoSection extends StatelessWidget {
  final Order order;

  const OrderInfoSection({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return DwaarDetailSection(
      icon: Icons.info_outline_rounded,
      title: l10n.orderDetailsTitle,
      accentColor: AppColors.primaryGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Waste type chips ──
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: order.wasteTypes
                .map(
                  (w) => DwaarDetailChip(
                    label: w.labelFor(locale),
                    color: const Color(0xFF06402B),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // ── Route: pickup address ──
          DwaarDetailRow(
            icon: Icons.radio_button_checked,
            iconColor: const Color(0xFF06402B),
            label: l10n.orderFromLabel,
            value: order.pickupAddress,
          ),

          // ── Dashed connector line (green dot → red dot) ──
          Padding(
            padding: const EdgeInsets.only(right: 7, top: 2, bottom: 2),
            child: Container(
              width: 1,
              height: 14,
              color: const Color(0xFFC0C9C1),
            ),
          ),

          // ── Route: dropoff address ──
          DwaarDetailRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red.shade400,
            label: l10n.orderToLabel,
            value: order.dropoffAddress,
          ),
          const SizedBox(height: 16),

          // ── Metric tiles ──
          Row(
            children: [
              if (order.distanceKm != null) ...[
                DwaarMetricTile(
                  icon: Icons.straighten_rounded,
                  value: l10n.orderDistKm(order.distanceKm!.toStringAsFixed(1)),
                  label: '',
                  color: const Color(0xFF717973),
                ),
                const SizedBox(width: 8),
              ],
              if (order.weightKg != null) ...[
                DwaarMetricTile(
                  icon: Icons.scale_rounded,
                  value: l10n.orderWeightKgLabel(
                    order.weightKg!.toStringAsFixed(0),
                  ),
                  label: '',
                  color: const Color(0xFF717973),
                ),
                const SizedBox(width: 8),
              ],
              if (order.reward > 0)
                DwaarMetricTile(
                  icon: Icons.monetization_on_outlined,
                  value: l10n.orderRewardJD(order.reward.toStringAsFixed(1)),
                  label: '',
                  color: AppColors.statusActiveText,
                  bold: true,
                ),
              if ((order.itemPrice ?? 0) > 0) ...[
                const SizedBox(width: 8),
                DwaarMetricTile(
                  icon: Icons.receipt_long_rounded,
                  value:
                      '${order.itemPrice!.toStringAsFixed(1)} ${l10n.orderCurrencyJD}',
                  label: '',
                  color: const Color(0xFF717973),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
