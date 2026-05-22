# Production Gaps & Solutions

## 1. Local Backend Integration Incomplete
**Problem**: `lib/backend_integration_locally/` missing `models/` (`local_user.dart`, `otp_record.dart`), `local_auth_service.dart`, `local_notification_service.dart`. `auth_service.dart` and `user_signup_service.dart` not fully wired. SharedPreferences missing.
**Solution**: 
- Create `models/local_user.dart` + `models/otp_record.dart`.
- Write `local_auth_service.dart` to handle OTP + user CRUD.
- Write `local_notification_service.dart` for OTP banner.
- Wire `auth_service.dart` and `main.dart` to new local backend.

## 2. Supabase Removal Incomplete 
**Problem**: `supabase_flutter` still in `pubspec.yaml`. `env.dart` + `supabase_client.dart` not deleted. `docs/supabase-removal-plan.md` blocked.
**Solution**: 
- Drop `supabase_flutter` from `pubspec.yaml`. Run `flutter pub get`.
- Delete `env.dart`, `supabase_client.dart`, `supabase_connect_test.dart`.
- Clean up `main.dart` Supabase init logic.
- Delete `/supabase` root folder.

## 3. AI Signup Verification Prototype Missing
**Problem**: `plan/feature-ai-signup-verification-1.md` planned but missing. No scanning animation or AI extraction feedback in UI.
**Solution**: 
- Build `_ScanningOverlay` + `_DataPulseOverlay` in `license_scan_section.dart`.
- Update `MockAiLicenseValidationService` with mock data.
- Build `_ExtractedDataCard`.
- Add "AI Liveness Check" badge.

## 4. RTL Arabic UI/Chat Not Enforced
**Problem**: `plan/process-rtl-arabic-chat-1.md` planned but missing. Chat and text inputs lack strict RTL direction/alignment. 
**Solution**: 
- Add `direction: rtl` / `text-align: right` rules to chat UI.
- Mirror UI components (avatars, timestamps) for RTL.
- Handle BiDi text (English/numbers inside Arabic).

## 5. Real AI & OCR Integration Missing
**Problem**: `MockAiService` and `MockAiSimulationService` full of TODOs. Real API calls not implemented.
**Solution**: 
- Implement real OCR.
- Wire `google_generative_ai` API calls to replace `MockAiService.getOnboardingSuggestions` and `validateLicense`.
- Remove TODOs.

## Next Steps
- Execute #1 + #2 first (Backend + Supabase purge).
- Execute #3 + #5 (AI Features).
- Execute #4 (UI Polish).