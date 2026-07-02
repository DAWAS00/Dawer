import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/services/app_theme_notifier.dart';
import '../../../l10n/l10n.dart';

class ThemeModeSheet extends StatelessWidget {
  const ThemeModeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AppThemeNotifier>();
    final currentMode = notifier.mode;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).bottomSheetTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.themeTitle,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildRow(
            context,
            icon: Icons.wb_sunny_rounded,
            label: l10n.themeLight,
            mode: ThemeMode.light,
            currentMode: currentMode,
            notifier: notifier,
          ),
          const Divider(height: 1),
          _buildRow(
            context,
            icon: Icons.dark_mode_rounded,
            label: l10n.themeDark,
            mode: ThemeMode.dark,
            currentMode: currentMode,
            notifier: notifier,
          ),
          const Divider(height: 1),
          _buildRow(
            context,
            icon: Icons.phone_android_rounded,
            label: l10n.themeAutoFull,
            mode: ThemeMode.system,
            currentMode: currentMode,
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required AppThemeNotifier notifier,
  }) {
    final isSelected = mode == currentMode;
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      onTap: () {
        notifier.setMode(mode);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

void showThemeModeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: const ThemeModeSheet(),
    ),
  );
}
