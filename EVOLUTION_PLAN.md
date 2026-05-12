# Dawer — Evolution Plan
> Single source of truth for all upcoming architectural changes, performance work, and new features.  
> Based on: `ARCHITECTURE.md` (gaps G1–G12), `MIGRATION_GCP.md` (Phases 0–8), and live codebase audit.

---

## Table of Contents
1. [Guiding Principles](#1-guiding-principles)
2. [Current State Snapshot](#2-current-state-snapshot)
3. [Target Architecture](#3-target-architecture)
4. [Sprint 0 — Critical Security & Stability](#4-sprint-0--critical-security--stability)
5. [Sprint 1 — Navigation, State, UX Foundation](#5-sprint-1--navigation-state-ux-foundation)
6. [Sprint 2 — GCP Migration: Auth & Database](#6-sprint-2--gcp-migration-auth--database)
7. [Sprint 3 — GCP Migration: Storage, Location, Cloud Run](#7-sprint-3--gcp-migration-storage-location-cloud-run)
8. [Sprint 4 — Maps Full Integration](#8-sprint-4--maps-full-integration)
9. [Sprint 5 — Notifications & Offline Resilience](#9-sprint-5--notifications--offline-resilience)
10. [Sprint 6 — AI Services Activation](#10-sprint-6--ai-services-activation)
11. [Sprint 7 — Flutter Frontend Rewire & Cutover](#11-sprint-7--flutter-frontend-rewire--cutover)
12. [Performance Optimization Guide](#12-performance-optimization-guide)
13. [New Features Backlog](#13-new-features-backlog)
14. [File Responsibility Map (Target State)](#14-file-responsibility-map-target-state)
15. [Coding Rules & Patterns](#15-coding-rules--patterns)
16. [Checklist Tracker](#16-checklist-tracker)

---

## 1. Guiding Principles

These rules govern every change we make. When in doubt, return here.

| # | Principle | What it means in practice |
|---|---|---|
| P1 | **Interfaces own the contract** | Domain interfaces (`IAuthRepository`, `IOrderRepository`, `IFileStorageRepository`) never change when we swap backends. Only `main.dart` wiring changes. |
| P2 | **No business logic in UI** | ViewModels hold state and call repository/store methods. Views only read state and fire user events. A ViewModel should be fully testable with zero Flutter imports. |
| P3 | **Fail loudly in dev, fail gracefully in prod** | `assert`/`throw` during development. In release builds, `AppFailure` propagated through `AppResult<T>` shown to user as an Arabic error message. No silent swallows. |
| P4 | **Every file ≤ 200 lines** | If a file grows past 200 lines, split by responsibility (use `part`/`part of` for same-class extensions, separate files for separate concepts). |
| P5 | **Feature flag pattern for migrations** | New GCP implementations live alongside Supabase ones. Swap in `main.dart` via `const useFirebase`. Zero domain or UI layer changes at cutover. |
| P6 | **Arabic first** | All user-visible strings go through `AppLocalizations` (`.arb` files). Never hardcode Arabic or English strings in widget code. |
| P7 | **AppColors tokens only** | Never use raw hex values. Always `AppColors.primaryGreen`, `AppColors.accentAmber`, etc. |
| P8 | **Result, not exceptions** | All repository and service methods return `AppResult<T>`. The ViewModel calls `.fold(onSuccess:, onFailure:)`. Never `try/catch` in the UI layer. |
| P9 | **Single source of truth for orders** | `AppOrderStore` is the only object that mutates order state. Role proxy stores (`DriverOrderStore`, etc.) are read-only filtered views. |
| P10 | **Secrets never in source** | API keys, Supabase/Firebase credentials always via `--dart-define` at build time. Remove every hardcoded fallback before any production build. |

---

## 2. Current State Snapshot

### What is working
- Clean three-layer separation (`domain/`, `data/`, `ui/`) — no leakage.
- `AppResult<T>` / `fold` error propagation across all repositories.
- Role-proxy stores (`DriverOrderStore`, `SupplierOrderStore`, `RecyclingOrderStore`).
- `Order` model split into focused part files (≤ 200 lines each).
- `LocalStore` — typed `SharedPreferences` wrapper.
- Realtime order stream (supplier + recyclingCo filtered; driver unfixed).
- Unit tests for `AppOrderStore`, reward service, collection sale lifecycle.
- `supabase_auth_service` part-file split.

### Critical blockers before production

| ID | Issue | File | Severity |
|---|---|---|---|
| SEC-1 | Hardcoded Supabase anon key fallback | `main.dart:43` | **Critical** |
| G1 | `LoginViewModel` wired to mock with fake 1.2s delay | `login_viewmodel.dart` | **High** |
| G2 | Driver order stream fetches full `orders` table (no server filter) | `supabase_order_repository.dart` | **High** |
| G6 | `LocationPublisher` calls `Supabase.instance.client` directly (not injected) | `location_publisher.dart` | **Medium** |
| G12 | `SupabaseService` swallows init exceptions silently | `supabase_service.dart` | **Medium** |

---

## 3. Target Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Flutter App (iOS + Android)                                         │
│                                                                      │
│  UI Layer                                                            │
│  ┌────────────┐  ┌─────────────────────┐  ┌─────────────────────┐   │
│  │ Auth Views │  │ Home Views (3 roles) │  │ Maps + Chatbot + AI │   │
│  │    + VMs   │  │ + VMs + Widgets      │  │ Views + VMs         │   │
│  └─────┬──────┘  └──────────┬──────────┘  └──────────┬──────────┘   │
│        │  go_router (auth guard + deep-link)          │              │
│        │  Provider + ChangeNotifier + ViewState<T>    │              │
│  ──────┼──────────────────────────────────────────────┼──────────    │
│  Domain Layer  (NEVER changes between backends)                      │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │  IAuthRepository · IOrderRepository · IFileStorageRepository  │   │
│  │  ILocationPublisher · IAiMarketplaceService                   │   │
│  │  AppFailure (sealed) · AppResult<T> · ViewState<T>            │   │
│  └──────────────────────────┬────────────────────────────────────┘   │
│  ──────────────────────────────────────────────────────────────────  │
│  Data Layer                                                          │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │  AppOrderStore (ChangeNotifier) + 5 domain part files        │    │
│  │  DriverOrderStore · SupplierOrderStore · RecyclingOrderStore  │    │
│  │  LocalStore (SharedPreferences)                               │    │
│  │                                                               │    │
│  │  [Phase: Supabase]      [Phase: Firebase — feature-flagged]   │    │
│  │  SupabaseAuthRepository  FirebaseAuthRepository               │    │
│  │  SupabaseOrderRepo       FirestoreOrderRepository             │    │
│  │  SupabaseFileStorage     FirebaseFileStorageRepository        │    │
│  │  LocationPublisher       FirebaseLocationPublisher            │    │
│  │  DriverLocationStream    FirebaseDriverLocationStream         │    │
│  └────────────┬─────────────────────────────┬────────────────────┘   │
└───────────────┼─────────────────────────────┼────────────────────────┘
                │  Firebase SDK (HTTPS/WSS)    │  Maps SDK + Cloud Run
                ▼                             ▼
   ┌────────────────────────┐    ┌────────────────────────────────────┐
   │  Firebase Project      │    │  Google Cloud                      │
   │  ├─ Firebase Auth      │    │  ├─ Cloud Run: dawer-auth-service  │
   │  ├─ Cloud Firestore    │    │  ├─ Cloud Run: dawer-reward-service│
   │  ├─ Realtime Database  │    │  ├─ Google Maps Platform           │
   │  ├─ Firebase Storage   │    │  │   Directions · Distance Matrix  │
   │  └─ FCM                │    │  │   Places · Geocoding            │
   └────────────────────────┘    └────────────────────────────────────┘
```

### State management pattern (ViewState<T>)

Every ViewModel adopts this sealed state type — no more ad-hoc boolean flags:

```dart
// lib/core/state/view_state.dart  (NEW FILE)
sealed class ViewState<T> {
  const ViewState();
}
final class Idle<T>    extends ViewState<T> { const Idle(); }
final class Loading<T> extends ViewState<T> { const Loading(); }
final class Loaded<T>  extends ViewState<T> {
  const Loaded(this.data);
  final T data;
}
final class Failed<T>  extends ViewState<T> {
  const Failed(this.failure);
  final AppFailure failure;
}
```

Standard ViewModel action template:
```dart
Future<void> onAction() async {
  _state = const Loading();
  notifyListeners();
  final result = await _repo.doSomething();
  _state = result.fold(
    onSuccess: (v) => Loaded(v),
    onFailure: (f) => Failed(f),
  );
  notifyListeners();
}
```

---

## 4. Sprint 0 — Critical Security & Stability

**Goal**: App safe to test with real users. All blockers removed.  
**Time estimate**: 2–3 days.

### Tasks

- [ ] **SEC-1** Remove hardcoded Supabase credentials from `main.dart:42–43`
  - Replace with: `if (supabaseUrl.isEmpty) { show ErrorScreen('Backend not configured'); return; }`
  - Never ship a fallback key. Use `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

- [ ] **G1** Wire `LoginViewModel` to live `IAuthRepository`
  - `lib/ui/features/auth/viewmodels/login_viewmodel.dart`
  - Remove the `MockAuthRepository` path and the fake 1.2s `Future.delayed`
  - `LoginViewModel` already receives `IAuthRepository` via constructor — just remove the mock branch

- [ ] **G12** Surface Supabase init failure as error screen
  - `lib/core/services/supabase_service.dart` — on catch, set an `initError` string
  - `SplashView` — if `SupabaseService.initError != null`, show `InitErrorScreen` with Arabic message

- [ ] **SEC-3** Document Maps API key restriction steps
  - Android: restrict to `com.dawer.app` + SHA-1 in Google Cloud Console
  - iOS: restrict to bundle ID `com.dawer.app`
  - Add to CI/CD build notes

---

## 5. Sprint 1 — Navigation, State, UX Foundation

**Goal**: Declarative routing, consistent loading/error UX across all screens.  
**Time estimate**: 1–1.5 weeks.

### 5.1 Add `go_router`

```yaml
# pubspec.yaml
go_router: ^14.0.0
```

Route structure:
```
/                     → SplashView (auth guard)
/login                → LoginView
/login/otp            → OtpView
/signup               → SignUpView
/home/driver          → DriverHomeView   (ShellRoute — guard: role == driver)
/home/supplier        → SupplierHomeView (ShellRoute — guard: role == supplier)
/home/recycling       → RecyclingHomeView (ShellRoute — guard: role == recyclingCo)
/order/:id            → OrderDetailsView
/order/:id/tracking   → OrderTrackingView
/marketplace/:id      → MarketItemDetailsView
```

Auth guard:
```dart
redirect: (ctx, state) {
  final loggedIn = ctx.read<IAuthRepository>().hasSession;
  final isLogin = state.matchedLocation.startsWith('/login');
  if (!loggedIn && !isLogin) return '/login';
  if (loggedIn && isLogin) return '/home/${role.name}';
  return null;
}
```

- [ ] Create `lib/core/routing/app_router.dart`
- [ ] Replace all `Navigator.push`/`pushReplacement` calls with `context.go()` / `context.push()`
- [ ] Remove `HomeRouter` switch (becomes a `GoRoute` redirect)
- [ ] Add deep-link support for push notification tap-to-order (required for Sprint 5)

### 5.2 Add `ViewState<T>`

- [ ] Create `lib/core/state/view_state.dart`
- [ ] Update `LoginViewModel`, `SignUpViewModel`, `VerificationViewModel` to use `ViewState`
- [ ] Update `SupplierHomeViewModel`, `DriverHomeViewModel`, `RecyclingHomeViewModel`
- [ ] Standard UI pattern for all loading states:
  ```dart
  // In build():
  switch (vm.state) {
    Idle()    => _buildContent(),
    Loading() => const AppLoadingSpinner(),
    Loaded(data: var d) => _buildContent(d),
    Failed(failure: var f) => AppErrorBanner(message: f.arabicMessage),
  }
  ```

### 5.3 Add structured logger

- [ ] Create `lib/core/utils/app_logger.dart`
  ```dart
  class AppLogger {
    static void info(String tag, String msg) { ... }
    static void warn(String tag, String msg) { ... }
    static void error(String tag, Object err, [StackTrace? st]) { ... }
  }
  ```
- [ ] Replace all `debugPrint` calls with `AppLogger`
- [ ] In release builds, route to Firebase Crashlytics (wired in Sprint 2)

---

## 6. Sprint 2 — GCP Migration: Auth & Database

**Goal**: Firebase Auth + Firestore running in staging with feature flag.  
**Time estimate**: 1.5–2 weeks.  
**Reference**: `MIGRATION_GCP.md` §5 + §6.

### 6.1 Firebase project setup (Phase 0)

- [ ] Create Firebase project `dawer-prod` + `dawer-staging`
- [ ] Enable: Auth (email/password + email link), Firestore (europe-west1), Realtime DB, Storage, FCM
- [ ] Run `flutterfire configure` → generates `lib/firebase_options.dart` + platform config files
- [ ] Add to `pubspec.yaml`:
  ```yaml
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_database: ^11.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
  ```

### 6.2 Write `FirebaseAuthService`

- [ ] `lib/data/services/firebase_auth_service.dart` (mirrors `SupabaseAuthService`)
- [ ] Part files: `firebase_auth_service/auth_helpers.dart`, `firebase_auth_service/signup_helpers.dart`
- [ ] Custom OTP flow: Cloud Run `POST /auth/requestOtp` → `POST /auth/verifyOtp` → `signInWithCustomToken`
- [ ] After sign-up: call Cloud Run `POST /auth/setCustomClaims` to set `{ role, supplierType }` on Firebase JWT

### 6.3 Write `FirebaseAuthRepository`

- [ ] `lib/data/repositories/firebase_auth_repository.dart` implements `IAuthRepository`
- [ ] All methods delegate to `FirebaseAuthService` — same contract as `SupabaseAuthRepository`

### 6.4 Write `FirestoreOrderRepository`

- [ ] `lib/data/repositories/firestore_order_repository.dart` implements `IOrderRepository`
- [ ] Fix driver stream (Gap G2): use two merged Firestore queries:
  ```dart
  // Feed: isVisibleToDrivers == true
  // Own:  driverId == userId
  // Merge + deduplicate by order.id + sort by createdAt
  ```
- [ ] Write `lib/data/models/order_firestore_ext.dart`:
  - `orderFromFirestoreDoc(DocumentSnapshot)` — replaces `orderFromSupabaseJson`
  - `Order.toFirestoreMap()` — no PostGIS, plain lat/lng fields
  - Timestamps: `(json['createdAt'] as Timestamp).toDate()`

### 6.5 Firestore Security Rules

Deploy to `dawer-staging` and test with Firebase Emulator:
```javascript
// Full rules in MIGRATION_GCP.md §13.1
// Test matrix:
// - Supplier: read/write own orders only
// - Driver: read pending feed + own accepted orders; update only own
// - RecyclingCo: read/write own collection jobs
// - Unauthenticated: PERMISSION_DENIED on all writes
```

### 6.6 Feature flag in `main.dart`

```dart
const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: false);

// Provider<IAuthRepository>:
create: (ctx) => useFirebase
    ? FirebaseAuthRepository(ctx.read<FirebaseAuthService>(), localStore)
    : SupabaseAuthRepository(...),

// Provider<IOrderRepository>:
create: (_) => useFirebase
    ? FirestoreOrderRepository()
    : SupabaseOrderRepository(SupabaseService.client),
```

Run staging: `flutter run --dart-define=USE_FIREBASE=true`

### 6.7 User migration (one-time script)

- [ ] Node.js script: export Supabase `public.users` → `Firebase Admin createUser` + `setCustomClaims`
- [ ] Build UID mapping table: `supabaseUid → firebaseUid`
- [ ] Migrate all `orders` rows: remap `supplier_id`/`driver_id`/`company_id` using mapping table
- [ ] Convert PostGIS POINT → `pickupLat`/`pickupLng` float fields
- [ ] Verify: Supabase row count == Firestore document count

### 6.8 LocalStore version guard

```dart
// lib/data/local/local_store.dart — add:
static const _buildVersionKey = 'dwaar_build_version';
static const currentBuildVersion = 2; // bump on each breaking UID format change

Future<void> guardVersion() async {
  final stored = _prefs.getInt(_buildVersionKey) ?? 0;
  if (stored < currentBuildVersion) {
    await clearAll();
    await _prefs.setInt(_buildVersionKey, currentBuildVersion);
  }
}
```

Call `localStore.guardVersion()` in `SplashView.initState()` before session rehydration.

---

## 7. Sprint 3 — GCP Migration: Storage, Location, Cloud Run

**Goal**: Files on Firebase Storage, GPS on RTDB, reward calc on Cloud Run.  
**Time estimate**: 1.5 weeks.  
**Reference**: `MIGRATION_GCP.md` §7 + §8 + §9.

### 7.1 `FirebaseFileStorageRepository`

- [ ] `lib/data/repositories/firebase_file_storage_repository.dart` implements `IFileStorageRepository`
- [ ] Profile photos: `profile-photos/{uid}/profile.ext` — public read
- [ ] Identity docs: `user-documents/{uid}/identity.ext` — owner read only
- [ ] Deploy Firebase Storage Security Rules (see `MIGRATION_GCP.md` §7.1)

### 7.2 `FirebaseLocationPublisher`

- [ ] `lib/data/services/firebase_location_publisher.dart` implements `ILocationPublisher`
- [ ] Injects `FirebaseDatabase` instead of calling `Supabase.instance.client` directly (fixes G6)
- [ ] On `stop()`: `_db.ref('driver_locations/$orderId').remove()`
- [ ] On network failure: buffer last position, retry on reconnect (fixes G6 + partial G9)

### 7.3 `FirebaseDriverLocationStream`

- [ ] `lib/data/services/firebase_driver_location_stream.dart`
- [ ] `FirebaseDatabase.instance.ref('driver_locations/$orderId').onValue` → `Stream<LatLng>`
- [ ] Deploy Realtime Database Security Rules (see `MIGRATION_GCP.md` §8.3)

### 7.4 Cloud Run services

Deploy two services:

**`dawer-auth-service`** (Node.js 20 or Dart shelf):
- `POST /auth/requestOtp` — generate 6-digit code, store in Firestore `/otp_verifications`, send email
- `POST /auth/verifyOtp` — validate code, create/get Firebase user, set custom claims, return custom token
- `POST /auth/setCustomClaims` — server-to-server only
- `GET /user/emailByPhone` — query Firestore `/users` by phone

**`dawer-reward-service`** (mirrors current `RewardService` logic):
- `POST /reward/calculate` — authoritative calculation
- Flutter `RewardService.calculate()` stays as offline fallback (fixes G8)
- Set `min-instances: 1` to eliminate cold start

---

## 8. Sprint 4 — Maps Full Integration

**Goal**: Live tracking with polyline + ETA, supplier location picker, Geocoding for addresses.  
**Time estimate**: 3–4 days.  
**Reference**: `MIGRATION_GCP.md` §10.

### 8.1 API key configuration

- [ ] Android `AndroidManifest.xml`: `android:value="${MAPS_API_KEY}"`
- [ ] iOS `AppDelegate.swift`: `GMSServices.provideAPIKey(...)`
- [ ] Build: `flutter run --dart-define=MAPS_API_KEY=AIza...`
- [ ] Restrict keys in Google Cloud Console (package name + SHA-1 / bundle ID)

### 8.2 Address resolution (fixes hardcoded `'موقع السحب المختار'`)

- [ ] Store `pickupAddress` as a string field in Firestore at order creation time
- [ ] `lib/data/services/geocoding_service.dart` (NEW):
  ```dart
  Future<String> reverseGeocode(double lat, double lng) async {
    // GET maps.googleapis.com/maps/api/geocode/json?latlng=...&language=ar
    // Return formatted_address
  }
  ```
- [ ] Call at order creation when supplier confirms pin location

### 8.3 Live tracking enhancements

- [ ] `order_tracking_card.dart`: replace placeholder with `FirebaseDriverLocationStream`
- [ ] Add Directions API polyline — draw route driver → pickup → dropoff
- [ ] Add Distance Matrix API ETA:
  ```
  GET /maps/api/distancematrix/json
    ?origins={driverLat},{driverLng}
    &destinations={pickupLat},{pickupLng}
    &mode=driving&language=ar
  ```
- [ ] Replace hardcoded `order.eta` string with live `etaMinutes` computed from API
- [ ] Store `etaMinutes` in `AppOrderStore` for display in Arabic

### 8.4 Pickup location picker

- [ ] New widget: `lib/ui/common/map/pickup_location_picker_view.dart`
- [ ] `GoogleMap` + long-press to drop pin → reverse geocode → fills address field
- [ ] Updates `CreatePickupRequest.pickupLat`, `.pickupLng`, `.pickupAddress`
- [ ] Used in `new_pickup_request_view.dart` and supplier sign-up address step

---

## 9. Sprint 5 — Notifications & Offline Resilience

**Goal**: Order status push notifications + offline write queue.  
**Time estimate**: 1.5 weeks.

### 9.1 Push notifications (FCM)

- [ ] `firebase_messaging` already in pubspec from Sprint 2
- [ ] Firestore Cloud Function trigger: on order status change → send FCM to relevant user
  ```javascript
  exports.notifyOnStatusChange = onDocumentUpdated('orders/{id}', async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (before.status === after.status) return;
    // send to supplierId / driverId based on role + new status
  });
  ```
- [ ] Flutter: foreground message → `AppOrderStore` merge (deduplicate with Firestore stream)
- [ ] Background tap → `go_router` deep-link to `/order/:id`
- [ ] Notification payload: `{ orderId, status, role }` — parsed in `go_router` redirect

### 9.2 Offline write queue (Gap G9)

- [ ] Add `connectivity_plus: ^6.0.0` to pubspec
- [ ] Create `lib/core/services/connectivity_notifier.dart`:
  ```dart
  class ConnectivityNotifier extends ChangeNotifier {
    bool get isOnline => _isOnline;
    // listens to connectivity_plus stream
    // notifyListeners() on change
  }
  ```
- [ ] In `AppOrderStore`: on `NetworkFailure`, enqueue `{ operation, payload, orderId }` in memory
- [ ] When `ConnectivityNotifier.isOnline` flips true, replay queue
- [ ] Show `OfflineBanner` widget in home views when offline:
  - Arabic text: `"لا يوجد اتصال — سيُرسل طلبك تلقائياً عند الاتصال"`
- [ ] `AppOrderStore` reconnect on stream error (Gap REL-1):
  ```dart
  _remoteSub = _remote.watchOrdersForUser(userId, role)
      .listen(_onRemoteOrders, onError: (_) => _scheduleReconnect());
  ```

---

## 10. Sprint 6 — AI Services Activation

**Goal**: Replace mock AI services with real Cloud Run endpoints.  
**Time estimate**: 2–3 weeks.

### 10.1 AI Marketplace (`mock_ai_marketplace_service.dart` → real)

- [ ] Deploy `dawer-ai-service` on Cloud Run: `POST /ai/marketplace`
- [ ] Write `CloudRunAiMarketplaceService` implements `IAiMarketplaceService`
- [ ] Wire in `main.dart` under `useFirebase` flag
- [ ] Keep `MockAiMarketplaceService` as fallback for offline/dev

### 10.2 License/Document validation (`mock_ai_license_validation_service.dart`)

- [ ] Evaluate: can stay on-device with ML Kit if model is small (< 10 MB)
- [ ] If server-side: `POST /ai/validateLicense` on Cloud Run
- [ ] Confidence threshold guard — if `confidence < 0.75`, return `ValidationResult.manualReview`

### 10.3 Chatbot upgrade (`DawaChatbotService`)

- [ ] Current: static keyword matching
- [ ] Phase A: Keep keyword matching; add structured FAQ from Firestore `/chatbot_kb` collection
- [ ] Phase B: Wire to `POST /ai/chat` on Cloud Run (LLM-backed)
- [ ] `IAiChatService` interface already exists in domain layer — only data layer changes

### 10.4 Reward calculation unification

- [ ] `RewardService.calculate()` delegates to Cloud Run `POST /reward/calculate`
- [ ] On network failure, falls back to local calculation
- [ ] Both paths produce identical output (add unit test to verify parity)

---

## 11. Sprint 7 — Flutter Frontend Rewire & Cutover

**Goal**: All features verified on Firebase in staging; production cutover.  
**Time estimate**: 1 week + 48h observation.  
**Reference**: `MIGRATION_GCP.md` §11 + §12.

### Pre-cutover checklist

- [ ] All Sprint 0–6 milestones verified in staging with `USE_FIREBASE=true`
- [ ] Full test suite passes: `flutter test --dart-define=USE_FIREBASE=true`
- [ ] `flutter analyze` returns 0 issues
- [ ] Firestore Security Rules audited (no open read/write)
- [ ] Firebase Storage Rules audited
- [ ] Realtime Database Rules audited
- [ ] Cloud Run health checks passing (`/healthz` endpoints on both services)
- [ ] All GCP API keys restricted
- [ ] Firebase billing alerts set: $50 / $200 thresholds
- [ ] User migration completed in production (100% verified)
- [ ] Rollback APK/IPA with `USE_FIREBASE=false` staged

### Cutover sequence

```
T-48h  Final incremental data sync (orders updated since initial migration)
T-24h  Deploy Cloud Run services to production
T-12h  Enable Firebase Auth for new sign-ups (parallel to Supabase)
T-0    Production build with USE_FIREBASE=true → Play Store + App Store
T+2h   Monitor Firebase Crashlytics + Cloud Logging
T+48h  Decision: confirm or rollback
T+30d  Decommission Supabase project
```

### Files to delete after cutover

```
lib/data/services/supabase_auth_service.dart  (+ part files)
lib/data/repositories/supabase_auth_repository.dart  (+ helpers.dart)
lib/data/repositories/supabase_order_repository.dart
lib/data/repositories/supabase_file_storage_repository.dart
lib/data/services/location_publisher.dart
lib/data/services/driver_location_stream.dart
lib/data/models/order_supabase_ext.dart
lib/core/services/supabase_service.dart
lib/core/config/supabase_config.dart
```

---

## 12. Performance Optimization Guide

### 12.1 Widget rebuild reduction

**Problem**: `context.watch<AppOrderStore>()` rebuilds the entire subtree on any order change.

**Fix**: Use `context.select()` to rebuild only on the specific field that changed:
```dart
// Instead of:
final store = context.watch<DriverOrderStore>();
// Use:
final orderCount = context.select<DriverOrderStore, int>((s) => s.driverFeed.length);
```

Split large widgets into smaller `StatelessWidget` or `Consumer` scoped to the minimal data needed.

### 12.2 Order list performance

- Use `ListView.builder` (already in use) — never `ListView(children: [...])` for dynamic lists.
- Add `const` constructors to all purely-static widgets (`OrderCard`, `StatusChip`, etc.).
- Cache `Order.toDisplayString()` computations — don't compute in `build()`.
- Add `RepaintBoundary` around the map widget in `order_tracking_card.dart` — maps repaint every GPS update; this isolates the repaint to the map subtree only.

### 12.3 Image loading

- `cached_network_image` already used — ensure `maxHeightDiskCache` and `maxWidthDiskCache` are set:
  ```dart
  CachedNetworkImage(
    imageUrl: url,
    maxHeightDiskCache: 400,
    maxWidthDiskCache: 400,
    // prevents disk bloat on profile photos
  )
  ```
- Use `ResizeImage` for thumbnails in list cards.

### 12.4 Firestore query performance

- All required composite indexes declared in `MIGRATION_GCP.md` §3.3 — deploy before launch.
- The driver two-query merge uses `StreamZip` — deduplicate by `order.id` (use `LinkedHashMap` keyed by id, preserving insertion order):
  ```dart
  .map((lists) {
    final seen = <String, Order>{};
    for (final o in [...lists[0], ...lists[1]]) seen[o.id] = o;
    return seen.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  })
  ```

### 12.5 App startup time

Current bottleneck: `SupabaseService.initialize()` is awaited before `runApp()`.

Target: move heavy init off the main thread cold path:
```dart
// main.dart — fast path:
unawaited(SupabaseService.initialize(...)); // don't await
runApp(DawerApp(...));

// SplashView: wait for init, then route
await SupabaseService.initComplete; // completer-based
```

This makes the app visually responsive immediately while init completes in background.

### 12.6 Build sizes

- Run `flutter build apk --analyze-size` before each release.
- Ensure `google_mlkit_image_labeling` only bundles models needed (do not bundle all label models).
- Use `--split-per-abi` for Android APK distribution (reduces per-device download ~40%).

### 12.7 Animation performance

- All animations use `const Duration` — avoid allocating in build.
- `order_status_timeline.dart` — use `AnimatedContainer` over manual `TweenAnimationBuilder` where possible.
- Profile with Flutter DevTools → Performance overlay before submitting any animation PR.

---

## 13. New Features Backlog

Features not yet in the codebase, ordered by user impact.

| # | Feature | Role | Sprint | Notes |
|---|---|---|---|---|
| F1 | Push notifications on order status change | All | 5 | Requires FCM + go_router deep-link |
| F2 | Live ETA countdown on tracking card | Supplier | 4 | Distance Matrix API |
| F3 | Route polyline on tracking map | Supplier | 4 | Directions API |
| F4 | Pin-drop location picker at order creation | Supplier | 4 | Replaces hardcoded address |
| F5 | Offline order submission queue | All | 5 | connectivity_plus + in-memory queue |
| F6 | Arabic address autocomplete (Places API) | Supplier | 4 | At order creation |
| F7 | Driver rating after order completion | Supplier | 6 | `rate_driver_sheet.dart` already exists; needs `IOrderRepository.rateDriver()` |
| F8 | Reward points history screen | Supplier | 6 | `rewards_view.dart` exists; needs real data from Firestore `/reward_transactions` |
| F9 | Real AI marketplace suggestions | All | 6 | Replace `MockAiMarketplaceService` |
| F10 | Driver earnings dashboard | Driver | 6 | Aggregate Firestore completed orders by driverId |
| F11 | RecyclingCo analytics tab | RecyclingCo | 7 | Order volume, waste types processed, revenue |
| F12 | Phone OTP (Twilio) | All | Post-cutover | Keep email OTP as primary; phone as alternate |
| F13 | In-app chatbot upgrade (LLM) | All | Post-cutover | Phase B of Sprint 6 chatbot work |
| F14 | Pagination for large order lists | All | Post-cutover | Firestore cursor pagination when > 1000 orders |

---

## 14. File Responsibility Map (Target State)

```
lib/
├── main.dart                           Bootstrap + DI wiring (feature flag)
├── firebase_options.dart               Generated by flutterfire configure
├── core/
│   ├── config/
│   │   ├── env.dart                    Compile-time env constants (NO fallback values)
│   │   └── firebase_config.dart        Firebase options accessor (NEW)
│   ├── result/result.dart              AppResult<T>, fold()
│   ├── state/view_state.dart           ViewState<T> sealed class (NEW)
│   ├── routing/app_router.dart         go_router definition + auth guard (NEW)
│   ├── services/
│   │   ├── app_lang_notifier.dart
│   │   ├── app_theme_notifier.dart
│   │   ├── connectivity_notifier.dart  ConnectivityNotifier (NEW)
│   │   └── map_launcher.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_tokens.dart
│   └── utils/
│       ├── app_logger.dart             Structured logger replacing debugPrint (NEW)
│       ├── arabic_text_utils.dart
│       ├── date_formatter.dart
│       └── error_key_resolver.dart
├── domain/
│   ├── entities/auth_session.dart
│   ├── failures/app_failure.dart
│   ├── repositories/
│   │   ├── i_auth_repository.dart
│   │   ├── i_order_repository.dart
│   │   └── i_file_storage_repository.dart
│   ├── requests/
│   │   ├── create_pickup_request.dart
│   │   └── sign_up_request.dart
│   └── services/
│       ├── i_location_publisher.dart
│       ├── i_ai_marketplace_service.dart
│       ├── i_ai_chat_service.dart      (NEW — for chatbot upgrade)
│       └── i_geocoding_service.dart    (NEW — for address resolution)
├── data/
│   ├── local/local_store.dart
│   ├── mock/
│   │   ├── order_mock_data.dart
│   │   ├── order_seed_market_items.dart
│   │   └── order_seed_orders.dart
│   ├── models/
│   │   ├── order.dart
│   │   ├── order_enums.dart
│   │   ├── order_copy_with.dart
│   │   ├── order_json.dart
│   │   ├── order_labels.dart
│   │   ├── order_arabic_labels.dart
│   │   ├── order_supabase_ext.dart     (DELETE after cutover)
│   │   ├── order_firestore_ext.dart    (NEW — replaces supabase_ext)
│   │   ├── user.dart
│   │   ├── user_role.dart
│   │   ├── reward_breakdown.dart
│   │   └── reward_transaction.dart
│   ├── repositories/
│   │   ├── mock_auth_repository.dart
│   │   ├── no_op_order_repository.dart
│   │   ├── supabase_auth_repository.dart       (DELETE after cutover)
│   │   ├── supabase_auth_repository/
│   │   │   └── helpers.dart                   (DELETE after cutover)
│   │   ├── supabase_order_repository.dart      (DELETE after cutover)
│   │   ├── supabase_file_storage_repository.dart (DELETE after cutover)
│   │   ├── firebase_auth_repository.dart       (NEW)
│   │   ├── firestore_order_repository.dart     (NEW)
│   │   └── firebase_file_storage_repository.dart (NEW)
│   └── services/
│       ├── app_order_store.dart                Central order state (ChangeNotifier)
│       ├── app_order_store/
│       │   ├── driver_actions.dart
│       │   ├── supplier_actions.dart
│       │   ├── collection_job_actions.dart
│       │   ├── collection_sale_actions.dart
│       │   └── marketplace_actions.dart
│       ├── driver_order_store.dart
│       ├── supplier_order_store.dart
│       ├── recycling_order_store.dart
│       ├── supabase_auth_service.dart          (DELETE after cutover)
│       ├── supabase_auth_service/              (DELETE after cutover)
│       ├── firebase_auth_service.dart          (NEW)
│       ├── firebase_auth_service/              (NEW — auth_helpers + signup_helpers)
│       ├── user_signup_service.dart
│       ├── reward_service.dart                 (keep as offline fallback)
│       ├── fee_calculator.dart
│       ├── geocoding_service.dart              (NEW)
│       ├── location_publisher.dart             (DELETE after cutover)
│       ├── firebase_location_publisher.dart    (NEW)
│       ├── driver_location_stream.dart         (DELETE after cutover)
│       └── firebase_driver_location_stream.dart (NEW)
└── ui/
    ├── common/
    │   ├── map/
    │   │   ├── live_tracking_map_view.dart
    │   │   ├── location_picker_panel.dart
    │   │   ├── location_picker_screen.dart
    │   │   ├── pickup_map_view.dart
    │   │   ├── route_map_placeholder.dart
    │   │   └── pickup_location_picker_view.dart (NEW — pin-drop for order creation)
    │   ├── ai_shimmer_loader.dart
    │   ├── animated_status_text.dart
    │   ├── app_nav_item.dart
    │   ├── filter_chip_row.dart
    │   ├── lang_picker_sheet.dart
    │   ├── orders_empty_state.dart
    │   ├── offline_banner.dart                  (NEW — shown when ConnectivityNotifier.isOnline == false)
    │   └── theme_mode_sheet.dart
    └── features/
        ├── auth/               (unchanged structure)
        ├── splash/             (add version guard + Firebase init wait)
        ├── chatbot/            (add IAiChatService when ready)
        └── home/
            ├── [driver|supplier|recycling]/  (unchanged structure; VMs adopt ViewState<T>)
            └── shared/         (unchanged structure)
```

---

## 15. Coding Rules & Patterns

### File size rule
Every `.dart` file must stay ≤ 200 lines. Use `part`/`part of` for same-class splits, separate files for separate concepts.

### Naming conventions
| Thing | Convention | Example |
|---|---|---|
| Interfaces | `I` prefix | `IOrderRepository` |
| Firebase implementations | `Firebase`/`Firestore` prefix | `FirebaseAuthRepository` |
| Supabase implementations | `Supabase` prefix | `SupabaseOrderRepository` |
| ViewModels | `<Screen>ViewModel` | `DriverHomeViewModel` |
| Views | `<Screen>View` | `DriverHomeView` |
| Stores | `<Domain>Store` | `AppOrderStore` |

### ViewModel pattern
```dart
// Always:
sealed class YourViewState { ... }  // or use generic ViewState<T>

class YourViewModel extends ChangeNotifier {
  YourViewModel(this._repo);
  final IYourRepository _repo;
  
  ViewState<YourData> _state = const Idle();
  ViewState<YourData> get state => _state;
  
  Future<void> load() async {
    _state = const Loading(); notifyListeners();
    final result = await _repo.fetchData();
    _state = result.fold(onSuccess: Loaded.new, onFailure: Failed.new);
    notifyListeners();
  }
}
```

### Error messages
- All user-facing error messages are Arabic strings from `.arb` localization files.
- `AppFailure` subclasses map to localization keys via `error_key_resolver.dart`.
- Never `showSnackBar(SnackBar(content: Text('Error: $e')))` in production.

### Testing
- Unit tests: no Flutter imports in ViewModel tests. Use `fake_cloud_firestore` + `firebase_auth_mocks`.
- One test file per repository/service file, same directory structure under `test/`.
- Required test coverage before merging any Sprint 2+ PR:
  - `FirebaseAuthRepository` — sign-up, sign-in, logout, session rehydration
  - `FirestoreOrderRepository` — watchOrdersForUser (all 3 roles), insertOrder, markAccepted
  - `FirebaseFileStorageRepository` — upload profile photo, upload identity doc, signed URL

---

## 16. Checklist Tracker

### Sprint 0 — Critical Security
- [ ] SEC-1: Remove hardcoded Supabase fallback from `main.dart`
- [ ] G1: Wire `LoginViewModel` to live `IAuthRepository`
- [ ] G12: Surface init failure as error screen
- [ ] SEC-3: Document Maps API key restriction

### Sprint 1 — Foundation
- [ ] Add `go_router` + `app_router.dart`
- [ ] Replace all imperative navigation calls
- [ ] Add `ViewState<T>` to `lib/core/state/`
- [ ] Update all ViewModels to use `ViewState<T>`
- [ ] Add `app_logger.dart`, replace all `debugPrint`
- [ ] Add `connectivity_plus`

### Sprint 2 — Firebase Auth + Firestore
- [ ] Firebase project setup (`dawer-prod` + `dawer-staging`)
- [ ] `flutterfire configure` + add Firebase packages
- [ ] `FirebaseAuthService` + part files
- [ ] `FirebaseAuthRepository`
- [ ] `FirestoreOrderRepository` (with fixed driver stream)
- [ ] `order_firestore_ext.dart`
- [ ] Firestore Security Rules deployed + tested
- [ ] Feature flag in `main.dart`
- [ ] User migration script (Node.js)
- [ ] `LocalStore` version guard

### Sprint 3 — Storage + Location + Cloud Run
- [ ] `FirebaseFileStorageRepository`
- [ ] Firebase Storage Security Rules
- [ ] `FirebaseLocationPublisher`
- [ ] `FirebaseDriverLocationStream`
- [ ] Realtime Database Security Rules
- [ ] `dawer-auth-service` deployed on Cloud Run
- [ ] `dawer-reward-service` deployed on Cloud Run

### Sprint 4 — Maps
- [ ] Maps API keys configured (Android + iOS)
- [ ] `geocoding_service.dart`
- [ ] `pickup_location_picker_view.dart`
- [ ] Live tracking polyline (Directions API)
- [ ] ETA calculation (Distance Matrix API)
- [ ] `order.eta` replaced with live `etaMinutes`

### Sprint 5 — Notifications + Offline
- [ ] Firestore Cloud Function: status change → FCM
- [ ] Flutter FCM setup (foreground + background)
- [ ] go_router deep-link for notification tap
- [ ] `connectivity_notifier.dart`
- [ ] `AppOrderStore` write-retry queue
- [ ] `offline_banner.dart` widget
- [ ] `AppOrderStore._remoteSub` onError reconnect

### Sprint 6 — AI
- [ ] `dawer-ai-service` Cloud Run deployed
- [ ] `CloudRunAiMarketplaceService` wired under feature flag
- [ ] License validation: on-device or Cloud Run decision made
- [ ] Chatbot: Firestore FAQ knowledge base
- [ ] `RewardService` delegates to Cloud Run with local fallback

### Sprint 7 — Cutover
- [ ] All pre-cutover checklist items verified
- [ ] Production data migration completed
- [ ] Production build published with `USE_FIREBASE=true`
- [ ] 48h observation window clear
- [ ] Supabase files deleted from codebase
- [ ] Supabase project decommissioned (T+30d)

---

*Dawer Evolution Plan v1.0 — aligns with ARCHITECTURE.md v1.0 + MIGRATION_GCP.md v1.0*  
*Next review: after Sprint 0 completion*
