import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'gemini_service.dart';

/// Abstract base for any Gemini Vision analysis task that:
/// - accepts an image file path
/// - sends the image + a text prompt to Gemini Vision
/// - expects a structured JSON response
/// - returns a typed result [T], or null on any failure
///
/// To add a new vision task (e.g. wood quality, document scan):
/// 1. Extend [GeminiVisionTask<YourResultType>]
/// 2. Override [prompt] and [fromJson]
/// 3. Optionally override [modelName], [timeout], or [systemInstruction]
///
/// All boilerplate (file I/O, MIME detection, model construction, JSON
/// extraction, timeout, error handling) is handled here.
abstract class GeminiVisionTask<T> {
  const GeminiVisionTask();

  /// The instruction prompt sent alongside the image.
  String get prompt;

  /// Parse a decoded JSON map into the typed result.
  T fromJson(Map<String, dynamic> json);

  /// Model to use — defaults to gemini-2.5-flash.
  String get modelName => 'gemini-2.5-flash';

  /// Timeout for the Gemini API call. Adjust for slower/larger models.
  Duration get timeout => const Duration(seconds: 30);

  /// Optional system instruction for this task (rarely needed for vision).
  Content? get systemInstruction => null;

  // ── Core logic (shared across all subclasses) ──────────────────────────────

  Future<T?> analyze(String imagePath) async {
    if (!GeminiService.instance.isInitialized) {
      debugPrint('[$runtimeType] Gemini not initialized — skipping.');
      return null;
    }

    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final mimeType = _mimeType(imagePath);

      final m = GeminiService.instance.model(
        modelName: modelName,
        systemInstruction: systemInstruction,
        config: GeminiService.kJsonConfig,
      );

      final response = await m.generateContent([
        Content.multi([
          DataPart(mimeType, imageBytes),
          TextPart(prompt),
        ]),
      ]).timeout(timeout);

      final raw = response.text?.trim() ?? '';
      final data = GeminiService.extractJson(raw);
      if (data == null) return null;

      return fromJson(data);
    } on TimeoutException {
      debugPrint('[$runtimeType] Gemini request timed out after ${timeout.inSeconds}s.');
      return null;
    } catch (e, st) {
      debugPrint('[$runtimeType] Error: $e\n$st');
      return null;
    }
  }

  static String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
