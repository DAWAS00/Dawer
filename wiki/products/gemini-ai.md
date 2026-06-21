---
name: gemini-ai
description: Google Gemini AI integration — vehicle registration scan, license validation, marketplace AI service, and Dawa chatbot
metadata:
  type: product
---

# Google Gemini AI

Package: `google_generative_ai: ^0.4.6`

Config: `lib/core/config/ai_config.dart` — `AiConfig.assertConfigured()` crashes at startup if `GEMINI_API_KEY` missing from `.env.local`.

## Services

### GeminiVehicleRegistrationService
`lib/data/services/gemini_vehicle_registration_service.dart`

Scans a vehicle registration photo and extracts:
- License plate number
- Vehicle model
- Vehicle color

Interface: `IAiVehicleRegistrationService`
Mock: `MockAiVehicleRegistrationService`

### GeminiLicenseValidationService
`lib/data/services/gemini_license_validation_service.dart`

Validates a driver's license photo (authenticity, expiry, etc.).

Interface: `IAiLicenseValidationService`
Mock: `MockAiLicenseValidationService`

### MarketAiService
`lib/data/services/market_ai_service.dart`

Gemini-powered marketplace suggestions — analyzes user waste categories and recommends relevant market listings.

Interface: `IAiMarketplaceService`
Mock: `MockMarketAiService`, `MockAiMarketplaceService`

### DawaChatbotService
`lib/ui/features/chatbot/dawa_chatbot_service.dart`

Gemini chat for the Dawa marketplace assistant FAB. Answers questions about waste types, prices, and the marketplace.

Also: `DawaImageScanService` — image analysis for marketplace items.

## Mock vs Real

All AI services implement interfaces from `lib/domain/services/`. VMs accept the interface so tests use mocks. The production VM constructors wire the Gemini implementation.

`MockAiSimulationService` and `MockAiValidationService` exist for additional mock scenarios.

## ML Kit

`google_mlkit_image_labeling: ^0.13.0` — local on-device image labeling. Used for waste type classification from camera images (complementary to Gemini).

## Related Pages

- [[patterns/mock-to-real-swap]]
- [[concepts/features-done-vs-next]]
