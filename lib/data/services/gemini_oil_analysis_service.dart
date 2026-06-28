import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/oil_analysis_result.dart';
import 'gemini_service.dart';

/// Sends a user-captured oil image to Gemini Vision and returns a structured
/// quality report. Returns null on any failure — callers must degrade
/// gracefully (fall back to ML Kit result).
class GeminiOilAnalysisService {
  GeminiOilAnalysisService._();
  static final GeminiOilAnalysisService instance = GeminiOilAnalysisService._();

  static const _prompt = '''
You are an expert used cooking oil quality analyst for a recycling logistics app in Jordan.
Analyze the provided image and return ONLY a valid JSON object — no markdown fences, no extra text.

{
  "isUsedCookingOil": true or false,
  "waterContent": "none" | "low" | "high",
  "impurityLevel": "clean" | "moderate" | "heavy",
  "grade": "A" | "B" | "C" | "rejected",
  "estimatedLiters": number (estimate from visible container; 0 if not oil or unclear),
  "estimatedPayoutMinJod": number,
  "estimatedPayoutMaxJod": number,
  "explanation": "2–3 sentences in Arabic explaining the quality assessment and payout estimate"
}

Grading and payout rates (JOD per liter):
- Grade A: clean oil, no water, no impurities → 0.40–0.50 JOD/L
- Grade B: low water content or moderate impurities → 0.20–0.30 JOD/L
- Grade C: high water or heavy impurities but still processable → 0.10–0.15 JOD/L
- Rejected: not used cooking oil, or contaminated beyond processing → 0 JOD/L

Multiply estimated liters × rate to compute the payout range.
If the image does not show used cooking oil, set isUsedCookingOil=false,
grade="rejected", estimatedLiters=0, both payout fields=0.
''';

  Future<OilAnalysisResult?> analyze(String imagePath) async {
    if (!GeminiService.instance.isInitialized) {
      debugPrint('[GeminiOilAnalysis] Gemini not initialized — skipping.');
      return null;
    }

    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final mimeType = _mimeType(imagePath);

      // Use a fresh GenerativeModel (no system instruction — the prompt carries all context).
      final model = GeminiService.instance.model();

      final response = await model.generateContent([
        Content.multi([
          DataPart(mimeType, imageBytes),
          TextPart(_prompt),
        ]),
      ]);

      final raw = response.text?.trim() ?? '';
      if (raw.isEmpty) return null;

      // Strip markdown code fences that Gemini sometimes adds.
      final cleaned = raw
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final data = jsonDecode(cleaned) as Map<String, dynamic>;
      return OilAnalysisResult.fromJson(data);
    } catch (e, st) {
      debugPrint('[GeminiOilAnalysis] Error: $e\n$st');
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
