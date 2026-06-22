import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified info row used across all role profile tabs.
///
/// Replaces the previously duplicated `DriverProfileTile` and the inline
/// `_buildProfileTile` implementations in the supplier/recycling tabs.
/// Card surface, icon chip, label, trailing value, optional chevron.
class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.showArrow = false,
    this.onTap,
    this.valueColor,
    this.valueLtr = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showArrow;
  final VoidCallback? onTap;
  final Color? valueColor;

  /// Force LTR on the value (phone numbers, plates, amounts).
  final bool valueLtr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tile = Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: theme.colorScheme.outline) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              textDirection: valueLtr ? TextDirection.ltr : null,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: valueColor ?? theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showArrow)
            Icon(
              Icons.chevron_left_rounded,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              size: 20,
            ),
        ],
      ),
    );

    if (onTap == null) return tile;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: tile,
    );
  }
}
