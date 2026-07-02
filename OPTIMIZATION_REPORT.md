# Dawer — Code Cleanup & Optimization Report

**Date**: 2026-06-27  
**Result**: `flutter analyze` → **0 issues** before and after all changes

---

## What Was Done

### 1. Deleted Dead Files (11 files removed)

These files were never imported by any live screen or service. Keeping them added compile weight, confused future contributors, and created a false impression that features were still in progress.

| File | Why deleted |
|---|---|
| `lib/data/services/mock_ai_validation_service.dart` | Replaced by `GeminiAiValidationService`; zero remaining imports |
| `lib/data/services/mock_ai_license_validation_service.dart` | Replaced by `GeminiAiLicenseValidationService`; zero remaining imports |
| `lib/data/services/mock_ai_marketplace_service.dart` | Replaced by `GeminiAiMarketplaceService`; zero remaining imports |
| `lib/data/services/mock_ai_simulation_service.dart` | Replaced by `GeminiAiSimulationService`; zero remaining imports |
| `lib/data/services/mock_brand_profile_ai_service.dart` | Replaced by `GeminiBrandProfileAiService`; zero remaining imports |
| `lib/data/services/mock_ai_base.dart` | Base class only used by the 5 mock services above; obsolete |
| `lib/data/services/waste_classifier_service.dart` | Implemented `IWasteClassifier` but was never imported or injected anywhere; the chatbot uses `DawaImageScanService` directly for ML Kit |
| `lib/domain/services/i_waste_classifier.dart` | Interface only referenced by the deleted `waste_classifier_service.dart` |
| `lib/ui/features/auth/views/widgets/ai_photo_validation_widget.dart` | Widget never imported in any screen; unreachable in production |
| `lib/ui/features/auth/viewmodels/ai_photo_validation_viewmodel.dart` | ViewModel only referenced from the deleted widget above |
| `test/data/services/mock_ai_simulation_service_test.dart` | Test file testing a deleted mock class; no longer valid |

**Lines removed: ~420**

---

### 2. Removed Dead ViewModel Code

**File**: `lib/ui/features/auth/viewmodels/recycling_co_onboarding_viewmodel.dart`

Removed the entire "Marketplace Interests" section (~32 lines):

```dart
// REMOVED — never called from any view
final Set<String> _selectedInterests = {};
Set<String> get selectedInterests => ...
String? marketplaceContent;
bool isGeneratingMarketplace = false;
void toggleInterest(String interest) { ... }
Future<void> generateMarketplaceContent() async { ... }
```

`generateMarketplaceContent()` contained a hardcoded `Future.delayed(2s)` and a template string — not AI-powered and never wired to any UI. `toggleInterest()` and the `selectedInterests` getter were never called from `recycling_co_onboarding_view.dart`.

**Lines removed: 32**

---

### 3. Removed Placeholder Data from Model

**File**: `lib/data/models/restaurant_registration_data.dart`

Removed the `metadata` block from `toJson()`:

```dart
// REMOVED from toJson()
'metadata': {
  // [FUTURE IMPLEMENTATION: AI API Integration]
  // Provide the real API key or references here later.
  'aiApiKeyUsed': '[PLACEHOLDER_FOR_FUTURE_API_KEY]'
}
```

This was a leftover stub that serialized a literal placeholder string into every restaurant JSON payload. No code ever read this field.

**Lines removed: 6**

---

### 4. Removed Stale Commented-Out Code

**File**: `lib/core/utils/app_logger.dart`

Removed:
```dart
// TODO(Phase 3): forward to Firebase Crashlytics in release builds
// if (!kDebugMode) FirebaseCrashlytics.instance.recordError(error, stackTrace);
```

Firebase Crashlytics is not yet a dependency and won't be until Phase 3 of the migration plan. The commented-out code referenced a class (`FirebaseCrashlytics`) that doesn't exist in the project, which would cause a compile error if uncommented accidentally. The reminder belongs in PHASES.md, not inline in production code.

**Lines removed: 2**

---

## Summary of Changes

| Category | Files affected | Lines removed |
|---|---|---|
| Deleted dead files | 11 | ~420 |
| Dead ViewModel code | 1 | 32 |
| Placeholder model data | 1 | 6 |
| Stale commented code | 1 | 2 |
| **Total** | **14** | **~460** |

---

## What Was NOT Changed (and Why)

| Item | Reason kept |
|---|---|
| `lib/data/repositories/mock_auth_repository.dart` | Still actively used in `main.dart` as a dev fallback when Supabase fails to initialize |
| `lib/data/repositories/no_op_order_repository.dart` | Used as the default parameter in `AppOrderStore` constructor; functional |
| `lib/core/utils/app_logger.dart` debug-only `debugPrint` | Correctly guarded by `kDebugMode`; safe in production |
| `// TODO` localization comments in `license_scan_section.dart` | These are genuine work items requiring ARB file changes, not dead code |
| `// TODO` in `store_onboarding_viewmodel.dart` (persist categories) | Active work item, not dead code |
| `lib/ui/features/chatbot/service/` KB files | Used by `DawaChatbotService` for follow-up chip responses |
| `IBrandProfileAiService` import in onboarding ViewModels | `BrandProfile` type is defined there and used as a field type |

---

## Current State

- **`flutter analyze`**: 0 issues
- **`flutter test`**: All existing tests pass (obsolete mock test removed)
- **AI services**: All 5 are now backed by Gemini 1.5 Flash (real API calls)
- **Chatbot**: Gemini-powered for typed messages; local KB for chip navigation
- **Dead code**: None remaining in `lib/`
