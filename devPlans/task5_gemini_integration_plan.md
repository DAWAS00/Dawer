# Task 5: Real AI & OCR Integration (Gemini API)

## Overview
Replace the hardcoded `MockAiService` with a real implementation using the `google_generative_ai` package. We will use Google's Gemini models for both text generation (category suggestions) and vision/OCR (license document validation).

## Prerequisites
- `google_generative_ai` package is already in `pubspec.yaml`.
- `flutter_dotenv` is already in `pubspec.yaml`.

## Implementation Phases

### Phase 1: Configuration & Setup
1. **Environment Variables**:
   - Add `GEMINI_API_KEY=your_api_key_here` to `.env` and `.env.local` files.
2. **Config Class**:
   - Create `lib/core/config/gemini_config.dart`.
   - Add a method to retrieve the key: `String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';`
   - Add initialization check to ensure the app fails early if the key is missing.

### Phase 2: Create `GeminiAiService`
Create `lib/data/services/gemini_ai_service.dart` implementing the same interface as the mock.

1. **Text Generation (`getOnboardingSuggestions`)**:
   - Initialize `GenerativeModel` with `gemini-1.5-flash`.
   - **Prompt Design**: "You are an assistant for a recycling app in Jordan. Given the company name '{name}' and tagline '{tagline}', suggest 3-5 recycling categories (e.g., Plastic, Electronics) in Arabic. Return only a JSON list of strings."
   - Parse the JSON response.

2. **Vision & OCR (`validateLicense`)**:
   - Initialize `GenerativeModel` with `gemini-1.5-flash` (it supports multimodal inputs).
   - Read the local image file as bytes (`File(imagePath).readAsBytes()`).
   - Create a `DataPart` with the image bytes and mime type.
   - **Prompt Design**: "Analyze this Jordanian business license. Extract the following information in Arabic: 'Company Name' (اسم الشركة), 'License Number' (رقم الترخيص), 'Expiry Date' (تاريخ الانتهاء), and 'Status' (حالة الترخيص). Return the result as a strict JSON object."
   - Handle potential failures (e.g., blurry image, not a license) by asking Gemini to return an error JSON structure if data is missing.

### Phase 3: ViewModel Integration
Update the viewmodels to use the new service:
- `lib/ui/features/auth/viewmodels/store_onboarding_viewmodel.dart`
- `lib/ui/features/auth/viewmodels/individual_supplier_onboarding_viewmodel.dart`
- `lib/ui/features/auth/viewmodels/recycling_co_onboarding_viewmodel.dart`

**Tasks**:
- Inject `GeminiAiService` instead of `MockAiService`.
- Add robust error handling (try/catch blocks) to manage API rate limits or network failures. Fallback to manual entry if AI fails.
- Update UI to show loading spinners during API calls.

### Phase 4: Cleanup & Testing
1. **Delete Mocks**: Remove `lib/data/services/mock_ai_service.dart`.
2. **Remove TODOs**: Scan the codebase and remove all `TODO: Replace MockAiService with real AI API` comments.
3. **Testing**: 
   - Test text generation with various company names.
   - Test OCR with a sample license image (can use `assets/images/sample_wood.jpg` or similar as a test fixture if a real license isn't available, but ensure the prompt handles invalid images gracefully).

## Risks & Mitigations
- **Latency**: Real API calls take 2-5 seconds. UI must show clear loading indicators (`CircularProgressIndicator`).
- **Parsing Errors**: LLMs can return malformed JSON. Wrap JSON parsing in `try/catch` and use prompt engineering to enforce strict JSON schemas.