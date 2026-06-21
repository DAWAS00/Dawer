# 7. AI Services

## Overview

Dwaar uses AI for two main purposes:

1. **Generative AI with Google Gemini** — document understanding, vehicle registration OCR, and waste photo classification.
2. **On-device ML Kit** — fast, offline image labeling for the support chatbot.

## Google Generative AI

Dependency:

```yaml
google_generative_ai: ^0.4.6
```

Model used throughout: **Gemini 1.5 Flash**.

API key is read from `.env.local` via `AiConfig`:

```dart
// lib/core/config/ai_config.dart
class AiConfig {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  static void assertConfigured() {
    if (!hasGeminiKey) {
      debugPrint('WARNING: GEMINI_API_KEY is not set. AI features will fail.');
    }
  }
}
```

## Vehicle registration extraction

### Service

`GeminiVehicleRegistrationService` analyzes Jordanian vehicle registration documents and extracts structured data.

```dart
// lib/data/services/gemini_vehicle_registration_service.dart
class GeminiVehicleRegistrationService implements IAiVehicleRegistrationService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: AiConfig.geminiApiKey,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.1,
    ),
  );

  Future<VehicleRegistrationResult> extractVehicleData(String filePath) async {
    ...
  }
}
```

### Prompt

The prompt instructs Gemini to return strict JSON:

```json
{
  "isVehicleRegistration": true,
  "vehicleClass": "بيك آب",
  "make": "تويوتا",
  "model": "هايلوكس",
  "color": "أبيض",
  "plateNumber": "11 - 12345",
  "registrationExpiry": "YYYY-MM-DD",
  "hasChemicalPermit": false,
  "confidence": 0.95
}
```

### Mapping to app enums

The service maps Arabic vehicle-class strings to the `VehicleType` enum:

```dart
static VehicleType _mapVehicleType(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('دراجة') || s.contains('motorcycle')) return VehicleType.motorcycle;
  if (s.contains('شاحنة ثقيلة') || s.contains('heavy')) return VehicleType.heavyTruck;
  if (s.contains('شاحنة') || s.contains('truck')) return VehicleType.truck;
  if (s.contains('فان') || s.contains('ونيت') || s.contains('van')) return VehicleType.van;
  if (s.contains('بيك') || s.contains('pickup')) return VehicleType.pickup;
  return VehicleType.car;
}
```

## Marketplace waste classification

### Service

`MarketAiService` analyzes a waste photo and suggests type, form, weight, and price.

```dart
// lib/data/services/market_ai_service.dart
class MarketAiService implements IAIMarketplaceService {
  Future<MarketAiResult> analyzeWastePhoto(String filePath) async {
    final response = await _model.generateContent([
      Content.multi([
        TextPart(_prompt),
        DataPart(_mimeType(file), bytes),
      ]),
    ]);
    return _parseJson(response.text);
  }
}
```

### Expected JSON output

```json
{
  "wasteTypes": ["plastic", "metal"],
  "wasteForm": "solid",
  "weightCategory": "medium",
  "estimatedWeightKg": 15.0,
  "approxPriceJd": 3.50,
  "note": "Clean plastic bottles mixed with aluminum cans",
  "confidence": 0.82
}
```

## License / identity validation

`GeminiLicenseValidationService` validates identity or business documents per role and suggests waste categories.

```dart
// lib/data/services/gemini_license_validation_service.dart
class GeminiLicenseValidationService implements IAILicenseValidationService {
  Future<LicenseValidationResult> validateDocument(...) async { ... }
}
```

## On-device ML Kit

Dependency:

```yaml
google_mlkit_image_labeling: ^0.13.0
```

Used by `DawaChatViewModel` for fast, offline waste labeling inside the support chatbot. It is not used for marketplace pricing or document extraction.

## Mock AI services

For offline development, mock counterparts exist:

- `MockAiVehicleRegistrationService`
- `MockMarketAiService`
- `MockLicenseValidationService`

Several onboarding viewmodels still wire the mock services with TODOs to replace them with real Gemini implementations:

- `individual_supplier_onboarding_viewmodel.dart`
- `recycling_co_onboarding_viewmodel.dart`
- `store_onboarding_viewmodel.dart`

## AI sign-up verification prototype

The "AI sign-up verification" feature (`plan/feature-ai-signup-verification-1.md`, recent commit `8631369`) adds a demo-friendly scanning flow with:

- Scanning overlays and data-pulse animations.
- Extracted-data cards.
- "AI Liveness Check" badge.

It is designed to look alive for demos and judges but must be hardened for production.

## Files referenced

- `lib/core/config/ai_config.dart`
- `lib/data/services/gemini_vehicle_registration_service.dart`
- `lib/data/services/market_ai_service.dart`
- `lib/data/services/gemini_license_validation_service.dart`
- `lib/data/services/mock_ai_service.dart`
- `lib/domain/services/i_ai_vehicle_registration_service.dart`
- `lib/domain/services/i_ai_marketplace_service.dart`
- `lib/domain/services/i_ai_license_validation_service.dart`
- `lib/ui/features/chatbot/viewmodels/dawa_chat_viewmodel.dart`
- `plan/feature-ai-signup-verification-1.md`
