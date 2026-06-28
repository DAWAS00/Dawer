import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified KPI card used by both the Analytics tab grid and the per-role
/// home stat rows. Sized via [AspectRatio] so it never overflows regardless
/// of how many sit in a row.
///
/// Pass [onTap] to enable a drill-down hook (no-op safe when null).
class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.delta,
    this.deltaPositive,
    this.onTap,
    this.aspectRatio = 1.35,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String? delta;
  final bool? deltaPositive;
  final VoidCallback? onTap;

  /// Width/height ratio. Lower = taller. 1.35 fits 2-up comfortably.
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.colorScheme.surface : Colors.white;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
              border: isDark
                  ? Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.4))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon chip + optional delta
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    if (delta != null) ...[
                      const Spacer(),
                      _DeltaChip(
                        text: delta!,
                        positive: deltaPositive,
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    height: 1.2,
                    color: const Color(0xFF6A7973),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.text, required this.positive});
  final String text;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final isUp = positive == true;
    const up = Color(0xFF16A34A);
    const down = Color(0xFFDC2626);
    final color = positive == null ? const Color(0xFF6A7973) : (isUp ? up : down);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
