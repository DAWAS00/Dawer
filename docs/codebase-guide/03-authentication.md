# 3. Authentication

## Overview

The app has two authentication backends that exist side-by-side:

1. **`MockAuthRepository`** — fake auth with magic phone numbers, currently wired in `main.dart`.
2. **`SupabaseAuthRepository`** — real Supabase phone-OTP auth, implemented but **not** the default.

There is also a **strategy mismatch**: `SupabaseAuthRepository` is written for phone OTP, while `SupabaseAuthService` (used for signup) uses email/password.

## Current runtime path: MockAuthRepository

In `lib/main.dart` the auth repository is bound to the mock implementation:

```dart
Provider<IAuthRepository>(
  create: (_) => MockAuthRepository(),
)
```

### Magic phone numbers

```dart
// lib/data/repositories/mock_auth_repository.dart
final Map<String, AuthSession> _users = {
  '+962790000001': const AuthSession(
    userId: 'm-driver-123',
    userName: 'أحمد السائق (تجريبي)',
    role: UserRole.driver,
  ),
  '+962790000002': const AuthSession(
    userId: 'm-supp-456',
    userName: 'خالد المورد (فردي)',
    role: UserRole.supplier,
    supplierType: SupplierType.individual,
  ),
  '+962790000003': const AuthSession(
    userId: 'm-store-789',
    userName: 'مطعم أبو علي (تجاري)',
    role: UserRole.supplier,
    supplierType: SupplierType.storeBusiness,
  ),
  '+962790000004': const AuthSession(
    userId: 'm-recy-000',
    userName: 'شركة تدويركم (تجريبي)',
    role: UserRole.recyclingCo,
  ),
};
```

### OTP validation disabled

```dart
@override
Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async {
  await Future.delayed(const Duration(seconds: 1));
  // [DEV] Validation temporarily disabled
  // if (otp != simulatedOtp) { ... }
  ...
}
```

The `simulatedOtp` is `'123456'`, but any OTP is accepted in the current build.

### Role override

`MockAuthRepository` respects the role selected on the login screen, not the stored role. This prevents test users from being locked into one role:

```dart
final session = AuthSession(
  userId: existingSession?.userId ?? 'auto-${normalizedPhone.hashCode.abs()}',
  userName: existingSession?.userName ?? 'مستخدم تجريبي',
  role: _targetRole,
  supplierType: _targetSupplierType,
);
```

### Why mock is the default

- Faster iteration without Supabase OTP delays.
- No real Firebase project required.
- Demo/pitch friendly.
- **Not safe for production.**

## Supabase auth implementation

### SupabaseAuthRepository

`lib/data/repositories/supabase_auth_repository.dart` implements `IAuthRepository` using Supabase Auth phone OTP:

```dart
@override
Future<AppResult<void>> requestOtp(String phone) async {
  try {
    await _client.auth.signInWithOtp(phone: phone);
    return const Success(null);
  } on AuthException catch (e) {
    return Failure(AuthFailure(message: e.message));
  }
}

@override
Future<AppResult<AuthSession>> verifyOtp(String phone, String otp) async {
  final response = await _client.auth.verifyOTP(
    phone: phone,
    token: otp,
    type: OtpType.sms,
  );
  ...
}
```

It fetches the matching `public.users` profile after verification and maps it to `AuthSession`, caching role/category in `LocalStore`.

### SupabaseAuthService

`lib/data/services/supabase_auth_service.dart` handles **email/password** sign-up and sign-in, plus profile creation and file uploads. It is used during the signup wizard.

```dart
final authResponse = await _client.auth.signUp(email: email, password: pw);
```

It inserts a row into `public.users`:

```dart
final profileRow = <String, dynamic>{
  'auth_id': authUser.id,
  'name': request.name.trim(),
  'phone': request.phone.trim(),
  'email': email,
  'role': request.role.dbValue,
  if (request.supplierType != null) 'supplier_type': request.supplierType!.dbValue,
  if (request.vehiclePlate != null) 'vehicle_plate': request.vehiclePlate!.trim(),
  ...
};
```

After profile insertion it optionally uploads profile photo and identity document to Supabase Storage.

### Strategy mismatch

| Component | Auth method |
|---|---|
| `SupabaseAuthRepository` | Phone OTP (`signInWithOtp`, `verifyOTP`) |
| `SupabaseAuthService` | Email/password (`signUp`, `signInWithPassword`) |

This means a user created via the email/password signup wizard cannot sign in through the phone-OTP login screen unless the phone is linked to the email account and the `get_email_by_phone` RPC works. The `PHONE_AUTH_PLAN.md` proposes moving to phone-only simulated OTP, but it has not fully replaced the email/password path.

## Login flow

1. `SplashView` checks `IAuthRepository.currentSession`.
2. If no session → `LoginView`.
3. User selects role (and supplier sub-type if applicable) and enters phone.
4. `LoginViewModel.requestOtp()` calls `IAuthRepository.requestOtp(phone)`.
5. User enters OTP in `VerificationView`.
6. `VerificationViewModel.verify()` calls `IAuthRepository.verifyOtp(phone, otp)`.
7. On success → `HomeRouter(role, supplierType, userName)`.

## Signup flow

The signup flow is multi-step and role-specific:

1. `UnifiedSignupView` / `SignupWizardView` collects base info.
2. Role-specific onboarding screens:
   - `IndividualSupplierOnboardingView`
   - `StoreOnboardingView`
   - `RecyclingCoOnboardingView`
   - `RestaurantSignupView`
3. AI-powered scans:
   - Vehicle registration scan for drivers (`GeminiVehicleRegistrationService`).
   - License/identity validation.
   - Waste photo classification.
4. `UserSignUpService` (a global singleton) delegates to `SupabaseAuthService.signUp()`.

```dart
// lib/main.dart
UserSignUpService.setGlobalAuthService(
  SupabaseAuthService(store: localStore, fileStorage: fileStorage),
);
```

## Auth session model

```dart
// lib/domain/repositories/i_auth_repository.dart (conceptual)
class AuthSession {
  final String userId;
  final String userName;
  final UserRole role;
  final SupplierType? supplierType;
  final List<String> categories;
  ...
}
```

The session is cached in `LocalStore` so `currentSession` can return quickly on app restart.

## Local backend plans

Several documents (`docs/local-backend-integration-plan.md`, `docs/supabase-removal-plan.md`) describe a local-only backend using `SharedPreferences` for users and OTP. Implementation is partial:

- ✅ `LocalStore` exists.
- ❌ `local_auth_service.dart`, `local_user.dart`, `otp_record.dart`, `local_notification_service.dart` are missing.

The current branch is **Supabase-first**, so the local-backend track appears superseded but not explicitly cancelled.

## Files referenced

- `lib/main.dart` — provider binding
- `lib/data/repositories/mock_auth_repository.dart` — mock auth
- `lib/data/repositories/supabase_auth_repository.dart` — Supabase OTP auth
- `lib/data/services/supabase_auth_service.dart` — Supabase email/password signup
- `lib/data/services/user_signup_service.dart` — global signup delegate
- `lib/ui/features/auth/viewmodels/login_viewmodel.dart`
- `lib/ui/features/auth/viewmodels/verification_viewmodel.dart`
- `PHONE_AUTH_PLAN.md`
- `docs/local-backend-integration-plan.md`
- `docs/supabase-removal-plan.md`
