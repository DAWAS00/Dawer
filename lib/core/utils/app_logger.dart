import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void info(String tag, String message) {
    if (kDebugMode) debugPrint('ℹ [$tag] $message');
  }

  static void warn(String tag, String message) {
    if (kDebugMode) debugPrint('⚠ [$tag] $message');
  }

  static void error(String tag, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('✖ [$tag] $error');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    // TODO(Phase 3): forward to Firebase Crashlytics in release builds
    // if (!kDebugMode) FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
