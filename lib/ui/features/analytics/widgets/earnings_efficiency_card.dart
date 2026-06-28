import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order/order_enums.dart';
import '../../../../l10n/l10n.dart';
import '../analytics_viewmodel.dart';

/// Compact card showing the big reward-per-km ratio + a list of the top-3
/// most efficient jobs. Empty state when no distance data exists.
class EarningsEfficiencyCard extends StatelessWidget {
  const EarningsEfficiencyCard({
    super.key,
    required this.earningsPerKm,
    required this.bestJobs,
  });

  final double? earningsPerKm;
  final List<EfficientJob> bestJobs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (earningsPerKm == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            l10n.analyticsEfficiencyEmpty,
            style: GoogleFonts.cairo(color: AppColors.mutedText),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big ratio
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              earningsPerKm!.toStringAsFixed(2),
              style: GoogleFonts.dmSans(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                height: 1.0,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'د.أ/كم',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.analyticsEfficiencyRatioCaption,
          style: GoogleFonts.cairo(fontSize: 12, color: AppColors.mutedText),
        ),
        if (bestJobs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            l10n.analyticsEfficiencyTopJobs,
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          for (final job in bestJobs) ...[
            _JobRow(job: job),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});
  final EfficientJob job;

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wasteType = job.order.wasteTypes.firstOrNull;
    final dateStr = job.order.completedAt != null
        ? _formatDate(job.order.completedAt!)
        : '—';

    return Row(
      children: [
        if (wasteType != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: wasteType.ganttColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          wasteType?.label ?? '—',
          style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain),
        ),
        const SizedBox(width: 8),
        Text(
          dateStr,
          style: GoogleFonts.dmSans(
              fontSize: 11, color: AppColors.mutedText),
        ),
        const Spacer(),
        Text(
          l10n.analyticsEfficiencyRatioValue(
              job.jodPerKm.toStringAsFixed(2)),
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen),
        ),
      ],
    );
  }
}
