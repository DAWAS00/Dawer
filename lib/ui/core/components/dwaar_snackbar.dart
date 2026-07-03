import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/failures/app_failure.dart';
import '../utils/failure_localization.dart';

enum SnackBarType { success, error, warning, info }

class SnackBarThemeColors {
  final Color background;
  final Color border;
  final Color foreground;

  const SnackBarThemeColors({
    required this.background,
    required this.border,
    required this.foreground,
  });
}

class DwaarSnackBar {
  static SnackBarThemeColors _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const SnackBarThemeColors(
          background: AppColors.statusCompletedBg,
          border: Color(0xFFBBF7D0),
          foreground: AppColors.statusCompletedText,
        );
      case SnackBarType.error:
        return const SnackBarThemeColors(
          background: AppColors.statusCancelledBg,
          border: Color(0xFFFECACA),
          foreground: AppColors.statusCancelledText,
        );
      case SnackBarType.warning:
        return const SnackBarThemeColors(
          background: AppColors.statusPendingBg,
          border: Color(0xFFFDE68A),
          foreground: AppColors.statusPendingText,
        );
      case SnackBarType.info:
        return const SnackBarThemeColors(
          background: AppColors.statusInTransitBg,
          border: Color(0xFFBFDBFE),
          foreground: AppColors.statusInTransitText,
        );
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }

  /// Triggers a localized snackbar for an [AppFailure].
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
  showErrorFailure(
    BuildContext context,
    AppFailure failure, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = failure.getLocalizedMessage(context);
    return show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  /// Base method to show a beautifully styled Dwaar Snackbar.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return null;

    final themeColors = _getColors(type);
    final icon = _getIcon(type);

    messenger.hideCurrentSnackBar();

    return messenger.showSnackBar(
      SnackBar(
        backgroundColor: themeColors.background,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: themeColors.border, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(icon, color: themeColors.foreground, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.cairo(
                  color: themeColors.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: themeColors.foreground,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}

extension DwaarSnackBarContextX on BuildContext {
  void showSuccessSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    DwaarSnackBar.show(
      this,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    DwaarSnackBar.show(
      this,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  void showWarningSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    DwaarSnackBar.show(
      this,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  void showInfoSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    DwaarSnackBar.show(
      this,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  void showErrorFailure(
    AppFailure failure, {
    Duration duration = const Duration(seconds: 4),
  }) {
    DwaarSnackBar.showErrorFailure(this, failure, duration: duration);
  }
}
