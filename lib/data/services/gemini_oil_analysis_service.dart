import '../models/oil_analysis_result.dart';
import 'gemini_vision_task.dart';

/// Gemini Vision analysis for used cooking oil quality.
/// Extends [GeminiVisionTask] — no boilerplate needed here.
class GeminiOilAnalysisService extends GeminiVisionTask<OilAnalysisResult> {
  GeminiOilAnalysisService._();
  static final GeminiOilAnalysisService instance = GeminiOilAnalysisService._();

  @override
  String get prompt => '''
You are an expert used cooking oil quality analyst for a recycling logistics app in Jordan.
Analyze the provided image and return a JSON object matching this exact schema:

{
  "isUsedCookingOil": boolean,
  "waterContent": "none" | "low" | "high",
  "impurityLevel": "clean" | "moderate" | "heavy",
  "grade": "A" | "B" | "C" | "rejected",
  "estimatedLiters": number,
  "estimatedPayoutMinJod": number,
  "estimatedPayoutMaxJod": number,
  "explanation": string
}

Grading criteria and payout rates (JOD per liter):
- Grade A: clean oil, no water, no impurities → 0.40–0.50 JOD/L
- Grade B: low water or moderate impurities → 0.20–0.30 JOD/L
- Grade C: high water or heavy impurities but still processable → 0.10–0.15 JOD/L
- Rejected: not cooking oil, or contaminated beyond processing → 0 JOD/L

Rules:
- Multiply estimated liters × rate to compute estimatedPayoutMinJod / estimatedPayoutMaxJod.
- If the image does not show used cooking oil, set isUsedCookingOil=false, grade="rejected",
  estimatedLiters=0, both payout fields=0.
- Write the "explanation" field in Arabic (2–3 sentences assessing quality and payout).
''';

  @override
  OilAnalysisResult fromJson(Map<String, dynamic> json) =>
      OilAnalysisResult.fromJson(json);
}
