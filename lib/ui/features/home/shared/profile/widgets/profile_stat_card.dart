import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single statistic shown in [ProfileStatCard].
class ProfileStat {
  const ProfileStat({required this.value, required this.label});
  final String value;
  final String label;
}

/// Floating stats card that overlaps the [ProfileHeader] by 20px.
///
/// Renders N evenly-spaced stat columns separated by vertical dividers.
/// Used by all role profile tabs (driver: 2 stats, supplier: 2, company: 3).
class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({super.key, required this.stats});

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final children = <Widget>[];
    for (var i = 0; i < stats.length; i++) {
      if (i > 0) {
        children.add(
          Container(width: 1, height: 40, color: theme.dividerColor),
        );
      }
      children.add(_StatColumn(stat: stats[i]));
    }

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? Border.all(color: theme.colorScheme.outline)
                : null,
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat});
  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                stat.value,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
