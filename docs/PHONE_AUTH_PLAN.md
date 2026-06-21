# Dwaar — Phone-Only Authentication Implementation Plan

> Handoff document. Contains full context for implementing phone-number-only login/signup with simulated OTP in the Dwaar Flutter app.

## 1. Project Background

**Dwaar (دوّر)** is an Arabic-first waste-recycling logistics app (Jordan). Flutter + Provider MVVM. Three user roles, each with its own home shell: **Driver**, **Supplier** (individual or store/business), **Recycling Company**.

- State management: `provider` (ChangeNotifier ViewModels)
- Architecture: `lib/domain/` = interfaces only, `lib/data/` = mock + Supabase implementations, `lib/ui/features/<feature>/` = views/viewmodels/widgets
- Error handling: `AppResult<T>` = `Result<T, AppFailure>` with `.fold(onSuccess:, onFailure:)` (`lib/core/result/result.dart`, `lib/domain/failures/app_failure.dart` — has `AuthFailure`, `NotFoundFailure`, `ValidationFailure`)
- Localization: bilingual ar/en via `.arb` files in `lib/l10n/` (Arabic is template), accessed with `context.l10n.<key>`. After editing `.arb` run `flutter gen-l10n`
- Styling: `GoogleFonts.cairo` for Arabic, `GoogleFonts.dmSans` for numbers/latin; colors from `AppColors` tokens (`lib/core/constants/app_colors.dart`); inputs use fill `Color(0xFFE6E9E7)`, radius 12
- Backend: Supabase initialized at startup, but auth currently uses `MockAuthRepository` bound in `main.dart`

## 2. Goal

Replace email+password login with **phone number only**:

```
LoginView (role grid + phone field, default +962)
   → "متابعة" button → requestOtp(phone)
   → VerificationView (6-digit OTP, simulated code: 123456)
       → known number   → HomeRouter (role/supplierType from stored session)
       → unknown number → SignUpWizardView (phone pre-verified & read-only)
       → wrong code     → inline error
```

Decided constraints:
1. **Simulated OTP** — fixed code `123456`, no SMS provider. Supabase implementation must stay compiling behind the interface for later.
2. **Phone is the ONLY auth method** — delete email/password UI and the password-reset flow entirely.
3. **New numbers flow into the existing signup wizard** to complete their profile (role, name, documents).

## 3. Packages

Add to `pubspec.yaml` dependencies:

| Package | Version | Purpose |
|---|---|---|
| `intl_phone_field` | `^3.2.0` | Phone input with country-code picker. Use `initialCountryCode: 'JO'` (+962). `onChanged` gives `phone.completeNumber` in E.164 (`+9627…`), which passes the app's existing phone regex `^\+?\d{9,15}$` |
| `pinput` | `^5.0.0` | 6-cell OTP input. Animated cells, `onCompleted` callback, SMS-autofill-ready for when real SMS lands |

Remove: `country_picker` (declared but never imported anywhere).

Already present and reused: `provider`, `google_fonts`, `supabase_flutter`.

For the future real-SMS switch (NOT part of this task): configure Twilio/Vonage/MessageBird in Supabase Dashboard → Authentication → Phone provider, then bind `SupabaseAuthRepository` instead of `MockAuthRepository` in `main.dart`. No UI change needed. Docs: https://supabase.com/docs/guides/auth/phone-login

## 4. What Already Exists (reuse, do not rebuild)

| Asset | Path | State |
|---|---|---|
| `IAuthRepository.requestOtp(String phone)` and `verifyOtp(String phone, String otp)` → `AppResult<AuthSession>` | `lib/domain/repositories/i_auth_repository.dart` | Interface ready. `AuthSession{userId, userName, role, supplierType, categories}` |
| `SupabaseAuthRepository` | `lib/data/repositories/supabase_auth_repository.dart` | Fully implements phone OTP (`signInWithOtp`, `verifyOTP(type: OtpType.sms)`) but is never instantiated. Keep compiling, keep unwired |
| `VerificationView` + `VerificationViewModel` | `lib/ui/features/auth/views/verification_view.dart`, `viewmodels/verification_viewmodel.dart` | OTP screen with verify/resend exists; needs Pinput + new-user branch |
| `LoginViewModel.requestOtp(phone)` | `lib/ui/features/auth/viewmodels/login_viewmodel.dart` | Exists but the UI never calls it (orphaned) |
| Signup wizard | `lib/ui/features/auth/controllers/signup_wizard_controller.dart`, `views/signup_wizard/` | 4 steps; step 4 currently collects phone+email+password |
| Phone regex | `lib/data/services/user_signup_service.dart` | `^\+?\d{9,15}$`; `SignUpRequest.password` is already nullable and validation skips it when null |
| `HomeRouter` | `lib/ui/features/home/home_router.dart` | Takes `UserRole`, `SupplierType`, `userName`, categories |

