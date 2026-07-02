import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order/order_enums.dart';
import '../analytics_viewmodel.dart';

/// Horizontal stacked bar showing each waste type's share of processed
/// weight, plus a legend. No extra deps — just `Expanded(flex:)` segments.
class WasteTypeBreakdown extends StatelessWidget {
  const WasteTypeBreakdown({super.key, required this.breakdown});

  final List<WasteShare> breakdown;

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'لا توجد مواد معالجة في هذه الفترة',
            style: GoogleFonts.cairo(color: AppColors.mutedText),
          ),
        ),
      );
    }

    // Cap legend at 6 entries, fold the rest into "أخرى".
    final shown = breakdown.take(6).toList();
    final rest = breakdown.skip(6).toList();
    final restShare = rest.fold(0.0, (s, e) => s + e.share);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                for (final s in shown)
                  Expanded(
                    flex: (s.share * 1000).round().clamp(1, 100000),
                    child: ColoredBox(color: s.type.ganttColor),
                  ),
                if (rest.isNotEmpty)
                  Expanded(
                    flex: (restShare * 1000).round().clamp(1, 100000),
                    child: const ColoredBox(color: Color(0xFF9CA3AF)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            for (final s in shown)
              _LegendItem(
                color: s.type.ganttColor,
                label: s.type.label,
                share: s.share,
              ),
            if (rest.isNotEmpty)
              _LegendItem(
                color: const Color(0xFF9CA3AF),
                label: 'أخرى',
                share: restShare,
              ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.share,
  });

  final Color color;
  final String label;
  final double share;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: AppColors.textMain,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '${(share * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
