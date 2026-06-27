import 'package:google_generative_ai/google_generative_ai.dart';

/// Singleton wrapper around the Google Generative AI client.
/// Call [init] once in main() before any AI service is used.
class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  String _apiKey = '';
  bool _initialized = false;

  bool get isInitialized => _initialized;

  void init(String apiKey) {
    _apiKey = apiKey;
    _initialized = true;
  }

  GenerativeModel model({
    String modelName = 'gemini-1.5-flash',
    Content? systemInstruction,
  }) {
    if (!_initialized || _apiKey.isEmpty) {
      throw StateError(
        'GeminiService.init() must be called before use. '
        'Ensure GEMINI_API_KEY is set in .env.local.',
      );
    }
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: systemInstruction,
    );
  }
}
