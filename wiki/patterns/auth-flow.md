---
name: auth-flow
description: Full auth flow — splash → login → OTP verification → HomeRouter; signup wizard; mock vs real Supabase paths
metadata:
  type: pattern
---

# Auth Flow

## Navigation Chain

```
SplashView → LoginView → VerificationView → HomeRouter(role, supplierType, userName)
                       ↘ SignupWizardView (new users)
```

All navigation is imperative `Navigator.push` / `Navigator.pushReplacement`.

## Login Screen

`lib/ui/features/auth/views/login_view.dart`

- Phone number input (intl_phone_field)
- Role selector grid (Driver / Supplier / Recycling Co)
- Supplier sub-type selector (individual / storeBusiness)
- Calls `LoginViewModel.requestOtp()` → `IAuthRepository.requestOtp()`

## OTP Verification

`lib/ui/features/auth/views/verification_view.dart`

- 6-digit OTP (Pinput widget)
- Calls `VerificationViewModel.verifyOtp()` → `IAuthRepository.verifyOtp()`
- On success: navigates to `HomeRouter` with role + userName from `AuthSession`

## Signup Wizard (4 Steps)

`lib/ui/features/auth/views/signup_wizard_view.dart`

Controller: `SignupWizardController`

| Step | File | Purpose |
|---|---|---|
| 1 | `step1_identity.dart` | Name, phone, role selection |
| 2 | `step2_ai_scan.dart` | AI photo scan of ID / vehicle doc |
| 3 | `step3_role_details.dart` | Role-specific details (vehicle, supplier type) |
| 4 | `step4_credentials.dart` | Password + review + submit |

FX widgets: `AiPhotoPicker`, `LaserScanner`, `DataPulse`, `ExtractedDataCard`

## IAuthRepository Implementations

### MockAuthRepository (currently wired)
- 4 hardcoded test accounts
- Any OTP accepted (validation disabled with `[DEV]` comment)
- Role is always overridden by UI selection (not by the stored mock account)

### SupabaseAuthRepository (written, NOT wired)
- Real Supabase OTP via `auth.signInWithOtp(phone:)`
- Fetches user profile from `profiles` table after OTP verify
- Caches role/supplierType/categories to `LocalStore`
- `watchAuthState()` stream maps Supabase auth events → `AuthSession`

## How to Swap to Real Auth

In `main.dart` `MultiProvider`:
```dart
// Replace:
Provider<IAuthRepository>(create: (_) => MockAuthRepository())

// With:
Provider<IAuthRepository>(
  create: (ctx) => SupabaseAuthRepository(
    Supabase.instance.client,
    UserSignUpService(authService: SupabaseAuthService(
      store: ctx.read<LocalStore>(),
      fileStorage: ctx.read<IFileStorageRepository>(),
    )),
    ctx.read<LocalStore>(),
  ),
)
```

Also re-enable OTP check in `mock_auth_repository.dart:88` (remove the comment block).

## Supabase Auth Method

Password-based (not phone OTP in Supabase). `SupabaseAuthService.signIn` uses `auth.signInWithPassword(email:, password:)` where identifier can be phone or email. Supabase OTP (SMS) is used only for existing-user login via `SupabaseAuthRepository.requestOtp()`.

## Related Pages

- [[concepts/user-roles]]
- [[concepts/app-architecture]]
- [[patterns/mock-to-real-swap]]
