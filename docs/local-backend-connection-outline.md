# Dwaar — Local Backend Connection Outline

> How the Obsidian prompts (docs/obsidian-prompts-future-features.md) map to
> the local backend implementation and how each future prompt slots in without
> touching the UI layer.

---

## Architecture overview

```
┌─────────────────────────────────────────────┐
│  UI Layer (Views + ViewModels)               │
│  — never imports LocalStore directly         │
│  — reads/writes only through LocalAuthService│
└────────────────┬────────────────────────────┘
                 │  constructor injection via Provider
┌────────────────▼────────────────────────────┐
│  lib/backend_integration_locally/            │
│                                              │
│  LocalAuthService   ◄── sendOtp / verifyOtp  │
│       │                  getCurrentUser      │
│       │                  logout              │
│       ▼                                      │
│  LocalStore         ◄── SharedPreferences    │
│       │               readUsers/writeUsers   │
│       │               readOtp/writeOtp       │
│       ▼                                      │
│  LocalNotificationService                    │
│       └── OverlayEntry OTP banner (MVP)      │
└─────────────────────────────────────────────┘
```

---

## How each prompt slots into this architecture

### Prompt A — Real SMS OTP
**Slot:** `LocalAuthService.sendOtp()`  
**Change:** Replace the local `dart:math` OTP generation + banner call with an
HTTP call to the SMS provider. Everything above (ViewModels, Views) and below
(LocalStore) is untouched.

```
LocalAuthService.sendOtp(identifier)
  BEFORE: generate code -> store code in SharedPreferences -> show banner
  AFTER:  POST to SMS provider -> store only expiry in SharedPreferences -> no banner
```

---

### Prompt B — Cloud Sync
**Slot:** New `IRemoteStore` / `RemoteStore` alongside `LocalStore`  
**Change:** `LocalStore` gains an optional `IRemoteStore` collaborator.
Writes go local-first; remote sync is async. `LocalAuthService` is unchanged —
it still calls `LocalStore` as before.

```
LocalStore.writeUsers(users)
  BEFORE: SharedPreferences.setString('dwaar_users', json)
  AFTER:  SharedPreferences.setString(...) -> fire-and-forget RemoteStore.pushUser(...)
```

---

### Prompt C — Biometric Auth
**Slot:** `LocalAuthService.getCurrentUser()`  
**Change:** Gate the return behind `BiometricService.authenticate()` when
`dwaar_biometric_enabled == true`. No other method changes.

```
LocalAuthService.getCurrentUser()
  BEFORE: read dwaar_current_user_id -> return user
  AFTER:  if biometric enabled -> authenticate() -> if fail return null
          else read dwaar_current_user_id -> return user
```

---

### Prompt D — Offline Orders
**Slot:** `AppOrderStore` + new `LocalStore` methods  
**Change:** `AppOrderStore` gains a `LocalStore` reference and calls
`readOrders()` on init, `writeOrders()` on every mutation.
No change to `LocalAuthService` or any View.

---

### Prompt E — RBAC
**Slot:** New `Permissions` class + `PermissionGuard` widget  
**Change:** Pure additions — no existing file changes except replacing
role `if/switch` guards in Tab widgets with `PermissionGuard`.

---

## Provider wiring (how main.dart exposes the backend)

```dart
// main.dart (after local backend init)
MultiProvider(
  providers: [
    Provider<LocalStore>.value(value: localStore),
    Provider<LocalAuthService>.value(value: localAuth),
    // Future prompts add here:
    // Provider<BiometricService>.value(value: biometricService),
    // Provider<IRemoteStore>.value(value: remoteStore),
    ChangeNotifierProvider(create: (_) => AppOrderStore(store: localStore)),
    ChangeNotifierProvider(create: (_) => AppOrderStore()),
    ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
    ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),
  ],
  ...
)
```

---

## File ownership table

| File | Owns | Consumed by |
|---|---|---|
| `local_store.dart` | SharedPreferences read/write | LocalAuthService, AppOrderStore (Prompt D) |
| `local_auth_service.dart` | OTP logic, user CRUD, session | LoginViewModel, SignUpViewModel, VerificationViewModel |
| `local_notification_service.dart` | In-app OTP banner | LocalAuthService.sendOtp (MVP only) |
| `biometric_service.dart` (Prompt C) | Biometric pref + auth | LocalAuthService.getCurrentUser |
| `remote_store.dart` (Prompt B) | Cloud sync | LocalStore (optional collaborator) |
| `permissions.dart` (Prompt E) | Role->permission map | PermissionGuard widget |

---

## Obsidian vault file map

```
Projects/Dawer/
  local-backend-integration-plan.md   ← full plan (approved)
  supabase-removal-plan.md            ← phase-by-phase removal steps
  local-backend-connection-outline.md ← this file
  prompts/
    future-features.md                ← Prompts A-E (verbatim, reusable)
```
