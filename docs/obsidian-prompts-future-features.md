# Dwaar — AI Prompts for Future Features

> Vault path: `Projects/Dawer/prompts/future-features.md`  
> Use these verbatim when opening a new Claude Code session for each feature.

---

## Prompt A — Real SMS OTP

```
You are implementing real SMS OTP delivery for Dwaar (Flutter/Dart).

Project context:
- Repo: C:/Users/dawas/dwaar
- Local backend lives in lib/backend_integration_locally/
- LocalAuthService.sendOtp(String identifier) currently generates a 6-digit OTP
  locally and displays it in an in-app banner (MVP behaviour).
- Target: replace the local generation + banner with a real SMS call.

Task:
1. Replace the body of LocalAuthService.sendOtp with a call to
   [FILL: Twilio Verify / Firebase Auth / custom REST at FILL:URL].
2. On success: store only the expiry timestamp + attempt count in SharedPreferences
   (key: dwaar_otp_<identifier>) — do NOT store the code itself.
3. On any error: throw SignUpException with an Arabic user-facing message.
4. Remove LocalNotificationService.show() calls from sendOtp.
5. Keep the public method signature identical: Future<void> sendOtp(String identifier).
6. Do NOT change VerificationViewModel, VerificationView, or any other UI file.
7. Do NOT add new Flutter packages without asking.

Acceptance: flutter analyze passes with zero errors.
```

---

## Prompt B — Cloud Sync (Remote User Store)

```
You are adding optional cloud sync to Dwaar's local user store (Flutter/Dart).

Project context:
- Repo: C:/Users/dawas/dwaar
- LocalStore (lib/backend_integration_locally/local_store.dart) owns all
  SharedPreferences read/write logic.
- LocalAuthService (lib/backend_integration_locally/local_auth_service.dart)
  is the only caller of LocalStore.

Task:
1. Define an abstract interface IRemoteStore in
   lib/backend_integration_locally/remote_store.dart with methods:
     Future<List<Map<String, dynamic>>> fetchUsers();
     Future<void> pushUser(Map<String, dynamic> user);
     Future<void> deleteUser(String id);
2. Implement the interface targeting [FILL: Supabase / Firebase Firestore / REST at FILL:URL].
3. Wrap LocalStore so writes go local-first, then call pushUser asynchronously
   (fire-and-forget; add to a retry queue on failure using SharedPreferences
   key dwaar_sync_queue).
4. Reads return local data immediately; trigger a background fetchUsers refresh.
5. Conflict resolution: last-write-wins on the user's updatedAt field.
6. All new code must be in lib/backend_integration_locally/.
7. Do NOT change any ViewModel, View, or model file.

Acceptance: flutter analyze passes; LocalStore unit tests still pass.
```

---

## Prompt C — Biometric Authentication

```
You are adding biometric unlock to Dwaar (Flutter/Dart).

Project context:
- Repo: C:/Users/dawas/dwaar
- LocalAuthService.getCurrentUser() returns the logged-in user from SharedPreferences.
- SharedPreferences key dwaar_current_user_id holds the active session.

Task:
1. Add the `local_auth` package to pubspec.yaml.
2. Add a BiometricService class in
   lib/backend_integration_locally/biometric_service.dart:
     Future<bool> isAvailable()
     Future<bool> authenticate()
     Future<void> setEnabled(bool value)
     Future<bool> isEnabled()
   Store preference under SharedPreferences key dwaar_biometric_enabled.
3. In LocalAuthService.getCurrentUser(): if biometric is enabled, call
   BiometricService.authenticate() and return null on failure.
4. After first successful OTP login, call BiometricService.isAvailable(); if
   true, show a one-time prompt offering to enable biometric — surface this
   via a ChangeNotifier event, not directly from the service.
5. Do NOT change OTP generation, VerificationViewModel, or signup logic.

Acceptance: flutter analyze passes; app runs without biometric hardware
(graceful fallback: isAvailable returns false, feature silently disabled).
```

---

## Prompt D — Offline-first Order Persistence

```
You are adding offline-first persistence to Dwaar's order store (Flutter/Dart).

Project context:
- Repo: C:/Users/dawas/dwaar
- AppOrderStore (lib/data/services/app_order_store.dart) is a ChangeNotifier
  that currently holds orders in memory only — data is lost on app restart.
- LocalStore (lib/backend_integration_locally/local_store.dart) owns all
  SharedPreferences access.

Task:
1. Add two methods to LocalStore:
     Future<List<Map<String, dynamic>>> readOrders()
     Future<void> writeOrders(List<Map<String, dynamic>> orders)
   Use SharedPreferences key dwaar_orders; value is a JSON-encoded list.
2. In AppOrderStore:
   a. Inject LocalStore via constructor (keep a no-arg convenience constructor
      that reads it from the Provider tree using a static accessor).
   b. On init: call LocalStore.readOrders() and populate the in-memory list.
   c. After every mutation (add, update, remove): call LocalStore.writeOrders().
3. Add Order.toJson() / Order.fromJson() if they do not already exist.
4. Do NOT add a network layer — that is covered by Prompt B.
5. Do NOT change any View or ViewModel other than AppOrderStore.

Acceptance: flutter analyze passes; orders survive a hot restart.
```

---

## Prompt E — Role-Based Access Control (RBAC)

```
You are adding role-based access control to Dwaar (Flutter/Dart).

Project context:
- Repo: C:/Users/dawas/dwaar
- UserRole enum: driver | supplier | recyclingCo (lib/data/models/user_role.dart)
- LocalAuthService exposes getCurrentUser() -> LocalUser?
- HomeRouter (lib/ui/features/home/home_router.dart) already branches on role.

Task:
1. Define a Permissions class in lib/backend_integration_locally/permissions.dart:
     static bool can(LocalUser user, Permission action)
   Permissions enum values: [FILL: viewOrders, claimPickup, postPickup,
   viewRewards, manageUsers — extend as needed].
2. Each UserRole maps to a fixed set of Permissions (no dynamic admin panel yet).
3. Add a PermissionGuard widget in lib/ui/common/permission_guard.dart that
   wraps a child and shows an empty/access-denied state when the current user
   lacks the required permission.
4. Replace any role-based if/switch guards in existing Tabs with PermissionGuard.
5. Do NOT add a backend admin panel — permissions are compile-time constants.

Acceptance: flutter analyze passes; role isolation is enforced at the widget level.
```
