import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/config/ai_config.dart';
import '../models/order.dart';

// ── Contract ──────────────────────────────────────────────────────────────────

abstract class IMarketAiService {
  Future<MarketAiResult> analyze(File image, {required Locale locale});
}

// ── Result DTO ────────────────────────────────────────────────────────────────

class MarketAiResult {
  final List<WasteType> wasteTypes;
  final WasteForm? wasteForm;
  final WeightCategory? weightCategory;
  final double? estimatedWeightKg;
  final double? approxPriceJd;
  final String? note;
  final double confidence;

  const MarketAiResult({
    this.wasteTypes = const [],
    this.wasteForm,
    this.weightCategory,
    this.estimatedWeightKg,
    this.approxPriceJd,
    this.note,
    this.confidence = 0.0,
  });

  factory MarketAiResult.fromJson(Map<String, dynamic> json) {
    return MarketAiResult(
      wasteTypes: _parseWasteTypes(json),
      wasteForm: _parseWasteForm(json['wasteForm']),
      weightCategory: _parseWeightCategory(json['weightCategory']),
      estimatedWeightKg: _coerceDouble(json['estimatedWeightKg'])?.clamp(0.1, 500.0),
      approxPriceJd: _coerceDouble(json['approxPriceJd'])?.clamp(0.1, 10000.0),
      note: json['note']?.toString(),
      confidence: _coerceDouble(json['confidence'])?.clamp(0.0, 1.0) ?? 0.0,
    );
  }

