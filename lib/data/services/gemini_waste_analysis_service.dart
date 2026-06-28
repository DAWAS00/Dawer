import '../models/waste_analysis_result.dart';
import 'gemini_vision_task.dart';

/// Gemini Vision quality analysis for ANY recyclable material type.
///
/// Works for: used cooking oil, construction wood, plastic, metal, paper,
/// glass, electronics, textiles, rubber, batteries, chemicals, furniture,
/// tires, organic waste, and anything else visible in the image.
///
/// Extends [GeminiVisionTask] — all I/O, timeout, safety settings,
/// JSON mode, and error handling are inherited.
class GeminiWasteAnalysisService extends GeminiVisionTask<WasteAnalysisResult> {
  GeminiWasteAnalysisService._();
  static final GeminiWasteAnalysisService instance =
      GeminiWasteAnalysisService._();

  @override
  String get prompt => '''
You are an expert waste quality analyst for the Dawer recycling app in Jordan.
Analyze the provided image and return a JSON object matching this exact schema — no extra text.

REQUIRED JSON SCHEMA:
{
  "isRecyclable": boolean,
  "materialType": "Arabic name of the material (e.g. زيت طبخ مستعمل, خشب بناء, بلاستيك, معادن)",
  "materialTypeEn": "one slug from the list below",
  "grade": "A" | "B" | "C" | "rejected",
  "estimatedQuantity": number,
  "quantityUnit": "لتر" (liquids) | "كغ" (solids by weight) | "قطعة" (items/pieces),
  "estimatedPayoutMinJod": number,
  "estimatedPayoutMaxJod": number,
  "explanation": "2–3 Arabic sentences assessing quality and recommending action",
  "recycleTips": ["tip 1 in Arabic", "tip 2 in Arabic"]
}

MATERIAL SLUGS for materialTypeEn:
used_cooking_oil | wood | plastic | metal | paper | glass | electronics |
textile | rubber | batteries | chemicals | furniture | tires | organic | unknown

GRADING CRITERIA:
- Grade A: excellent, clean, high purity → top payout
- Grade B: good, minor contamination or wear → medium payout
- Grade C: acceptable but significantly contaminated or damaged → low payout
- Rejected: non-recyclable, too contaminated, or unidentifiable → 0 JOD

JORDANIAN MARKET PAYOUT RATES:
Used cooking oil : A=0.40–0.50 JOD/L,  B=0.20–0.30 JOD/L,  C=0.10–0.15 JOD/L
Construction wood: A=0.08–0.12 JOD/kg, B=0.03–0.07 JOD/kg, C=0.01–0.02 JOD/kg
Cardboard/paper  : A=0.05–0.08 JOD/kg, B=0.02–0.04 JOD/kg, C=0.01 JOD/kg
Plastic (PET)    : A=0.15–0.25 JOD/kg, B=0.06–0.14 JOD/kg, C=0.01–0.05 JOD/kg
Iron/steel scrap : A=0.10–0.14 JOD/kg, B=0.06–0.09 JOD/kg, C=0.02–0.05 JOD/kg
Aluminum         : A=0.60–0.90 JOD/kg, B=0.35–0.59 JOD/kg, C=0.15–0.34 JOD/kg
Copper           : A=2.50–4.00 JOD/kg, B=1.50–2.49 JOD/kg, C=0.50–1.49 JOD/kg
Glass (clean)    : A=0.02–0.04 JOD/kg, B=0.01–0.02 JOD/kg, C=0 JOD/kg
Electronics      : A=1.00–5.00 JOD/item, B=0.25–0.99 JOD/item, C=0.10–0.24 JOD/item
Textile/clothes  : A=0.08–0.12 JOD/kg, B=0.02–0.07 JOD/kg, C=0 JOD/kg
Rubber/tires     : A=0.04–0.08 JOD/kg, B=0.01–0.03 JOD/kg, C=0 JOD/kg
Batteries        : A=0.10–0.30 JOD/kg (hazardous — certified collection required)
Organic waste    : A=0.01–0.03 JOD/kg (compost value)

CALCULATION RULES:
- estimatedPayoutMinJod = estimatedQuantity × min_rate_for_grade
- estimatedPayoutMaxJod = estimatedQuantity × max_rate_for_grade
- If isRecyclable is false: grade="rejected", both payout fields=0, explanation should explain why.
- estimatedQuantity = realistic visual estimate; use 0 if impossible to determine.
- recycleTips: practical Arabic tips (e.g. storage, cleaning, collection steps).
- If you cannot identify any waste, set isRecyclable=false, materialTypeEn="unknown".
''';

  @override
  WasteAnalysisResult fromJson(Map<String, dynamic> json) =>
      WasteAnalysisResult.fromJson(json);
}
