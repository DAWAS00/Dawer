# Dwaar — Supabase Removal Plan

> Step-by-step guide to purge every Supabase reference and replace with the
> local backend (`lib/backend_integration_locally/`).

---

## Phase 0 — Pre-flight (read-only, no changes)

- [ ] Run `flutter analyze` — note any pre-existing errors to separate from migration errors.
- [ ] Run `flutter test` — baseline pass/fail count.
- [ ] Commit or stash any WIP changes so the removal is a clean diff.

---

## Phase 1 — Remove the package

**File:** `pubspec.yaml`

Remove this line:
```yaml
  supabase_flutter: ^2.8.0
```

Also remove from `dev_dependencies` (if present):
```yaml
  http: ^1.2.0   # only used by supabase_connect_test — can remove
```

Then run:
```bash
flutter pub get
```

> The `pubspec.lock` cleans itself. Do not edit it manually.

---

## Phase 2 — Delete Supabase-only files

These files have no purpose without Supabase and should be deleted entirely:

| File | Reason |
|---|---|
| `lib/core/config/env.dart` | Only holds SUPABASE_URL / SUPABASE_ANON_KEY |
| `lib/core/services/supabase_client.dart` | SupabaseService singleton — entirely Supabase |
| `test/integration/supabase_connect_test.dart` | Hits live Supabase REST endpoint |

```bash
# Run from repo root
rm lib/core/config/env.dart
rm lib/core/services/supabase_client.dart
rm test/integration/supabase_connect_test.dart
```

---

## Phase 3 — Rewrite Supabase-dependent files

### 3a. `lib/data/services/auth_service.dart`
- Remove `MockAuthService` body.
- Make `IAuthService` delegate to `LocalAuthService`.
- Remove all mock delays (LocalAuthService handles its own timing).

### 3b. `lib/data/services/user_signup_service.dart`
- Delete the entire `UserSignUpService` class (Supabase OTP/signUp/verifyOTP calls).
- **Keep:** `SignUpRequest`, `SignUpException`, `ValidationErrors` — these are pure
  Dart validation structs with no Supabase imports.
- Remove: `import 'package:supabase_flutter/...'` and
  `import '../../core/services/supabase_client.dart'`.
- Add a thin re-export of `LocalAuthService` OTP methods for backward compat.

### 3c. `lib/data/services/reward_service.dart`
- Remove Supabase Edge Function call.
- Replace with a local calculation using the same formula as
  `supabase/functions/calculate_reward/index.ts` (copy the math into Dart).
- File becomes self-contained: no network, no Supabase import.
- Class `RewardService` keeps the same public `calculate(...)` signature.

### 3d. `lib/data/models/reward_breakdown.dart`
- Remove doc-comment references to `supabase/functions/...`.
- No code change needed — the class is already pure Dart.

### 3e. `lib/data/models/user_role.dart`
- Remove doc-comment references to `supabase/migrations/...`.
- Remove `dbValue` / `fromDb` / `allowedDbValues` extensions IF no longer needed.
  (Keep them if `LocalUser` serialization reuses the string labels — which it should.)

### 3f. `lib/ui/features/auth/viewmodels/signup_viewmodel.dart`
- Remove: `import '../../../../core/services/supabase_client.dart'`
- Remove: `import '../../../../data/services/user_signup_service.dart'` (Supabase methods)
- Replace: `_service` field (`UserSignUpService?`) → `LocalAuthService` (non-nullable)
- Replace: `submit()` live path with `LocalAuthService.sendOtp(email)` call
- Remove: `SupabaseService.isInitialized` guard

### 3g. `lib/ui/features/auth/viewmodels/verification_viewmodel.dart`
- Remove: `import '../../../../core/services/supabase_client.dart'`
- Remove: `import '../../../../data/services/user_signup_service.dart'`
- Remove: `_service` nullable field + live Supabase path in `verify()`
- Replace: inject `LocalAuthService`; `verify()` always calls
  `LocalAuthService.verifyOtp(destination, _digits.join(), pendingRequest: pendingRequest)`
- Remove: mock fallback delay block

### 3h. `lib/main.dart`
- Remove imports:
  ```dart
  import 'core/config/env.dart';
  import 'core/services/supabase_client.dart';
  ```
- Remove entire block:
  ```dart
  if (Env.isConfigured) { ... } else { debugPrint('Supabase credentials...'); }
  ```
- Add after `WidgetsFlutterBinding.ensureInitialized()`:
  ```dart
  final localStore = await LocalStore.init();
  final localAuth  = LocalAuthService(store: localStore);
  ```
- Add to `MultiProvider`:
  ```dart
  Provider<LocalStore>.value(value: localStore),
  Provider<LocalAuthService>.value(value: localAuth),
  ```

---

## Phase 4 — Verify

```bash
flutter analyze          # must show zero errors
flutter test             # all non-integration tests must pass
flutter build apk --debug  # APK must compile
```

---

## Phase 5 — Cleanup

- [ ] Delete the `supabase/` folder at repo root (migrations, functions, config).
- [ ] Delete `.env.example` and `.env.local.example` if present.
- [ ] Remove any `--dart-define-from-file=.env.local` references from
      `.vscode/launch.json` or CI scripts.
- [ ] Update `CLAUDE.md` to remove Supabase mentions from the Data Layer section.

---

## Conflict notes

| Conflict | Resolution |
|---|---|
| `reward_service.dart` calls a Supabase Edge Function for pricing | Inline the calculation as a local Dart function using the same formula from `supabase/functions/calculate_reward/index.ts`. Flag in code that this must stay in sync until Prompt B cloud sync is implemented. |
| `user_role.dart` extensions use `.dbValue` string labels | Keep the extensions — `LocalUser` serialization reuses the same string labels so the JSON stored in SharedPreferences matches the future cloud schema. |
| `SignUpRequest` / `SignUpException` structs live inside `user_signup_service.dart` | Move them to `lib/data/models/signup_request.dart` before deleting the service file so no import breaks. |
