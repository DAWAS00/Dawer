import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../l10n/l10n.dart';

/// Section title with an optional trailing "edit" action.
///
/// In RTL the title sits on the right (start) and the edit button on the
/// left (end). Used to head each profile section (info, settings, etc.).
class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    super.key,
    required this.title,
    this.onEdit,
  });

  final String title;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          if (onEdit != null)
            TextButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_rounded, size: 16, color: theme.primaryColor),
              label: Text(
                context.l10n.edit,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
