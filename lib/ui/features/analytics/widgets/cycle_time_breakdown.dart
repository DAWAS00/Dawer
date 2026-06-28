import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../analytics_viewmodel.dart';

/// Horizontal proportional stacked bar showing the four lifecycle stages'
/// share of average total order time, plus a legend with each stage's
/// average minutes.
class CycleTimeBreakdownChart extends StatelessWidget {
  const CycleTimeBreakdownChart({super.key, required this.data});

  final CycleTimeBreakdown data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            l10n.analyticsCycleEmpty,
            style: GoogleFonts.cairo(color: AppColors.mutedText),
          ),
        ),
      );
    }

    final stages = <_Stage>[
      _Stage(l10n.analyticsCycleStageAccept, data.avgAcceptMinutes,
          const Color(0xFF2563EB)),
      _Stage(l10n.analyticsCycleStagePickup, data.avgPickupMinutes,
          const Color(0xFFD97706)),
      _Stage(l10n.analyticsCycleStageTransit, data.avgTransitMinutes,
          const Color(0xFF16A34A)),
      _Stage(l10n.analyticsCycleStageDropoff, data.avgDropoffMinutes,
          const Color(0xFF7C3AED)),
    ].where((s) => s.minutes != null).toList();

    final total = stages.fold<double>(
        0, (s, e) => s + (e.minutes ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.avgTotalMinutes != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.analyticsCycleAvgCaption(data.avgTotalMinutes!.round()),
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
          ),
        if (total > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (int i = 0; i < stages.length; i++) ...[
                    Expanded(
                      flex: ((stages[i].minutes! / total) * 1000)
                          .round()
                          .clamp(1, 100000),
                      child: ColoredBox(color: stages[i].color),
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            for (final s in stages)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: s.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.label,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    l10n.analyticsCycleMinutes(
                        s.minutes!.toStringAsFixed(0)),
                    style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Stage {
  const _Stage(this.label, this.minutes, this.color);
  final String label;
  final double? minutes;
  final Color color;
}