  /// Tolerant numeric parser — accepts num, int, double, and string literals
  /// like "12.5" or "1,200" that some Gemini responses occasionally emit
  /// despite responseMimeType being application/json.
  static double? _coerceDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').trim();
      return double.tryParse(cleaned);
    }
    return null;
  }

  // ── Parsing helpers ──────────────────────────────────────────────────────

  static List<WasteType> _parseWasteTypes(Map<String, dynamic> json) {
    final rawList = json['wasteTypes'];
    if (rawList is List) {
      return rawList.map(_parseOneWasteType).whereType<WasteType>().toList();
    }
    // Graceful fallback: legacy single-key response from older prompt versions
    final single = _parseOneWasteType(json['wasteType']);
    return single != null ? [single] : [];
  }

  static WasteType? _parseOneWasteType(dynamic value) {
    if (value == null) return null;
    final s = value.toString().toLowerCase();
    for (final type in WasteType.values) {
      if (type.name.toLowerCase() == s) return type;
    }
    // Common synonyms the model may use
    if (s == 'cardboard') return WasteType.paper;
    if (s == 'iron' || s == 'steel' || s == 'copper' || s == 'aluminium' || s == 'aluminum') return WasteType.metal;
    if (s == 'timber' || s == 'lumber') return WasteType.wood;
    if (s == 'pvc' || s == 'pet' || s == 'hdpe') return WasteType.plastic;
    return null;
  }

  static WasteForm? _parseWasteForm(dynamic value) {
    if (value == null) return null;
    final s = value.toString().toLowerCase();
    for (final form in WasteForm.values) {
      if (form.name.toLowerCase() == s) return form;
    }
    if (s == 'gaseous' || s == 'vapour' || s == 'vapor') return WasteForm.gas;
    return null;
  }

  static WeightCategory? _parseWeightCategory(dynamic value) {
    if (value == null) return null;
    final s = value.toString().toLowerCase();
    for (final cat in WeightCategory.values) {
      if (cat.name.toLowerCase() == s) return cat;
    }
    if (s == 'veryheavy' || s == 'very_heavy') return WeightCategory.veryHeavy;
    return null;
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class MarketAiService implements IMarketAiService {
  final GenerativeModel _model;

  /// Production constructor — reads key from compile-time env.
  MarketAiService() : _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: AiConfig.geminiApiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.2,
    ),
  );

  /// Injection constructor for tests — accepts a pre-built model.
  MarketAiService.withModel(this._model);

  @override
  Future<MarketAiResult> analyze(File image, {required Locale locale}) async {
    if (!AiConfig.hasGeminiKey) {
      throw Exception('Gemini API key not configured');
    }

    final bytes = await image.readAsBytes();
    final prompt = _buildPrompt(locale);
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(_mimeType(image), bytes),
      ])
    ];

    return _callWithRetry(content);
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<MarketAiResult> _callWithRetry(
    List<Content> content, {
    int maxAttempts = 2,
  }) async {
    Exception? lastError;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _model.generateContent(content);
        final text = response.text;
        if (text == null || text.isEmpty) {
          throw const FormatException('Empty response from Gemini');
        }
        final decoded = jsonDecode(text);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Gemini response was not a JSON object');
        }
        return MarketAiResult.fromJson(decoded);
      } on Exception catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    throw lastError!;
  }

  /// Detects MIME type from file extension so PNG/WebP images are sent correctly.
  static String _mimeType(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg', // jpg, jpeg, heic — all served as JPEG to Gemini
    };
  }

  String _buildPrompt(Locale locale) {
    final language = locale.languageCode == 'ar' ? 'Arabic' : 'English';

    return '''
You are the "Dawer AI Agent" — an expert waste classification assistant for the Dawer recycling app in Jordan.
Your ONLY job is to analyze the image and return a structured JSON object that fills every form field.

## PRIMARY MATERIALS (highest priority — identify these first):
1. WOOD — timber, planks, pallets, furniture frames, branches, plywood, MDF
2. METAL — iron, steel, aluminium, copper, tin, scrap pipes, wires, cans, appliances
3. PLASTIC — PET bottles, HDPE containers, PVC pipes, plastic bags, foam
4. CARDBOARD — boxes, sheets, packaging (map to wasteTypes: ["paper"])

## OTHER SUPPORTED TYPES:
glass, electronics, organic, textile, rubber, oil, chemicals, batteries, furniture, tires, construction

## MATERIAL STATE (wasteForm):
- "solid" — rigid or firm shape (default for wood, metal, plastic, cardboard)
- "liquid" — flows freely (oil, chemical waste, contaminated water)
- "gas" — aerosol cans, gas cylinders, chemical vapors, pressurized containers
- "mixed" — clearly inseparable combination of solid + liquid, or solid + gas

## WEIGHT ESTIMATION GUIDE:
- Wood pallet (standard): 15–25 kg → medium/heavy
- Metal pipes (2m length each, 5 pieces): 30–60 kg → heavy
- Cardboard boxes (collapsed, stack): 10–20 kg → medium
- Plastic bottles (bag of 30): 1.5–2.5 kg → light
- Metal scrap (small pile): 5–30 kg → medium/heavy
- Furniture (single chair): 8–15 kg → medium
- Electronics (single device): 0.5–5 kg → light/medium

## JORDAN MARKET PRICING GUIDE (Jordanian Dinars - JD):
- Cardboard/paper: 0.05–0.10 JD/kg → 10 kg = 0.5–1.0 JD
- Plastic PET: 0.15–0.25 JD/kg → 2 kg = 0.3–0.5 JD
- Iron/steel scrap: 0.08–0.12 JD/kg → 50 kg = 4–6 JD
- Aluminium: 0.5–0.8 JD/kg → 10 kg = 5–8 JD
- Copper wire: 2–4 JD/kg → 5 kg = 10–20 JD
- Wood (clean): 0.01–0.03 JD/kg → 20 kg = 0.2–0.6 JD
- Electronics (per device): 0.5–3 JD each

## REQUIRED JSON OUTPUT (all fields required, no nulls):
{
  "wasteTypes": ["slug1", "slug2"],
  "wasteForm": "solid|liquid|gas|mixed",
  "weightCategory": "light|medium|heavy|veryHeavy",
  "estimatedWeightKg": 12.5,
  "approxPriceJd": 1.5,
  "note": "Description in $language",
  "confidence": 0.95
}

RULES:
- "wasteTypes" is always an array — never a string. List 1–4 types, dominant first.
- "weightCategory" thresholds: light=0–5 kg, medium=5–20 kg, heavy=20–100 kg, veryHeavy=100 kg+
- "confidence": 0.0–1.0. Use < 0.6 for blurry/unclear images, > 0.85 for clearly identifiable items.
- Write "note" in $language.

## FEW-SHOT EXAMPLES:

Example 1 — Cardboard:
{"wasteTypes": ["paper"], "wasteForm": "solid", "weightCategory": "medium", "estimatedWeightKg": 12.0, "approxPriceJd": 1.0, "note": "Collapsed cardboard boxes (approx 15 units), dry and clean. Good recycling quality.", "confidence": 0.97}

Example 2 — Plastic bottles:
{"wasteTypes": ["plastic"], "wasteForm": "solid", "weightCategory": "light", "estimatedWeightKg": 2.5, "approxPriceJd": 0.5, "note": "Bag of clear PET plastic water bottles, approximately 30–40 pieces. Lightly compressed.", "confidence": 0.96}

Example 3 — Iron scrap:
{"wasteTypes": ["metal"], "wasteForm": "solid", "weightCategory": "heavy", "estimatedWeightKg": 40.0, "approxPriceJd": 4.0, "note": "Iron scrap pipes and rods, mixed lengths. Light surface rust. Suitable for scrap metal collection.", "confidence": 0.95}

Example 4 — Wooden pallet:
{"wasteTypes": ["wood"], "wasteForm": "solid", "weightCategory": "medium", "estimatedWeightKg": 18.0, "approxPriceJd": 0.5, "note": "Standard wooden shipping pallet, structurally damaged. Dry wood, suitable for chipping or small resale.", "confidence": 0.94}

Example 5 — Aerosol cans:
{"wasteTypes": ["chemicals"], "wasteForm": "gas", "weightCategory": "light", "estimatedWeightKg": 1.5, "approxPriceJd": 0.3, "note": "Empty aerosol spray cans. Requires puncturing before recycling. Handle with care.", "confidence": 0.90}

Example 6 — Used motor oil:
{"wasteTypes": ["oil"], "wasteForm": "liquid", "weightCategory": "medium", "estimatedWeightKg": 8.0, "approxPriceJd": 2.0, "note": "Used motor oil in container. Dark color indicating high degradation. Requires specialized collection.", "confidence": 0.93}

Example 7 — Mixed recyclables:
{"wasteTypes": ["metal", "plastic", "paper"], "wasteForm": "solid", "weightCategory": "medium", "estimatedWeightKg": 8.0, "approxPriceJd": 1.2, "note": "Mixed recyclables: metal cans (dominant), plastic bottles, and cardboard scraps. Sorting recommended before collection.", "confidence": 0.88}

Example 8 — Electronics + batteries:
{"wasteTypes": ["electronics", "batteries"], "wasteForm": "solid", "weightCategory": "light", "estimatedWeightKg": 3.5, "approxPriceJd": 2.5, "note": "Used smartphones and tablets with a bag of AA batteries. Requires certified e-waste handling. Do not crush.", "confidence": 0.93}

Example 9 — Mixed liquid + solid (wasteForm: mixed):
{"wasteTypes": ["chemicals", "plastic"], "wasteForm": "mixed", "weightCategory": "medium", "estimatedWeightKg": 6.0, "approxPriceJd": 0.8, "note": "Leaking chemical containers mixed with plastic wrapping. Cannot be separated. Handle with gloves.", "confidence": 0.85}

Available WasteType slugs: ${WasteType.values.map((e) => e.name).join(', ')}
''';
  }
}
