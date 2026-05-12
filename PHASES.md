# Dawer — Execution Phases
> Ordered by risk (highest first). Each phase is a deployable unit — complete it fully before moving to the next.  
> Reference: `EVOLUTION_PLAN.md` for full details on each task.

---

## Risk Ladder

```
PHASE 1 ██████████ Security & Critical Fixes       ← START HERE (blocking production)
PHASE 2 █████████░ GCP Infrastructure Setup        ← foundational; wrong config = expensive redo
PHASE 3 █████████░ Firebase Auth Migration         ← user accounts at risk; UID mismatch = lockout
PHASE 4 ████████░░ Firestore Data Migration        ← production data; loss = unrecoverable
PHASE 5 ███████░░░ Navigation & State Foundation   ← architectural; regressions across all roles
PHASE 6 ██████░░░░ Storage + Location + Cloud Run  ← GPS tracking + file access
PHASE 7 █████░░░░░ Maps Full Integration           ← billing risk if keys not restricted
PHASE 8 ████░░░░░░ Notifications + Offline         ← reliability; additive
PHASE 9 ███░░░░░░░ AI Services Activation          ← additive; no regression risk
PHASE 10 ██░░░░░░░░ Production Cutover             ← high-ceremony; fully mitigated by phases 1-9
```

---

## Phase 1 — Security & Critical Fixes
**Risk**: Critical — hardcoded secrets + mock auth = cannot ship to real users  
**Est. time**: 2–3 days  
**Owner**: Flutter Developer  
**Unblocks**: Everything

### Tasks

#### P1-T1 — Remove hardcoded Supabase credentials
**File**: `lib/main.dart:42–43`  
**What**: The fallback strings `'https://bpzuwwbtqqrpohfqjcuo.supabase.co'` and `'sb_publishable__...'` must be deleted.  
**Replace with**:
```dart
if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
  runApp(const _BackendMissingErrorApp());
  return;
}
```
Add `_BackendMissingErrorApp` — a minimal `MaterialApp` with an Arabic error screen:
`"لم يتم تهيئة الخادم — يرجى التواصل مع الدعم الفني"`.  
**Build command**: `flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>`  
**Test**: Run without `--dart-define` flags → should show error screen, not crash.

---

#### P1-T2 — Wire LoginViewModel to live IAuthRepository
**File**: `lib/ui/features/auth/viewmodels/login_viewmodel.dart`  
**What**: Identify and remove the `MockAuthRepository` path + fake `Future.delayed(Duration(seconds: 1, milliseconds: 200))`. The `IAuthRepository` is already injected via constructor — the mock branch is the only thing to remove.  
**Also**: Adopt `ViewState<T>` for login state (create `lib/core/state/view_state.dart` first).  
**Test**: Sign in with a real Supabase account → token returned, session cached in `LocalStore`.

---

#### P1-T3 — Surface Supabase init failure as error screen
**File**: `lib/core/services/supabase_service.dart`  
**What**: Current `catch` block sets `_isInitialized = false` silently. Add:
```dart
static String? initError;
// in catch:
initError = e.toString();
```
**File**: `lib/ui/features/splash/views/splash_view.dart`  
**What**: After `SupabaseService.initialize()`, check `initError != null` → navigate to error screen instead of continuing.  
**Test**: Pass invalid URL → should show Arabic error screen.

---

#### P1-T4 — Add ViewState\<T\> sealed class
**New file**: `lib/core/state/view_state.dart`  
**What**:
```dart
sealed class ViewState<T> { const ViewState(); }
final class Idle<T>    extends ViewState<T> { const Idle(); }
final class Loading<T> extends ViewState<T> { const Loading(); }
final class Loaded<T>  extends ViewState<T> { const Loaded(this.data); final T data; }
final class Failed<T>  extends ViewState<T> { const Failed(this.failure); final AppFailure failure; }
```
Used by all ViewModels starting from P1-T2. Required before P5.

---

#### P1-T5 — Add AppLogger (replace all debugPrint)
**New file**: `lib/core/utils/app_logger.dart`  
**What**: Structured logger with `info`, `warn`, `error` methods. In debug mode → `debugPrint`. In release → no-op (Crashlytics wired in Phase 3).  
**Replace**: All `debugPrint` calls in:
- `lib/data/services/location_publisher.dart`
- `lib/core/services/supabase_service.dart`
- `lib/data/repositories/supabase_order_repository.dart`
- Any other file with `debugPrint`

