import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/services/app_lang_notifier.dart';
import '../../../l10n/l10n.dart';

class LangPickerSheet extends StatelessWidget {
  const LangPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AppLangNotifier>();
    final current = notifier.locale.languageCode;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
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
            l10n.languagePickerTitle,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildRow(
            context,
            label: l10n.languageArabic,
            code: 'ar',
            current: current,
            notifier: notifier,
          ),
          const Divider(height: 1),
          _buildRow(
            context,
            label: l10n.languageEnglish,
            code: 'en',
            current: current,
            notifier: notifier,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String code,
    required String current,
    required AppLangNotifier notifier,
  }) {
    final isSelected = code == current;
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      onTap: () {
        notifier.setLocale(Locale(code));
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).primaryColor, size: 24),
          ],
        ),
      ),
    );
  }
}

void showLangPickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => LangPickerSheet(),
  );
}
