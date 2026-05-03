---
type: plan
status: awaiting-approval
date: 2026-04-22
tags: [dwaar, backend, local, otp, auth]
---

# Dwaar — Local Backend Integration Plan

## Goal
Replace Supabase with a fully local, offline-capable backend embedded in the APK.
All auth, OTP, and user data stored via `shared_preferences` (already a dep — no new packages).

---

## 1  Scope — What Changes

### Remove
| File / Symbol | Action |
|---|---|
| `pubspec.yaml` — `supabase_flutter` dep | Delete |
| `pubspec.lock` — supabase entries | Auto-cleaned by `flutter pub get` |
| `lib/core/config/env.dart` | Delete (Supabase-only) |
| `lib/core/services/supabase_client.dart` | Delete |
| `lib/data/services/user_signup_service.dart` | Replace with local impl |
| `lib/data/services/auth_service.dart` | Replace MockAuthService body |
| `lib/main.dart` — Supabase init block | Remove |
| `lib/ui/features/auth/viewmodels/verification_viewmodel.dart` | Remove Supabase path |
| Supabase integration tests | Delete |

### Add — new folder `lib/backend_integration_locally/`
```
lib/
  backend_integration_locally/
    local_auth_service.dart         // OTP gen + verify + user CRUD
    local_store.dart                // SharedPreferences thin wrapper
    local_notification_service.dart // in-app OTP-sent overlay
    models/
      local_user.dart               // plain Dart user model
      otp_record.dart               // OTP + expiry + retry state
```

---

## 2  Data Schema (SharedPreferences)

| Key | Type | Contents |
|---|---|---|
| `dwaar_users` | `String` (JSON list) | `[{id, name, phone, email?, role, supplierType?, vehiclePlate?, createdAt}]` |
| `dwaar_otp_<phone_or_email>` | `String` (JSON) | `{code, expiresAt, attempts, maxAttempts}` |
| `dwaar_current_user_id` | `String` | ID of logged-in user (null = logged out) |

---

## 3  OTP Rules

| Parameter | Value |
|---|---|
| Length | 6 digits |
| Expiry | 120 seconds (matches existing UI timer) |
| Max attempts | 3 |
| Max resends | 5 per session |
| Generation | `dart:math` SecureRandom — no external dep |
| Display | In-app banner (no real SMS for MVP) |

---

## 4  Feature Spec

### 4.1 Login flow
1. User enters phone/email + selects role -> taps Send OTP
2. `LocalAuthService.sendOtp(identifier)` generates 6-digit code, stores in SharedPreferences with 120s expiry
3. `LocalNotificationService.show(context, otp)` shows in-app banner: "رمز التحقق: 123456"
4. User navigates to VerificationView (UI unchanged)
5. On submit -> `LocalAuthService.verifyOtp(identifier, code)` checks code + expiry + attempt count
6. Success -> load user from store -> navigate to HomeRouter
7. No user found -> route to signup

### 4.2 Signup flow
1. Same as login steps 1-4 but carries SignUpRequest payload
2. On OTP success -> `LocalAuthService.createUser(request)` writes new LocalUser to SharedPreferences
3. Auto-login (set `dwaar_current_user_id`)
4. Navigate to HomeRouter

### 4.3 OTP error handling
| Condition | UI message (Arabic) |
|---|---|
| Wrong code | "الرمز غير صحيح" + attempt counter |
| Expired | "انتهت صلاحية الرمز، اضغط إعادة الإرسال" |
| Max attempts | "تجاوزت الحد المسموح، اضغط إعادة الإرسال" |
| Resend | Clears old OTP, generates new, shows banner again |

### 4.4 In-app notification (OTP banner)
- Global overlay using `OverlayEntry` injected from `LocalNotificationService`
- Shown for 8 seconds, dismissible by tap
- RTL, uses `AppColors.primaryGreen` background
- Banner text: "رمز التحقق: [OTP]"
- For future real SMS: swap `show` to a no-op and delete the code from display

---

## 5  File-by-File Implementation Notes

### `lib/backend_integration_locally/local_store.dart`
- Thin wrapper around `SharedPreferences`
- Methods: `readUsers()` / `writeUsers()` / `readOtp(key)` / `writeOtp(key, record)` / `clearOtp(key)`
- Initialized once at app start; injected via constructor

### `lib/backend_integration_locally/local_auth_service.dart`
- No Supabase, no network
- Public API:
  - `Future<void> sendOtp(String identifier)`
  - `Future<LocalUser?> verifyOtp(String identifier, String code, {SignUpRequest? pendingRequest})`
  - `Future<LocalUser?> getCurrentUser()`
  - `Future<void> logout()`

### `lib/backend_integration_locally/local_notification_service.dart`
- Static `show(BuildContext context, String message)`
- Uses `OverlayEntry` — no package needed
- Auto-dismisses after 8 seconds