---

**Phase 1 exit criteria**:
- [ ] `flutter run` without `--dart-define` shows error screen, does not crash
- [ ] `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` launches normally
- [ ] Login with a real Supabase account succeeds
- [ ] `flutter analyze` returns 0 issues
- [ ] `flutter test` passes all existing tests

---

## Phase 2 — GCP Infrastructure Setup
**Risk**: High — wrong region/config is expensive to redo; all Firebase phases depend on this  
**Est. time**: 1–2 days (mostly console clicks + CLI)  
**Owner**: Backend Engineer + Flutter Developer  
**Unblocks**: Phases 3, 4, 6

### Tasks

#### P2-T1 — Create Firebase projects
- Console: `console.firebase.google.com` → New project → `dawer-prod`
- Second project: `dawer-staging`
- Both: enable Google Analytics

---

#### P2-T2 — Enable Firebase services on both projects
For each project (`dawer-prod`, `dawer-staging`):
- Authentication → Sign-in methods: Email/Password ✓, Email Link ✓
- Firestore → Production mode → Region: **europe-west1**
- Realtime Database → Region: **europe-west1**
- Storage → Region: **europe-west1**
- FCM → enabled by default

---

#### P2-T3 — Enable Google Maps Platform APIs
Console: `console.cloud.google.com` → APIs & Services:
- Maps SDK for Android
- Maps SDK for iOS
- Directions API
- Distance Matrix API
- Places API
- Geocoding API  

Create **two restricted API keys**:
- Android key: restrict to package `com.dawer.app` + SHA-1 debug fingerprint
- iOS key: restrict to bundle ID `com.dawer.app`

---

#### P2-T4 — Register Flutter app with Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=dawer-staging
# Select: Android + iOS
# Generates: google-services.json, GoogleService-Info.plist, lib/firebase_options.dart
```
Repeat for `dawer-prod` (store as separate files, inject via CI/CD env).

---

#### P2-T5 — Add Firebase packages to pubspec.yaml
```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_database: ^11.0.0
  firebase_messaging: ^15.0.0

dev_dependencies:
  fake_cloud_firestore: ^3.0.0
  firebase_auth_mocks: ^0.14.0
```
Run `flutter pub get` and verify `flutter analyze` still passes.

---

#### P2-T6 — Add Firebase init to main.dart (behind feature flag)
```dart
const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: false);

