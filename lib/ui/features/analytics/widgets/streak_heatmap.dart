import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';

/// GitHub-style 5-week (35-cell) activity heatmap. Each cell = one day;
/// color intensity scales with completed-order count that day.
///
/// Cells for future days render as outlined-empty. RTL-aware: columns flow
/// right-to-left to match the app's text direction.
class StreakHeatmap extends StatelessWidget {
  const StreakHeatmap({
    super.key,
    required this.counts,
    required this.today,
    this.weeks = 5,
  });

  /// Day-granularity DateTime → completed-order count.
  final Map<DateTime, int> counts;

  /// "Today" (injectable for tests).
  final DateTime today;

  final int weeks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final todayDay = DateTime(today.year, today.month, today.day);
    // 35 days ending today, oldest-first.
    final days = List<DateTime>.generate(
      weeks * 7,
      (i) => todayDay.subtract(Duration(days: (weeks * 7 - 1) - i)),
    );

    if (counts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            l10n.analyticsStreakEmpty,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: AppColors.mutedText),
          ),
        ),
      );
    }

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int w = 0; w < weeks; w++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  for (int d = 0; d < 7; d++)
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: _Cell(
                            day: days[w * 7 + d],
                            count: counts[days[w * 7 + d]] ?? 0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.day, required this.count});
  final DateTime day;
  final int count;

  Color _color() {
    if (count == 0) return AppColors.surfaceAlt;
    if (count <= 2) return AppColors.primaryGreen.withValues(alpha: 0.35);
    if (count <= 4) return AppColors.primaryGreen.withValues(alpha: 0.65);
    return AppColors.primaryGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${day.day}/${day.month}: $count',
      child: Container(
        decoration: BoxDecoration(
          color: _color(),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