### `lib/data/services/user_signup_service.dart` (replaced)
- Keeps `SignUpRequest` + `SignUpException` structs (no Supabase imports)
- Thin delegate to `LocalAuthService`

### `lib/ui/features/auth/viewmodels/verification_viewmodel.dart`
- Remove `SupabaseService` import
- `_service` becomes `LocalAuthService` (non-nullable)
- All verify/resend logic calls `LocalAuthService`

### `lib/main.dart`
- Remove Supabase init block and imports
- Initialize `LocalStore` -> inject into `LocalAuthService`
- Provide `LocalAuthService` at root via `Provider`

---

## 6  Dependencies Delta

| Package | Before | After |
|---|---|---|
| `supabase_flutter` | required | **REMOVED** |
| `shared_preferences` | already present | kept |
| `dart:math` | stdlib | used for OTP generation |
| `dart:convert` | stdlib | used for JSON serialization |

**No new packages needed.**

---

## 7  Future Roadmap

| # | Feature | Notes |
|---|---|---|
| F-01 | Real SMS OTP via Twilio/Firebase | Swap `LocalAuthService.sendOtp` only — UI unchanged |
| F-02 | Cloud sync (REST/Supabase) | `LocalStore` becomes adapter; add `RemoteStore` |
| F-03 | Push notifications (FCM) | `LocalNotificationService.show` becomes thin wrapper |
| F-04 | Biometric auth | Add `local_auth` package; gate `getCurrentUser` |
| F-05 | Role management / admin panel | Extend `LocalUser` model + add RBAC layer |
| F-06 | Order persistence (offline-first) | Extend `LocalStore` schema for orders |

---

## 8  AI Prompts for Future Features

### Prompt A — Real SMS OTP
```
You are implementing SMS OTP for Dwaar (Flutter/Dart).
Context:
- LocalAuthService.sendOtp(identifier) currently generates an OTP locally and shows it in-app.
- Replace the local generation with a call to [FILL: Twilio / Firebase Auth / custom REST endpoint].
- Keep the same public interface: Future<void> sendOtp(String identifier).
- On success: store only the expiry + attempt count locally (not the code itself).
- On failure: throw SignUpException with Arabic user-facing message.
- Do NOT change VerificationViewModel or any UI layer.
```

### Prompt B — Cloud Sync
```
You are adding cloud sync to Dwaar local user store.
Context:
- LocalStore (lib/backend_integration_locally/local_store.dart) is the single source of truth.
- Add a RemoteStore interface with read/write/delete methods.
- On write: save locally first, then sync to remote asynchronously (fire-and-forget with retry queue).
- On read: return local copy immediately; refresh from remote in background.
- Use [FILL: Supabase / Firebase Firestore / custom REST] as the remote.
- Conflict resolution: last-write-wins on updatedAt timestamp.
```

### Prompt C — Biometric Auth
```
You are adding biometric unlock to Dwaar.
Context:
- After first OTP login, offer to enable Face ID / fingerprint.
- Use the `local_auth` Flutter package.
- Gate getCurrentUser() in LocalAuthService behind biometric prompt when enabled.
- Store biometric preference in SharedPreferences key `dwaar_biometric_enabled`.
- Do NOT change the OTP flow or any signup logic.
```

### Prompt D — Offline-first Orders
```
You are extending Dwaar LocalStore to persist orders offline.
Context:
- Current AppOrderStore (lib/data/services/app_order_store.dart) holds orders in memory only.
- Add SharedPreferences persistence using key `dwaar_orders`.
- Keep AppOrderStore as the ChangeNotifier; wire it to LocalStore for read/write.
- On app launch: hydrate AppOrderStore from SharedPreferences.
- On every order mutation: persist to SharedPreferences immediately.
- Do NOT add a network layer — that is a separate task (use Prompt B for that).
```

---

## 9  Execution Checklist

- [ ] Write `lib/backend_integration_locally/models/local_user.dart`
- [ ] Write `lib/backend_integration_locally/models/otp_record.dart`
- [ ] Write `lib/backend_integration_locally/local_store.dart`
- [ ] Write `lib/backend_integration_locally/local_auth_service.dart`
- [ ] Write `lib/backend_integration_locally/local_notification_service.dart`
- [ ] Update `lib/data/services/user_signup_service.dart` (remove Supabase)
- [ ] Update `lib/data/services/auth_service.dart` (wire LocalAuthService)
- [ ] Update `lib/ui/features/auth/viewmodels/verification_viewmodel.dart`
- [ ] Update `lib/ui/features/auth/viewmodels/login_viewmodel.dart`
- [ ] Update `lib/main.dart` (remove Supabase init, add LocalStore init)
- [ ] Delete `lib/core/services/supabase_client.dart`
- [ ] Delete `lib/core/config/env.dart`
- [ ] Remove `supabase_flutter` from `pubspec.yaml`
- [ ] Delete Supabase integration tests
- [ ] Run `flutter analyze` — zero errors
- [ ] Run `flutter test` — all pass