if (useFirebase) {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
```
Verify: `flutter run --dart-define=USE_FIREBASE=true` launches (even if Firebase repos not wired yet).

---

#### P2-T7 — Set up Cloud Run project
- GCP Console → enable: Cloud Run API, Cloud Build API, Artifact Registry API
- Note GCP project ID → fill `[FILL: target GCP project ID]` in `MIGRATION_GCP.md §9.4`
- Create service accounts with minimum required roles:
  - `dawer-auth-service`: `Firebase Auth Admin`, `Cloud Datastore User`
  - `dawer-reward-service`: `Cloud Run Invoker`

---

**Phase 2 exit criteria**:
- [ ] Both Firebase projects active with all services enabled
- [ ] `lib/firebase_options.dart` generated and in `.gitignore`-safe location
- [ ] `google-services.json` and `GoogleService-Info.plist` in place (not committed)
- [ ] `flutter run --dart-define=USE_FIREBASE=true` launches without crash
- [ ] All 4 Google Maps APIs enabled; restricted keys created (noted in secure store)
- [ ] Cloud Run APIs enabled; service accounts created

---

## Phase 3 — Firebase Auth Migration
**Risk**: High — user account migration; UID mismatch = users locked out permanently  
**Est. time**: 1 week  
**Owner**: Backend Engineer (Cloud Run) + Flutter Developer  
**Depends on**: Phase 2 complete  
**Unblocks**: Phase 4 (needs UID mapping table)

### Tasks

#### P3-T1 — Write FirebaseAuthService
**New file**: `lib/data/services/firebase_auth_service.dart`  
Part files: `firebase_auth_service/auth_helpers.dart`, `firebase_auth_service/signup_helpers.dart`  
Mirror `SupabaseAuthService` contract. Key differences:
- `signInWithEmailAndPassword` instead of `signInWithPassword`
- After sign-up: call Cloud Run `POST /auth/setCustomClaims`
- `fetchCurrentProfile()`: reads `firestore.collection('users').doc(uid).get()`
- `mapAuthError()`: maps `FirebaseAuthException` codes

---

#### P3-T2 — Write FirebaseAuthRepository
**New file**: `lib/data/repositories/firebase_auth_repository.dart`  
Implements `IAuthRepository`. All methods delegate to `FirebaseAuthService`.  
Same contract as `SupabaseAuthRepository` — no domain changes.

---

#### P3-T3 — Deploy dawer-auth-service on Cloud Run
**New directory**: `cloud-run/auth-service/`  
Endpoints (see `MIGRATION_GCP.md §9.3` for full spec):
- `POST /auth/requestOtp` — generate 6-digit code → store in Firestore `/otp_verifications/{email}` (10-min TTL) → send email
- `POST /auth/verifyOtp` — validate → create/get Firebase user → set custom claims → return custom token
- `POST /auth/setCustomClaims` — Admin SDK server-to-server only
- `GET /user/emailByPhone` — query Firestore `/users` by phone field  

Deploy to `dawer-staging`:
```bash
gcloud run deploy dawer-auth-service \
  --source ./cloud-run/auth-service \
  --region europe-west1 \
  --allow-unauthenticated \
  --set-env-vars FIREBASE_PROJECT_ID=dawer-staging
```

---

#### P3-T4 — Wire custom OTP flow in FirebaseAuthService
- `requestEmailOtp(email)` → `POST /auth/requestOtp`
- `verifyEmailOtpAndGetProfile(email, code)` → `POST /auth/verifyOtp` → `signInWithCustomToken(token)`
- Password reset: `POST /auth/requestOtp` with `type: 'password_reset'` → separate `/password_reset_otps/{email}` collection

---

#### P3-T5 — Wire feature flag in main.dart
```dart
Provider<IAuthRepository>(
  create: (ctx) => useFirebase
      ? FirebaseAuthRepository(ctx.read<FirebaseAuthService>(), localStore)
      : SupabaseAuthRepository(SupabaseService.client, ...),
),
```
Test: `flutter run --dart-define=USE_FIREBASE=true` → OTP sign-in flow works in staging.

---

#### P3-T6 — User migration script (one-time, server-side Node.js)
**New file**: `scripts/migrate-users.js`  
Steps:
1. Export all rows from Supabase `public.users` via REST API
2. For each user: `admin.createUser({ email, displayName })` → `setCustomUserClaims(uid, { role, supplierType })`
3. Write `Firestore /users/{firebaseUid}` with all profile fields
4. Save mapping: `{ supabaseUid: firebaseUid }` → `scripts/uid-mapping.json`
5. Send password-reset email to all migrated users  

**Verification**: Firebase user count == Supabase user count

---

#### P3-T7 — Add LocalStore version guard
**File**: `lib/data/local/local_store.dart`  
Add `guardVersion()` — clears stale Supabase UIDs on first launch with new build.  
Call in `SplashView.initState()` before session rehydration.  
See `EVOLUTION_PLAN.md §6.8` for full implementation.

---

**Phase 3 exit criteria**:
- [ ] `POST /auth/requestOtp` + `POST /auth/verifyOtp` working on `dawer-staging` Cloud Run
- [ ] `flutter run --dart-define=USE_FIREBASE=true` → OTP sign-in creates session
- [ ] `flutter run` (no flag) → Supabase sign-in still works (no regression)
- [ ] User migration script runs clean on staging data (0 failures)
- [ ] `uid-mapping.json` generated and verified
- [ ] All `IAuthRepository` methods covered by unit tests using `firebase_auth_mocks`

---

## Phase 4 — Firestore Data Migration
**Risk**: High — production order data; a bad migration = data loss with no rollback  
**Est. time**: 1–1.5 weeks  
**Owner**: Backend Engineer + Flutter Developer  
**Depends on**: Phase 3 (needs UID mapping table)  
**Unblocks**: Phase 6 (Firestore is the database for all location/storage lookups)

### Tasks

#### P4-T1 — Write order_firestore_ext.dart
**New file**: `lib/data/models/order_firestore_ext.dart`  
- `orderFromFirestoreDoc(DocumentSnapshot)`: replaces `orderFromSupabaseJson`
  - No PostGIS: use `json['pickupLat']`, `json['pickupLng']` directly
  - Timestamps: `(json['createdAt'] as Timestamp).toDate()`
  - Enumerate all fields from `order_supabase_ext.dart` — map 1:1
- `Order.toFirestoreMap()`: produces the Firestore document map

---

#### P4-T2 — Write FirestoreOrderRepository
**New file**: `lib/data/repositories/firestore_order_repository.dart`  
Implements `IOrderRepository`. Critical design:
- **Driver stream fix (G2)**: merge two Firestore queries (pending feed + own orders), deduplicate by `order.id`
- `isVisibleToDrivers` field: managed by Cloud Function trigger (see P4-T4)
- Use `StreamZip` from `rxdart` package (add to pubspec) or manual `StreamController`

---

#### P4-T3 — Deploy Firestore composite indexes
In `firestore.indexes.json`:
```json
{ "collection": "orders", "fields": [{"fieldPath":"supplierId","order":"ASCENDING"},{"fieldPath":"createdAt","order":"DESCENDING"}] },
{ "collection": "orders", "fields": [{"fieldPath":"companyId","order":"ASCENDING"},{"fieldPath":"createdAt","order":"DESCENDING"}] },
{ "collection": "orders", "fields": [{"fieldPath":"driverId","order":"ASCENDING"},{"fieldPath":"createdAt","order":"DESCENDING"}] },
{ "collection": "orders", "fields": [{"fieldPath":"isVisibleToDrivers","order":"ASCENDING"},{"fieldPath":"createdAt","order":"DESCENDING"}] }
```
Deploy: `firebase deploy --only firestore:indexes --project dawer-staging`

---

#### P4-T4 — Deploy Firestore Security Rules + Cloud Function trigger
**File**: `firestore.rules` — full rules from `MIGRATION_GCP.md §13.1`  
**Cloud Function**: `syncDriverVisibility` — sets `isVisibleToDrivers = (status == 'pending' && !driverId)` on every order write  
Test with Firebase Emulator:
```bash
firebase emulators:exec --only firestore "flutter test test/security_rules/"
```
Test matrix: supplier read/write own only · driver pending feed · recyclingCo own only · unauthenticated = PERMISSION_DENIED

---

#### P4-T5 — Wire FirestoreOrderRepository in main.dart
```dart
Provider<IOrderRepository>(
  create: (_) => useFirebase
      ? FirestoreOrderRepository()
      : SupabaseOrderRepository(SupabaseService.client),
),
```

---

#### P4-T6 — Order data migration script (one-time Node.js)
**New file**: `scripts/migrate-orders.js`  
Steps:
1. Export all orders from Supabase REST API
2. For each order: remap `supplier_id`/`driver_id`/`company_id` using `uid-mapping.json`
3. Convert PostGIS POINT string `'POINT(lng lat)'` → `{ pickupLat, pickupLng }` floats
4. Convert snake_case → camelCase field names
5. Set `isVisibleToDrivers = (status === 'pending' && !driverId)`
6. Write to Firestore: `db.collection('orders').doc(order.id).set(orderDoc)`
7. Verify: Supabase count == Firestore count  

Run dry-run first (write to a `orders_migration_test` collection), spot-check 10 random orders.

---

**Phase 4 exit criteria**:
- [ ] `FirestoreOrderRepository` passes all existing `app_order_store_test.dart` tests
- [ ] Driver sees only pending + own orders (G2 fixed) — verified via Firestore Emulator
- [ ] Security rules pass full test matrix
- [ ] Migration script runs clean on staging data
- [ ] Staging order count == Supabase order count
- [ ] `flutter run --dart-define=USE_FIREBASE=true` → all 3 roles can see their orders

---

## Phase 5 — Navigation & State Foundation
**Risk**: Medium-High — touches every screen; regression risk across all 3 role flows  
**Est. time**: 1–1.5 weeks  
**Owner**: Flutter Developer  
**Depends on**: Phase 1 complete (ViewState<T> already created in P1-T4)  
**Unblocks**: Phase 8 (push notification deep-links need go_router)

### Tasks

#### P5-T1 — Add go_router
```yaml
go_router: ^14.0.0
```
**New file**: `lib/core/routing/app_router.dart`  
Route tree (see `EVOLUTION_PLAN.md §5.1`):
- `/` → SplashView (redirect logic)
- `/login`, `/login/otp`, `/signup` → auth views
- `/home/driver`, `/home/supplier`, `/home/recycling` → ShellRoutes with role guard
- `/order/:id`, `/order/:id/tracking`, `/marketplace/:id` → detail screens

Auth guard: redirect unauthenticated → `/login`; redirect authenticated from `/login` → `/home/:role`

---

#### P5-T2 — Replace all Navigator.push calls
Audit and replace every imperative navigation call in:
- `lib/ui/features/auth/` — login/signup/otp/forgot-password flows
- `lib/ui/features/home/driver/` — all tabs + order detail
- `lib/ui/features/home/supplier/` — all tabs + new-order flow
- `lib/ui/features/home/recycling/` — all tabs
- `lib/ui/features/home/shared/` — order details, market item details
- `SplashView` → `HomeRouter` → now a `GoRoute` redirect

Use `context.go()` for replace, `context.push()` for stack.

---

#### P5-T3 — Update all ViewModels to ViewState\<T\>
Priority order (highest user-facing impact first):
1. `LoginViewModel` (already done in P1-T2)
2. `SignUpViewModel` / `VerificationViewModel`
3. `DriverHomeViewModel`
4. `SupplierHomeViewModel` / `IndividualSupplierViewModel`
5. `RecyclingHomeViewModel`
6. `MarketplaceViewModel`
7. `ForgotPasswordViewModel`

Standard pattern for each (see `EVOLUTION_PLAN.md §3`).

---

#### P5-T4 — Add AppOrderStore stream reconnect (Gap REL-1)
**File**: `lib/data/services/app_order_store.dart`
```dart
_remoteSub = _remote.watchOrdersForUser(userId, role)
    .listen(_onRemoteOrders, onError: (_) => _scheduleReconnect());

void _scheduleReconnect() {
  Future.delayed(const Duration(seconds: 5), () => _subscribe(userId, role));
}
```

---

**Phase 5 exit criteria**:
- [ ] All navigation uses `go_router` — zero `Navigator.push` calls remaining
- [ ] Auth guard redirects unauthenticated users to `/login`
- [ ] Deep-link `/order/:id` opens order details from cold start
- [ ] All 7 ViewModels use `ViewState<T>` — no ad-hoc `isLoading` booleans
- [ ] `flutter test` passes all existing tests
- [ ] Manual regression: all 3 role home flows work end-to-end

---

## Phase 6 — Storage + Location + Cloud Run
**Risk**: Medium — GPS tracking and file access downtime during migration  
**Est. time**: 1 week  
**Owner**: Flutter Developer + Backend Engineer  
**Depends on**: Phase 2 + Phase 4

### Tasks

#### P6-T1 — Write FirebaseFileStorageRepository
**New file**: `lib/data/repositories/firebase_file_storage_repository.dart`  
Implements `IFileStorageRepository`. Profile photos: public read. Identity docs: owner-only.  
Deploy Firebase Storage Security Rules.

#### P6-T2 — File migration script
**New file**: `scripts/migrate-files.js`  
Download from Supabase Storage → upload to Firebase Storage at matching path.  
Update `Firestore /users/{uid}.profilePhotoUrl` to new Firebase Storage URLs.

#### P6-T3 — Write FirebaseLocationPublisher (fixes G6)
**New file**: `lib/data/services/firebase_location_publisher.dart`  
Implements `ILocationPublisher`. Injects `FirebaseDatabase` (not global singleton).  
On network failure: buffer last position, retry on reconnect.

#### P6-T4 — Write FirebaseDriverLocationStream
**New file**: `lib/data/services/firebase_driver_location_stream.dart`  
`FirebaseDatabase.ref('driver_locations/$orderId').onValue` → `Stream<LatLng>`.  
Deploy Realtime Database Security Rules.

#### P6-T5 — Deploy dawer-reward-service on Cloud Run
**New directory**: `cloud-run/reward-service/`  
Mirrors `RewardService.calculate()` logic. `POST /reward/calculate`.  
Flutter `RewardService` stays as offline fallback. Wire: try Cloud Run → on failure → local.

#### P6-T6 — Wire all new implementations in main.dart (behind flag)
```dart
Provider<IFileStorageRepository>(
  create: (_) => useFirebase ? FirebaseFileStorageRepository() : SupabaseFileStorageRepository(),
),
Provider<ILocationPublisher>(
  create: (_) => useFirebase ? FirebaseLocationPublisher.instance : LocationPublisher.instance,
),
```

---

**Phase 6 exit criteria**:
- [ ] Profile photo upload/display works with Firebase Storage
- [ ] GPS tracking: driver location updates visible on supplier map (Firebase RTDB)
- [ ] `POST /reward/calculate` on Cloud Run returns correct breakdown
- [ ] `flutter run --dart-define=USE_FIREBASE=true` → GPS tracking + files work

---

## Phase 7 — Maps Full Integration
**Risk**: Medium — billing spike if API keys not restricted before launch  
**Est. time**: 3–4 days  
**Owner**: Flutter Developer  
**Depends on**: Phase 2 (keys created), Phase 4 (Firestore for address storage)

### Tasks

#### P7-T1 — Configure Maps API keys in native projects
- Android `AndroidManifest.xml`: `android:value="${MAPS_API_KEY}"`
- iOS `AppDelegate.swift`: `GMSServices.provideAPIKey(...)`
- Build: `flutter run --dart-define=MAPS_API_KEY=AIza...`

#### P7-T2 — Write GeocodingService
**New file**: `lib/data/services/geocoding_service.dart`  
`reverseGeocode(lat, lng)` → Arabic `formatted_address` from Google Geocoding API.  
Called at order creation (supplier confirms pin). Stored in Firestore at creation time.

#### P7-T3 — Build PickupLocationPickerView
**New file**: `lib/ui/common/map/pickup_location_picker_view.dart`  
`GoogleMap` + long-press → drop pin → reverse geocode → fills address field.  
Wire into `new_pickup_request_view.dart`.

#### P7-T4 — Add Directions API polyline to tracking map
**File**: `lib/ui/common/map/live_tracking_map_view.dart`  
Draw route polyline: driver current pos → pickup → dropoff using Directions API.

#### P7-T5 — Add Distance Matrix ETA
Replace hardcoded `order.eta` string with live ETA from Distance Matrix API.  
Store `etaMinutes` in `AppOrderStore`. Display in Arabic in `order_tracking_card.dart`.

---

**Phase 7 exit criteria**:
- [ ] Maps render on Android + iOS with no API key console warnings
- [ ] Supplier can pin-drop pickup location; address auto-fills in Arabic
- [ ] Live tracking shows polyline route, not just a marker
- [ ] ETA displayed in Arabic numerals, updates every 30 seconds
- [ ] No billing alert triggered (keys restricted, usage < $10 in staging)

---

## Phase 8 — Notifications + Offline Resilience
**Risk**: Medium — additive features; main risk is FCM misconfiguration  
**Est. time**: 1–1.5 weeks  
**Owner**: Flutter Developer + Backend Engineer  
**Depends on**: Phase 5 (go_router deep-links), Phase 4 (Firestore triggers)

### Tasks

#### P8-T1 — Firestore Cloud Function: status change → FCM
```javascript
exports.notifyOnStatusChange = onDocumentUpdated('orders/{id}', async (event) => {
  // Compare before/after status
  // Look up recipient UID (supplier / driver based on status + role)
  // Send FCM via admin.messaging().send({ token, notification, data: { orderId, screen } })
});
```

#### P8-T2 — Flutter FCM setup
- Android: `google-services.json` already in place (Phase 2)
- iOS: APNs certificate in Firebase Console; capability in Xcode
- `FirebaseMessaging.onMessage` → merge with `AppOrderStore` (deduplicate with Firestore stream)
- `FirebaseMessaging.onMessageOpenedApp` → `context.go('/order/$orderId')`

#### P8-T3 — Add connectivity_plus
```yaml
connectivity_plus: ^6.0.0
```
**New file**: `lib/core/services/connectivity_notifier.dart`

#### P8-T4 — AppOrderStore write-retry queue
On `NetworkFailure` from any mutation → enqueue `{ operation, payload }`.  
On `ConnectivityNotifier.isOnline` → true: replay queue.

#### P8-T5 — OfflineBanner widget
**New file**: `lib/ui/common/offline_banner.dart`  
Arabic text: `"لا يوجد اتصال — سيُرسل طلبك تلقائياً عند الاتصال"`  
Show in all three role home views when `ConnectivityNotifier.isOnline == false`.

---

**Phase 8 exit criteria**:
- [ ] Driver receives push when supplier submits order
- [ ] Supplier receives push when driver accepts/completes order
- [ ] Notification tap → opens correct order details screen
- [ ] Offline banner appears when network drops; disappears when restored
- [ ] Failed order mutation queued and retried on reconnect

---

## Phase 9 — AI Services Activation
**Risk**: Low — purely additive; mock services remain as fallback  
**Est. time**: 2–3 weeks  
**Owner**: Backend Engineer + Flutter Developer  
**Depends on**: Phase 6 (Cloud Run already running)

### Tasks

#### P9-T1 — Deploy dawer-ai-service on Cloud Run
- `POST /ai/marketplace` — AI marketplace suggestions
- `POST /ai/chat` — LLM-backed chatbot (Phase B)
- `POST /ai/validateLicense` — document validation (if server-side decision)

#### P9-T2 — Write CloudRunAiMarketplaceService
Implements `IAiMarketplaceService`. Replace `MockAiMarketplaceService` under `useFirebase` flag.

#### P9-T3 — Chatbot Phase A: Firestore knowledge base
Load FAQ from `Firestore /chatbot_kb`. Augment keyword matching with structured data.

#### P9-T4 — Unify RewardService with Cloud Run (Gap G8)
`RewardService.calculate()` tries Cloud Run first → on network failure → local calculation.  
Add unit test verifying both paths produce identical output for same inputs.

#### P9-T5 — License validation decision
Evaluate: on-device ML Kit (< 10 MB model) vs Cloud Run.  
If on-device: add confidence threshold guard → `ValidationResult.manualReview` if `confidence < 0.75`.

---

**Phase 9 exit criteria**:
- [ ] AI marketplace returns real suggestions (not mock data) under `USE_FIREBASE=true`
- [ ] Chatbot answers from Firestore FAQ (not just static keywords)
- [ ] Reward calculation parity test passes (Cloud Run == local for same inputs)
- [ ] License validation returns `manualReview` on low-confidence images

---

## Phase 10 — Production Cutover
**Risk**: High-ceremony but fully mitigated — all risk absorbed in Phases 1–9  
**Est. time**: 1 week (including 48h observation)  
**Owner**: Tech Lead + Backend Engineer  
**Depends on**: All previous phases verified in staging

### Pre-cutover gate (all must be green)
- [ ] Full test suite: `flutter test --dart-define=USE_FIREBASE=true` → 0 failures
- [ ] `flutter analyze` → 0 issues
- [ ] Firestore / Storage / RTDB security rules audited (no open read/write)
- [ ] Cloud Run health checks passing
- [ ] All API keys restricted
- [ ] Firebase billing alerts set ($50 / $200)
- [ ] Production data migration completed + verified
- [ ] Rollback APK/IPA with `USE_FIREBASE=false` staged

### Cutover sequence
```
T-48h  Final incremental data sync
T-24h  Deploy Cloud Run services to production
T-12h  Firebase Auth open for new sign-ups (parallel to Supabase)
T-0    Production app build with USE_FIREBASE=true → Play Store + App Store
T+2h   Monitor Crashlytics + Cloud Logging
T+48h  Confirm or rollback decision
T+30d  Delete Supabase files from codebase; decommission Supabase project
```

### Rollback triggers
| Trigger | Action |
|---|---|
| Crashlytics error rate > 5% | Push rollback build (`USE_FIREBASE=false`) within 15 min |
| Cloud Run p95 latency > 5s | Scale up min-instances; use local `RewardService` fallback |
| Firestore Security Rule breach | Emergency: deploy deny-all rules; investigate |
| Firebase Auth OTP delivery failure | Enable email-link sign-in as temporary path |

---

*Phases plan v1.0 — 10 phases, ordered highest-to-lowest risk*  
*Start with Phase 1. Each phase has clear exit criteria before moving to the next.*
