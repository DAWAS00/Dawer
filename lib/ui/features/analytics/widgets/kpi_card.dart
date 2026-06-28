import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.delta,
    this.deltaPositive,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String? delta;
  final bool? deltaPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.colorScheme.surface : Colors.white;

    return Container(
      padding: const EdgeInsets.all(14),
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
            ? Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Icon(
                  deltaPositive == true
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 12,
                  color: deltaPositive == true
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 2),
                Text(
                  delta!,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: deltaPositive == true
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: const Color(0xFF6A7973),
            ),
          ),
        ],
      ),
    );
  }
}
