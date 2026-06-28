import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// Returns a [GenerativeModel] ready for use.
  ///
  /// [modelName] — defaults to `gemini-1.5-flash`
  /// [systemInstruction] — optional system-level prompt
  /// [config] — optional generation config (temperature, JSON mode, etc.)
  /// [safetySettings] — defaults to [kDefaultSafetySettings]
  GenerativeModel model({
    String modelName = 'gemini-1.5-flash',
    Content? systemInstruction,
    GenerationConfig? config,
    List<SafetySetting>? safetySettings,
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
      generationConfig: config,
      safetySettings: safetySettings ?? kDefaultSafetySettings,
    );
  }

  // ── Shared defaults ────────────────────────────────────────────────────────

  /// Safety settings that allow recycling / food-waste / oil content to pass
  /// through without spurious blocks while still blocking genuinely harmful
  /// output. Applied to every model unless overridden.
  ///
  /// `HarmBlockThreshold.high` = block only when probability is HIGH
  /// (equivalent to BLOCK_ONLY_HIGH in the REST API).
  static final kDefaultSafetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
  ];

  /// Generation config for structured JSON tasks. Forces valid JSON output
  /// and uses low temperature to maximise schema compliance.
  static final kJsonConfig = GenerationConfig(
    responseMimeType: 'application/json',
    temperature: 0.1,
  );

  // ── JSON extraction utility ────────────────────────────────────────────────

  /// Parses the JSON object from a Gemini response string.
  ///
  /// Strips markdown code fences if present, then decodes the first valid
  /// JSON object found. Returns null if parsing fails so callers can
  /// gracefully degrade instead of crashing.
  static Map<String, dynamic>? extractJson(String raw) {
    if (raw.isEmpty) return null;
    try {
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[GeminiService] JSON parse failed: $e\nRaw: $raw');
      return null;
    }
  }
}