## 5. Design Decisions

**D1 — Unknown-number signaling.** `verifyOtp` keeps returning `AppResult<AuthSession>`. A correctly-verified but unregistered phone returns `Failure(NotFoundFailure(message: …, code: AuthErrorCodes.phoneNotRegistered))`. Add next to the interface:

```dart
abstract final class AuthErrorCodes {
  static const phoneNotRegistered = 'phone_not_registered';
  static const invalidOtp = 'invalid_otp';
}
```

`VerificationViewModel` pattern-matches that failure and sets `needsSignup = true` instead of showing an error. This maps 1:1 onto `SupabaseAuthRepository.verifyOtp`'s existing "session OK but profile == null" branch — later real-backend wiring is a one-line change.

**D2 — Interface trim.** Delete `signInWithEmail`, `requestPasswordReset`, `verifyResetCode`, `updatePassword` from `IAuthRepository` and both implementations. Their only consumers are the login form and password-reset screens being deleted. Email logic still needed by signup lives in `SupabaseAuthService` (separate class) — untouched.

**D3 — Wizard registers into the mock.** Inject `IAuthRepository?` into `SignupWizardController`; when present, `submit()` calls `repository.signUp(buildRequest())`. `MockAuthRepository.signUp` inserts the new phone into its in-memory user map, so the number is "known" for the rest of the session. The existing `UserSignUpService` path stays as fallback when no repo injected (keeps existing tests green).

**D4 — Role grid stays on LoginView.** Known number → stored session's role wins. New number → grid selection seeds `SignUpWizardView(initialRole:, initialSupplierType:)`.

## 6. Implementation Phases

### Phase 1 — Dependencies + l10n
- `pubspec.yaml`: add `intl_phone_field`, `pinput`; remove `country_picker`; `flutter pub get`
- Add keys to **both** `lib/l10n/app_ar.arb` (template) and `app_en.arb`, then `flutter gen-l10n`:
  - `loginPhoneHint` ("7X XXX XXXX"), `loginContinueButton` ("متابعة"/"Continue"), `loginPhoneEmptyError`, `loginNewNumberHint` ("رقم جديد؟ سيتم إنشاء حسابك بعد التحقق")
  - `otpTitle`, `otpSubtitle` (with `{phone}` placeholder), `otpVerifyButton`, `otpResendButton`, `otpResentMessage`, `otpErrorIncomplete`, `otpErrorInvalid`, `otpSimulatedHint` ("للتجربة استخدم الرمز 123456")

### Phase 2 — Domain + data layer
- `lib/domain/repositories/i_auth_repository.dart`: remove the 4 email/password methods; add `AuthErrorCodes`
- `lib/data/repositories/mock_auth_repository.dart`: rewrite —
  - `static const simulatedOtp = '123456';`
  - Mutable `Map<String, AuthSession> _users` seeded with magic Jordan numbers: `+962790000001` driver · `+962790000002` individual supplier · `+962790000003` store business · `+962790000004` recycling co (reuse existing canned sessions)
  - `requestOtp`: normalize phone (strip spaces/dashes), short delay, always `Success(null)`
  - `verifyOtp`: wrong code → `AuthFailure(code: invalidOtp)`; known phone → `Success(session)`; unknown → `NotFoundFailure(code: phoneNotRegistered)`
  - `signUp(request)`: build session and insert into `_users` keyed by normalized phone
  - Delete email/password methods, `faker` import; document magic numbers in class doc comment
- `lib/data/repositories/supabase_auth_repository.dart`: delete the 4 trimmed methods; change `profile == null` branch in `verifyOtp` to return `NotFoundFailure(code: phoneNotRegistered)` to match the mock's contract

