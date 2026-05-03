import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiConfig {
  /// Gemini API key, loaded from .env.local
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  /// Call this once during `main()` so a missing key fails loudly in the
  /// console instead of silently breaking AI features at runtime.
  static void assertConfigured() {
    if (!hasGeminiKey) {
      debugPrint(
        '[AiConfig] WARNING: GEMINI_API_KEY is empty. '
        'AI features (PostToMarket auto-fill) will fail. '
        'Run with --dart-define=GEMINI_API_KEY=... or use the VSCode '
        '"Dawer (debug)" launch profile.',
      );
    } else {
      debugPrint('[AiConfig] Gemini key loaded (length=${geminiApiKey.length}).');
    }
  }
}
