import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order/order_enums.dart';
import '../../../../l10n/l10n.dart';
import '../analytics_viewmodel.dart';

/// Horizontal bar chart of reward-per-kg per waste type, sorted desc. The
/// top row carries a "الأعلى ربحًا" badge.
class WasteProfitabilityChart extends StatelessWidget {
  const WasteProfitabilityChart({super.key, required this.data});

  final List<WasteProfitability> data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            l10n.analyticsProfitabilityEmpty,
            style: GoogleFonts.cairo(color: AppColors.mutedText),
          ),
        ),
      );
    }

    final maxPerKg = data.first.rewardPerKg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Row(
              item: data[i],
              fraction: maxPerKg == 0
                  ? 0.0
                  : (data[i].rewardPerKg / maxPerKg).clamp(0.0, 1.0),
              isTop: i == 0,
              topBadgeLabel: l10n.analyticsProfitabilityTopBadge,
              perKgLabel: l10n.analyticsProfitabilityPerKg(
                data[i].rewardPerKg.toStringAsFixed(1),
              ),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.item,
    required this.fraction,
    required this.isTop,
    required this.topBadgeLabel,
    required this.perKgLabel,
  });

  final WasteProfitability item;
  final double fraction;
  final bool isTop;
  final String topBadgeLabel;
  final String perKgLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.type.ganttColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    item.type.label,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMain,
                    ),
                  ),
                  if (isTop) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        topBadgeLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    perKgLabel,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    item.type.ganttColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