### Phase 3 — Login + OTP UI
- `lib/ui/features/auth/views/widgets/login_form.dart`: delete `_EmailField`, `_PasswordField`, forgot-password link, "سجّل الآن" link. Add `IntlPhoneField` (`initialCountryCode: 'JO'`, styled fill `0xFFE6E9E7` radius 12, `ValueKey('phone_input')`, `onChanged: (p) => viewModel.setPhone(p.completeNumber)`). Button calls `viewModel.requestOtp(viewModel.phone)`. Show passive `loginNewNumberHint` text. Keep supplier portal selector logic
- `lib/ui/features/auth/viewmodels/login_viewmodel.dart`: remove email/password/signIn/passwordReset state + methods; keep `selectedRole`, `supplierType`, `phone`, `requestOtp`, `otpSent`, `error`, `isLoading`
- `lib/ui/features/auth/views/login_view.dart`: drop the `signedIn` and `passwordResetRequested` navigation blocks; `otpSent` block navigates `VerificationView(phoneNumber:, initialRole: viewModel.selectedRole, initialSupplierType: viewModel.supplierType)`
- `lib/ui/features/auth/views/verification_view.dart`: replace plain TextField with `Pinput` (6 cells, `ValueKey('otp_input')`, theme matching app inputs, `GoogleFonts.dmSans` 24pt). On `verified` → `HomeRouter(userName: viewModel.session!.userName, …categories from session)`. On `needsSignup` → `pushReplacement` to `SignUpWizardView(initialRole:, initialSupplierType: ?? SupplierType.individual, initialPhone: phoneNumber)`. All strings via `context.l10n`; show `otpSimulatedHint` caption
- `lib/ui/features/auth/viewmodels/verification_viewmodel.dart`: add `needsSignup` flag set when failure is `NotFoundFailure` with `phoneNotRegistered` code
- **Delete files**: `views/forgot_password_otp_view.dart`, `views/reset_password_view.dart`, `viewmodels/forgot_password_viewmodel.dart`, `viewmodels/login_viewmodel_new.dart` (orphan)

### Phase 4 — Signup wizard
- `controllers/signup_wizard_controller.dart`: add `IAuthRepository? authRepository` + `String initialPhone = ''` ctor params; remove `password`/`passwordConfirm`; `buildRequest()` passes `password: null`; `submit()` uses `authRepository.signUp()` when injected else existing service path; surface failures into an `error` field (currently swallowed)
- `views/signup_wizard_view.dart`: add `initialPhone` param; construct controller with `context.read<IAuthRepository>()`; step-4 title → 'بيانات التواصل'
- `views/signup_wizard/steps/step4_credentials.dart`: delete both password fields; phone read-only + verified check icon when pre-filled; keep optional email as profile field

### Phase 5 — Tests
- Rewrite `test/ui/auth/login_form_widget_test.dart`: fake repo implements trimmed interface; tests — empty phone blocks request; typed `790000001` reaches repo as `+962790000001` with `otpSent` true; failure surfaces error
- New `test/data/repositories/mock_auth_repository_test.dart`: magic numbers → correct roles; wrong code → `invalid_otp`; unknown + correct code → `phone_not_registered`; `signUp` then `verifyOtp` same phone → success
- New `test/ui/auth/verification_viewmodel_test.dart`: incomplete code blocked; success sets session; `phone_not_registered` sets `needsSignup` without error; resend resets
- Must stay green untouched: `test/ui/auth/signup_viewmodel_test.dart`, `test/data/user_signup_request_test.dart`, all order/chat tests

## 7. Acceptance Criteria / Verification

1. `flutter pub get` && `flutter gen-l10n` succeed
2. `flutter analyze` → **0 issues**
3. `flutter test` → **all pass**
4. Manual smoke on emulator (mock repo, no `main.dart` change needed):
   - `+962790000002` + `123456` → individual-supplier home
   - any number + wrong code → inline error, stays on OTP screen
   - new number + `123456` → signup wizard with phone locked in step 4 → submit → home
   - same new number again (after sign-out) → straight to home
5. No email or password field reachable anywhere in the auth flow

## 8. Conventions to Respect

- All user-facing strings through `context.l10n` — new keys in both `.arb` files, Arabic template first
- RTL-first layouts; phone/OTP digits render LTR
- Never edit generated files (`l10n/generated/`, `*.freezed.dart`, `*.g.dart`)
- Match existing input styling (fill `0xFFE6E9E7`, radius 12) and font conventions (Cairo for Arabic, DM Sans for numbers)
- New code returns `AppResult` and uses `.fold()`, never throws across layer boundaries
