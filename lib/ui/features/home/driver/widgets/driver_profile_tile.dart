import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showArrow;

  const DriverProfileTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: theme.colorScheme.outline) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.primaryColor),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const Spacer(),
          if (value.isNotEmpty)
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (showArrow) ...[
            if (value.isNotEmpty) const SizedBox(width: 12),
            Icon(Icons.chevron_left_rounded, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), size: 20),
          ]
        ],
      ),
    );
  }
}
