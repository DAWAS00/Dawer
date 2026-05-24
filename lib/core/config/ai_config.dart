import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  /// Gemini API key, loaded from .env.local
  static String get geminiApiKey {
    try {
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Call this once during `main()` so a missing key fails loudly in the
  /// console instead of silently breaking AI features at runtime.
  static void assertConfigured() {
    if (!hasGeminiKey) {
      debugPrint(
        '\x1B[33m[AiConfig] WARNING: GEMINI_API_KEY is empty.\n'
        'AI features will run in MOCK MODE.\n'
        'To use real AI, add GEMINI_API_KEY to your .env.local file.\x1B[0m',
      );
    } else {
      debugPrint('\x1B[32m[AiConfig] Gemini key loaded (length=${geminiApiKey.length}).\x1B[0m');
    }
  }
}
