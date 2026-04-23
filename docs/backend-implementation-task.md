# Backend Implementation Task — Dwaar Local Backend

## Status
- [x] Supabase removed from main.dart
- [x] auth_service.dart — LocalAuthService stub written
- [x] user_signup_service.dart — local OTP logic written (in-memory, no SharedPreferences yet)
- [x] verification_viewmodel.dart — wired to UserSignUpService local path
- [x] signup_viewmodel.dart — wired to UserSignUpService
- [x] reward_service.dart — local calculation (no Edge Function)
- [ ] lib/backend_integration_locally/ folder — DOES NOT EXIST YET
- [ ] SharedPreferences persistence (users + OTP survive app restart)
- [ ] In-app OTP notification banner
- [ ] supabase_flutter removed from pubspec.yaml
- [ ] supabase_client.dart + env.dart deleted
- [ ] flutter analyze passes clean

---

## What needs to be built

### Folder: `lib/backend_integration_locally/`

```
lib/backend_integration_locally/
  models/
    local_user.dart         // serializable user model for SharedPreferences
    otp_record.dart         // OTP + expiry + attempt count
  local_store.dart          // SharedPreferences read/write wrapper
  local_auth_service.dart   // OTP gen, verify, user CRUD — replaces inline logic in auth_service.dart
  local_notification_service.dart  // OverlayEntry OTP banner
```

### local_user.dart
Fields: `id` (uuid), `name`, `phone`, `email?`, `role` (string), `supplierType?`, `vehiclePlate?`, `vehicleModel?`, `vehicleColor?`, `createdAt` (ISO string).
Methods: `toJson()`, `LocalUser.fromJson()`.

### otp_record.dart
Fields: `code` (6-digit string), `expiresAt` (ISO string), `attempts` (int), `maxAttempts` (int = 3).
Methods: `toJson()`, `OtpRecord.fromJson()`, `bool get isExpired`, `bool get isExhausted`.

### local_store.dart
Thin wrapper around `SharedPreferences`. Keys:
- `dwaar_users` → JSON-encoded `List<Map>`
- `dwaar_otp_<identifier>` → JSON-encoded `OtpRecord`
- `dwaar_current_user_id` → String

Methods: `init()` (static async factory), `readUsers()`, `writeUsers()`, `readOtp(key)`, `writeOtp(key, record)`, `clearOtp(key)`, `getCurrentUserId()`, `setCurrentUserId(id)`, `clearCurrentUserId()`.

### local_auth_service.dart
Replaces the inline `LocalAuthService` in `auth_service.dart` and the in-memory maps in `user_signup_service.dart`.

Methods:
- `sendOtp(String identifier)` — generate 6-digit code, persist OtpRecord, show notification banner
- `verifyOtp(String identifier, String code, {SignUpRequest? pendingRequest})` → `Map<String, dynamic>?` — checks expiry + attempts, creates user if pendingRequest non-null
- `getCurrentUser()` → `Map<String, dynamic>?`
- `logout()`

### local_notification_service.dart
Static `show(BuildContext context, String message)`.
Uses `OverlayEntry`. Auto-dismisses after 8 seconds. Dismissible by tap. RTL layout. Green background using `AppColors.primaryGreen`.

---

## Wiring changes after folder is created

| File | Change needed |
|---|---|
| `lib/data/services/auth_service.dart` | Remove inline `LocalAuthService` body; import from `backend_integration_locally/local_auth_service.dart` |
| `lib/data/services/user_signup_service.dart` | Remove `_defaultOtp`, `_otpByDestination`, `_profilesByDestination` in-memory maps; delegate to `LocalAuthService` from the new folder |
| `lib/main.dart` | Init `LocalStore` + `LocalAuthService`; provide via `Provider` at root |

---

## Acceptance criteria
1. `flutter analyze` — zero errors
2. `flutter test` — all existing tests pass
3. OTP survives app restart (stored in SharedPreferences)
4. User profile survives app restart
5. In-app banner shows OTP code for 8 seconds
6. Wrong OTP shows Arabic error; 3rd wrong attempt locks until resend
7. APK builds: `flutter build apk --debug`
