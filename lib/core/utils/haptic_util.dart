import 'package:flutter/services.dart';

class HapticUtil {
  /// Light tap for small interactions (selection, toggle)
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap for important actions (next step, AI success)
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap for critical actions (submit, error)
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Celebratory pattern for success
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// Alert pattern for errors
  static Future<void> error() async {
    await HapticFeedback.vibrate();
  }
}
