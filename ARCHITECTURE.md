# Dawer (دوّر) — Architecture & System Design Plan
> Version 1.0 · Based on codebase analysis at `lib/` HEAD

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Current State Assessment](#2-current-state-assessment)
3. [Component Architecture](#3-component-architecture)
4. [Data Flows](#4-data-flows)
5. [System Design Decisions](#5-system-design-decisions)
6. [Technology Stack](#6-technology-stack)
7. [Security Model](#7-security-model)
8. [Reliability & Resilience](#8-reliability--resilience)
9. [Observability](#9-observability)
10. [Migration Roadmap](#10-migration-roadmap)
11. [Risk Register](#11-risk-register)
12. [Prioritized Backlog](#12-prioritized-backlog)

---

## 1. Executive Summary

Dawer is a three-sided waste-recycling marketplace for Jordan connecting **Suppliers** (individuals/businesses generating recyclable waste), **Drivers** (collectors/haulers), and **Recycling Companies** (processors/buyers). The Flutter app (iOS + Android) communicates with a Supabase backend that provides PostgreSQL, Auth, Storage, Realtime subscriptions, and Edge Functions.

### Recommended Target Architecture

**Pattern**: Clean Architecture (already 80% in place) with a strict boundary between Domain, Data, and UI layers.

**Key decisions** (justified in detail below):

| Decision | Choice | Reason |
|---|---|---|
| State management | Provider + ChangeNotifier (current) → add `AsyncValue` pattern | Fits team skill set; low migration cost |
| Navigation | Introduce `go_router` | Declarative deep-linking, auth guards |
| Remote error reporting | Sentry Flutter SDK | Already planned in comments |
| Push notifications | Supabase + Firebase Cloud Messaging | No new backend; Supabase triggers FCM |
| Pagination | Supabase cursor pagination on driver stream | Fixes current full-stream issue |
| Offline queue | In-memory retry queue in `AppOrderStore` | Simple, no extra dependency |
| AI services | Supabase Edge Function + on-device ML Kit | Current mocks replaced incrementally |

---

## 2. Current State Assessment

### 2.1 What Is Working Well

- **Clean three-layer separation** — `lib/domain`, `lib/data`, `lib/ui` are clearly delineated with no leakage.
- **Interface-driven data layer** — `IAuthRepository`, `IOrderRepository`, `IFileStorageRepository` are all abstract interfaces. Mock implementations exist for every contract, enabling unit testing without a live Supabase connection.
- **`Result<T,E>` error propagation** — `AppResult<T>` / `fold(onSuccess:, onFailure:)` pattern is consistently applied across repositories and services, eliminating silent swallowed errors.
- **Role-scoped store proxies** — `DriverOrderStore`, `SupplierOrderStore`, `RecyclingOrderStore` wrap `AppOrderStore` and give each role a minimal surface area without duplicating state.
- **Realtime order stream** — `SupabaseOrderRepository.watchOrdersForUser` uses Supabase `.stream()` with role-scoped equality filters for supplier and recyclingCo; driver falls back to full stream pending pagination.
- **GPS tracking** — `LocationPublisher` (singleton) upserts to `driver_locations` with a foreground notification on Android; `DriverLocationStream` subscribes via Realtime and exposes `Stream<LatLng>`.
- **Modular `Order` model** — split into `order.dart` (core fields), `order_enums.dart`, `order_copy_with.dart`, `order_json.dart`, `order_supabase_ext.dart` — each file is ≤ 200 lines.
- **`LocalStore`** — thin `SharedPreferences` wrapper with typed getters/setters. All persistence goes through a single point.
- **Test coverage** — unit tests for `AppOrderStore`, collection sale lifecycle, reward service, and auth sign-up inputs.

### 2.2 Identified Gaps (Priority-Ordered)

| # | Gap | Impact | Effort |
|---|---|---|---|
| G1 | `LoginViewModel` uses `MockAuthRepository` path with a fake 1.2s delay | Users cannot log in against real backend | Low |
| G2 | Driver order stream fetches the full `orders` table (no server-side filter for drivers) | Scalability & RLS bypass risk | Medium |
| G3 | No router / navigation system (`go_router` or equivalent) | No deep-linking, no auth guards, ad-hoc `Navigator.push` throughout | Medium |
| G4 | No push notifications | Users unaware of order state changes when app is backgrounded | Medium |
| G5 | No error observability (Sentry planned, not wired) | Silent production failures invisible | Medium |
| G6 | `LocationPublisher` calls `Supabase.instance.client` directly (not injected) | Untestable, tightly coupled to global | Low |
| G7 | All AI services (`mock_ai_*`) are stubs with no real ML backend path | Advertised feature non-functional | High |
| G8 | `RewardService` calculates locally; the `calculate_reward` edge function is unreferenced | Divergence risk between client & server calculation | Low |
| G9 | No offline write-queue; mutations fail silently on network loss | Unreliable UX on poor connections (Jordan mobile networks) | Medium |
| G10 | Phone OTP (Twilio) deferred; only email OTP is live | Limits user acquisition for less tech-savvy users | High |
| G11 | `LocalStore` stores raw `Map<String, dynamic>` for orders — no typed model round-trip validation | Data corruption risk after model schema changes | Low |
| G12 | `SupabaseService` swallows init exceptions silently | App can enter a degraded state with no user feedback | Low |

---

## 3. Component Architecture

### 3.1 Layer Diagram

```
┌─────────────────────────────────────────────────────────┐
│  UI Layer  (lib/ui/)                                    │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  Auth Views │  │  Home Views  │  │  Chatbot View │  │
│  │  + VMs      │  │  (per role)  │  │  + ViewModel  │  │
│  └─────┬───────┘  └──────┬───────┘  └───────┬───────┘  │
│        │  ChangeNotifier / Provider           │          │
├────────┼─────────────────┼───────────────────┼──────────┤
│  Domain Layer  (lib/domain/)                            │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Interfaces: IAuthRepository, IOrderRepository  │    │
│  │              IFileStorageRepository              │    │
│  │  Entities:   AuthSession                         │    │
│  │  Failures:   AppFailure sealed hierarchy         │    │
│  │  Requests:   SignUpRequest, CreatePickupRequest  │    │
│  └─────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────┤
│  Data Layer  (lib/data/)                                │
│  ┌────────────────┐  ┌────────────────┐                 │
│  │ AppOrderStore  │  │ SupabaseAuth   │                 │
│  │ (ChangeNotify) │  │ Repository     │                 │
│  │ + 3 role proxy │  │ + AuthService  │                 │
│  │   stores       │  │ + SignUpSvc    │                 │
│  └──────┬─────────┘  └──────┬─────────┘                │
│         │                   │                           │
│  ┌──────▼─────────────────────────────────────────┐    │
│  │  Supabase Client (supabase_flutter ^2.8.4)     │    │
│  │  LocalStore (SharedPreferences)                 │    │
│  └────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────┤
│  Core  (lib/core/)                                      │
│  Result<T,E> · AppFailure · SupabaseService             │
│  AppThemeNotifier · AppLangNotifier · LocalStore        │
└─────────────────────────────────────────────────────────┘
```

### 3.2 Order Store Composition

```
AppOrderStore (ChangeNotifier)  ← single source of truth for all orders
  part driver_actions.dart       → driverFeed, acceptOrder, completeOrder, …
  part supplier_actions.dart     → supplierOrdersFor, submitPickupRequest, …
  part collection_job_actions.dart → createCollectionJob, deleteCollectionJob, …
  part collection_sale_actions.dart → createCollectionSale, markInTransit, …
  part marketplace_actions.dart  → marketItems, purchaseMarketItem, …

DriverOrderStore    ──┐
SupplierOrderStore  ──┼── ProxyProvider wrapping AppOrderStore
RecyclingOrderStore ──┘   (each role gets only its slice of the API)
```

### 3.3 Auth Component Map

```
LoginView / SignUpView / OtpView
        │ ViewModel calls
        ▼
IAuthRepository ◄──── SupabaseAuthRepository (live)
                 ◄──── MockAuthRepository (test / no-backend)
        │
        ▼
UserSignUpService ──► SupabaseAuthService
                         ├── supabase_auth_service/auth_helpers.dart
                         └── supabase_auth_service/signup_helpers.dart
```

### 3.4 AI / Chatbot Component Map

```
DawaChatView ──► DawaChatViewModel
                    ├── DawaChatbotService  (keyword lookup, static)
                    └── DawaScanHandler    (ML Kit image classification)
                            └── google_mlkit_image_labeling

[Future] Live AI path:
  DawaChatViewModel ──► IAiChatService
                              └── SupabaseEdgeFunctionAiService
                                    └── POST /functions/v1/dawa-ai
```

### 3.5 Real-Time Data Flow

```
Supabase DB (orders table)
      │  Realtime channel
      ▼
SupabaseOrderRepository.watchOrdersForUser(userId, role)
      │  Stream<List<Order>>
      ▼
AppOrderStore._remoteSub (StreamSubscription)
      │  notifyListeners()
      ▼
DriverOrderStore / SupplierOrderStore / RecyclingOrderStore
      │  notifyListeners()
      ▼
Role-specific Home View  (context.watch<DriverOrderStore>())
```

---

## 4. Data Flows

### 4.1 Supplier Creates Pickup Request

```
SupplierHomeViewModel.submitPickupRequest(CreatePickupRequest)
  → SupplierOrderStore.submitPickupRequest()
    → AppOrderStore.submitPickupRequest()          [in-memory state update]
      → IOrderRepository.insertOrder(order)        [remote write]
        → SupabaseOrderRepository: INSERT INTO orders
          → Supabase Realtime broadcasts row change
            → AppOrderStore._remoteSub receives update
              → notifyListeners() → UI refreshed
```

### 4.2 Driver Accepts Order

```
DriverHomeViewModel.acceptOrder(orderId, driver)
  → DriverOrderStore.acceptOrder()
    → AppOrderStore.acceptOrder()                  [optimistic in-memory update]
      → IOrderRepository.markAccepted(orderId)     [remote write: sets driver_id, accepted_at]
        → LocationPublisher.start(orderId)         [GPS stream begins]
```

### 4.3 Order Status State Machine

```
pickupRequest:
  pending ──accept──► accepted ──markInTransit──► inTransit ──complete──► completed
          ◄──────────────────────────── cancel ──────────────────────────

collectionJob:
  pending ──claim──► accepted(collectionSale created)
  pending ──edit──► pending
  pending ──delete──► [removed]

collectionSale:
  accepted ──markInTransit──► inTransit ──completeCollectionSale──► completed
           ◄────────────────────── cancel (guard: not inTransit/completed) ─────
```

### 4.4 Authentication Flow

```
SplashView ──► rehydrate from LocalStore
  if session found ──► HomeRouter (role-based dispatch)
  else ──► LoginView

LoginView ──► requestEmailOtp(email)          [live: Supabase OTP email]
          ──► verifyEmailOtpAndGetProfile()   [live: returns profile row]
          ──► LocalStore.setCurrentUser*      [session cache]
          ──► HomeRouter
```

### 4.5 GPS Tracking Flow

```
Order accepted
  → LocationPublisher.start(orderId)
    → Geolocator.getPositionStream() [10m distance filter]
      → upsert driver_locations {driver_id, order_id, lat, lng}

Supplier tracking view:
  → DriverLocationStream.forOrder(orderId)
    → initial SELECT driver_locations WHERE order_id = ?
    → Realtime channel: driver-tracking-{orderId}
      → Stream<LatLng> → Google Maps marker update

Order completed/cancelled:
  → LocationPublisher.stop()
    → DELETE driver_locations WHERE driver_id = ? AND order_id = ?
```

---

## 5. System Design Decisions

### 5.1 State Management

**Decision**: Retain Provider + ChangeNotifier, augment with explicit loading/error state per ViewModel.

**Rationale**: The current `AppOrderStore` → ProxyProvider → role-specific stores pattern is well-structured and test-friendly. Migrating to Riverpod or BLoC would be high-effort with marginal benefit at current scale. The key improvement is adding a consistent `ViewModelState` value type so UI can distinguish `idle | loading | success | failure` without ad-hoc booleans.

```dart
// Recommended addition to lib/core/
sealed class ViewState<T> { ... }
final class Idle<T> extends ViewState<T> { }
final class Loading<T> extends ViewState<T> { }
final class Loaded<T> extends ViewState<T> { final T data; }
final class Failed<T> extends ViewState<T> { final AppFailure failure; }
```

### 5.2 Navigation

**Decision**: Adopt `go_router` for all navigation.

**Rationale**:
- Auth guards — redirect unauthenticated users to `/login` without ViewModels needing to know about navigation.
- Deep-linking — required for push notification tap-to-open.
- Role-based shells — `ShellRoute` per role replaces the manual `HomeRouter` switch.
- Current `HomeRouter` switch stays but becomes one `GoRoute`.

### 5.3 Data Model: Single `Order` vs. Sub-types

**Decision**: Keep the single `Order` class for now; introduce a discriminated union pattern only when a 4th order type is added.

**Rationale**: The `OrderType` enum (`pickupRequest | collectionJob | collectionSale | marketplaceListing`) already discriminates behavior. Many fields are genuinely shared (`id`, `status`, `wasteTypes`, timestamps, location). A polymorphic hierarchy would require breaking changes to `IOrderRepository` and Supabase JSON mapping. The current `order_enums.dart` + `order_copy_with.dart` factoring keeps the model manageable.

**Future trigger**: If a 4th type with > 10 unique fields is added, migrate to sealed subclasses.

### 5.4 Backend Scope

**Decision**: Keep all business logic in Flutter/Dart; push only auth and storage to Supabase. Use Edge Functions for AI and reward calculations only.

**Rationale**: The current architecture puts order state machine logic in `AppOrderStore` Dart code, which is unit-testable without a live server. This is correct. Supabase RLS should enforce write authorization but not encode business rules.

### 5.5 Offline Strategy

**Decision**: Implement a lightweight write-retry queue in `AppOrderStore`.

**Rationale**: Jordan mobile network reliability varies. The current code has no offline handling — a failed `insertOrder` silently discards the user's pickup request. The fix is an in-memory queue that retries on reconnection, not a full offline-first DB.

```
On write failure (NetworkFailure):
  → Enqueue { orderId, operation, payload }
  → Show "حفظ مؤقت — سيُرسل عند الاتصال" banner
  → Connectivity check via dart:io socket poll
  → On reconnect: replay queue
  → Clear queue, notify
```

---

## 6. Technology Stack

All recommendations stay within the current dependency set unless marked **[NEW]**.

| Layer | Current | Recommended | Notes |
|---|---|---|---|
| Framework | Flutter 3.x / Dart ^3.8.0 | No change | ✅ |
| State management | Provider ^6.1.5 + ChangeNotifier | No change + `ViewState<T>` pattern | ✅ |
| Navigation | Ad-hoc Navigator | **[NEW]** `go_router ^14` | Adds deep-linking + auth guards |
| Backend | Supabase ^2.8.4 | No change | ✅ |
| Local cache | SharedPreferences ^2.5.3 via LocalStore | No change | ✅ |
| Image | cached_network_image + image_picker | No change | ✅ |
| Maps | google_maps_flutter ^2.10 | No change | ✅ |
| Location | geolocator ^13.0.2 | No change | ✅ |
| ML Kit | google_mlkit_image_labeling ^0.13 | No change | ✅ |
| Error monitoring | (none) | **[NEW]** `sentry_flutter ^8` | Low effort — already planned |
| Push notifications | (none) | **[NEW]** `firebase_messaging ^15` | Required for order state changes |
| Connectivity | (none) | **[NEW]** `connectivity_plus ^6` | Required for offline queue |
| Phone OTP | (deferred) | **[FUTURE]** Twilio via Supabase Auth | Keep email OTP as primary |

---

## 7. Security Model

### 7.1 Credentials

- ✅ `SUPABASE_URL` and `SUPABASE_ANON_KEY` are compile-time env vars (`--dart-define`), not hardcoded in source.
- ⚠️ `main.dart` falls back to hardcoded values when env vars are missing — **remove the fallback values before any production release**. Use an empty string that forces the app to show an error.

### 7.2 Row-Level Security (RLS)

All `orders` table writes must be protected by Supabase RLS policies. The current codebase assumes RLS is in place but does not document it. Recommended policies:

| Table | Operation | Policy |
|---|---|---|
| orders | INSERT | `auth.uid() IS NOT NULL` |
| orders | SELECT | supplier: `supplier_id = auth.uid()`; driver: `status != cancelled`; recyclingCo: `company_id = auth.uid()` |
| orders | UPDATE | Only fields the role owns (e.g. driver can only update `driver_id`, `status`, timestamps) |
| driver_locations | INSERT/UPDATE | `driver_id = auth.uid()` |
| driver_locations | SELECT | driver of that order OR the order's supplier |
| profiles | SELECT | `id = auth.uid()` |
| profiles | UPDATE | `id = auth.uid()` |

### 7.3 File Storage

- `SupabaseFileStorageRepository` uploads profile photos and identity documents.
- Storage bucket policies must restrict: (a) upload only to `profiles/{auth.uid()}/`, (b) read only by the authenticated user or verified admin.

### 7.4 Auth

- Email OTP is the live auth path. Password-based sign-in (`signInWithEmail`) is implemented but the UI flow is OTP-first.
- OTP codes must have a short TTL (Supabase default is 1 hour — reduce to 10 minutes in project settings).
- Password reset flow is implemented via 6-digit recovery OTP.
- The `UserRole` is stored in the `profiles` table and read back at session rehydration. Client-side role is used for UI routing only; all write authorization must be enforced server-side by RLS.

### 7.5 Transport

- All Supabase traffic is over HTTPS (SDK default).
- Google Maps API key must be restricted to the app's package name + SHA-1 in the Google Cloud Console.

---

## 8. Reliability & Resilience

### 8.1 Error Propagation

The `AppResult<T>` / `Failure` pattern is correctly used throughout repositories. The gap is in ViewModels — some do not expose `AppFailure` to the UI, leaving users without feedback on failures.

**Standard ViewModel contract to enforce**:
```
void onAction() {
  _state = Loading();
  notifyListeners();
  final result = await _repo.doSomething();
  result.fold(
    onSuccess: (v) { _state = Loaded(v); },
    onFailure: (f) { _state = Failed(f); },
  );
  notifyListeners();
}
```

### 8.2 Supabase Realtime Reconnection

Supabase Realtime automatically reconnects on network loss. `AppOrderStore` must handle the case where the `StreamSubscription` fires an error event and attempt to re-subscribe.

```dart
_remoteSub = _remote.watchOrdersForUser(userId, role)
    .listen(
      _onRemoteOrders,
      onError: (e) => _scheduleReconnect(),
    );
```

### 8.3 LocationPublisher Resilience

`LocationPublisher` currently swallows upsert errors silently (`debugPrint` only). On `NetworkFailure`, it should buffer the last position and retry the upsert when connectivity is restored, rather than dropping tracking updates silently.

### 8.4 Initialization Guard

`SupabaseService.initialize` catches all exceptions and sets `_isInitialized = false` silently. The app then runs in a degraded state (falls through to `MockAuthRepository`). This is acceptable for development but must surface a user-visible error screen in release builds.

### 8.5 Order ID Collision

Orders use client-generated IDs (format `ORD-XXXXX` or UUID). Supabase `orders.id` must be a `uuid` column with `DEFAULT gen_random_uuid()` and a `NOT NULL` constraint. Client-generated IDs should be reviewed to ensure they are UUID v4, not sequential or guessable.

---

## 9. Observability

### 9.1 Current State

- Only `debugPrint` statements exist (e.g., in `LocationPublisher`, `SupabaseService`).
- No error aggregation, no performance tracing, no user analytics.

### 9.2 Recommended Stack

**Error Monitoring**: Sentry Flutter SDK (`sentry_flutter`)
- Captures unhandled Flutter + Dart exceptions.
- Wire in `main()` as `SentryFlutter.init(...)` wrapping `runApp`.
- Map `AppFailure` subtypes to Sentry breadcrumbs for context.

**Performance**: Sentry performance tracing or Firebase Performance (if already using FCM)
- Trace order submission → confirmation latency.
- Trace realtime subscription establishment time.

**Analytics**: Firebase Analytics (lightweight)
- Track order creation per role.
- Track funnel drop-off in sign-up flow.
- No PII in events.

**Logging Convention**:
```dart
// Replace ad-hoc debugPrint with structured logger:
class Log {
  static void info(String tag, String msg) { ... }
  static void warn(String tag, String msg) { ... }
  static void error(String tag, Object err, [StackTrace? st]) { ... }
}
```

---

## 10. Migration Roadmap

### Phase 0 — Immediate Fixes (< 1 week, no breaking changes)
| Task | File(s) | Notes |
|---|---|---|
| Remove hardcoded Supabase credentials fallback | `lib/main.dart:42–43` | Security critical |
| Wire `LoginViewModel` to live `IAuthRepository` | `lib/ui/features/auth/viewmodels/login_viewmodel.dart` | G1 |
| Surface Supabase init failure as error screen | `lib/core/services/supabase_service.dart` | G12 |
| Add `connectivity_plus` and expose `AppOrderStore.retryQueue` | new `lib/core/services/connectivity_notifier.dart` | G9 |

### Phase 1 — Navigation & UX (1–2 weeks)
| Task | Notes |
|---|---|
| Add `go_router` with auth guard | Replace ad-hoc `Navigator.push` |
| `HomeRouter` becomes a `GoRoute` child | Minimal refactor |
| Deep-link support for order detail | Required for push notifications |
| Add `ViewState<T>` to all ViewModels | Consistent loading/error UX |

### Phase 2 — Reliability (2–3 weeks)
| Task | Notes |
|---|---|
| Add `sentry_flutter` — capture unhandled errors | Wire Sentry DSN via `--dart-define` |
| Server-side filter for driver order stream | Add Supabase RLS + OR filter by `driver_id`/`status` |
| `LocationPublisher`: inject `SupabaseClient`; buffer on network loss | G6 |
| Audit and document all RLS policies | Security gate for production launch |
| Write integration tests for auth flow | `test/integration/` is currently empty |

### Phase 3 — Push Notifications (3–4 weeks)
| Task | Notes |
|---|---|
| Add `firebase_messaging` | iOS + Android setup |
| Supabase Postgres trigger → Edge Function → FCM | On order status change, notify relevant user |
| Notification tap → `go_router` deep-link to order detail | Requires Phase 1 |
| Foreground notification handling in `AppOrderStore` | Merge with realtime; deduplicate |

### Phase 4 — AI Services (4–6 weeks)
| Task | Notes |
|---|---|
| Replace `mock_ai_marketplace_service.dart` with real Edge Function | `POST /functions/v1/ai-marketplace` |
| Replace `mock_ai_license_validation_service.dart` with real validation | Can stay on-device if model is small |
| `RewardService.calculate()` → delegate to `calculate_reward` Edge Function | Unify client/server calc logic; keep local as fallback |
| Chatbot: add `IAiChatService` Supabase implementation | Replace static keyword matching |

### Phase 5 — Phone OTP (6–8 weeks)
| Task | Notes |
|---|---|
| Twilio integration via Supabase Auth (Phone provider) | Update Supabase project settings |
| Update `IAuthRepository.requestOtp` / `verifyOtp` | Already defined; only data layer changes |
| Update sign-up views to support phone-primary flow | |

---

## 11. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Hardcoded Supabase anon key leaks in binary | High (currently present) | High | Remove fallback in `main.dart` immediately (Phase 0) |
| Missing RLS allows cross-user data access | Medium | Critical | Audit + document RLS before production release |
| Driver stream ingests entire `orders` table | High (will grow) | Medium | Add server-side OR filter in Phase 2 |
| `LocalStore` order JSON diverges from `Order` schema | Medium | Medium | Add round-trip validation test; version migration logic |
| ML Kit label mismatch causes wrong waste classification | Medium | Medium | Add confidence threshold guard; fallback to keyword match |
| Supabase Realtime drops connection, orders go stale | Medium | High | Implement `onError` reconnect in `AppOrderStore` |
| `LocationPublisher` accumulates stale rows on crash | Low | Low | Add periodic cleanup job or TTL trigger on `driver_locations` |
| Google Maps API key not restricted to app | High (common oversight) | Medium | Restrict in Google Cloud Console before release |
| Phone OTP (Twilio) cost overrun | Low | Medium | Rate-limit OTP requests; add CAPTCHA to sign-up |
| Order ID collision for client-generated IDs | Low | High | Enforce UUID v4 generation; add `UNIQUE` constraint |

---

## 12. Prioritized Backlog

### Critical (must be done before any production traffic)
- [ ] **SEC-1** Remove hardcoded Supabase credentials from `main.dart`
- [ ] **SEC-2** Audit and enforce RLS policies on `orders`, `profiles`, `driver_locations`, storage buckets
- [ ] **SEC-3** Restrict Google Maps API key to app package + SHA-1

### High (Sprint 1)
- [ ] **AUTH-1** Wire `LoginViewModel` to live `IAuthRepository` (remove mock delay)
- [ ] **OBS-1** Add `sentry_flutter` and capture unhandled exceptions
- [ ] **NAV-1** Introduce `go_router` with auth guard redirect
- [ ] **STATE-1** Add `ViewState<T>` to critical ViewModels (login, order creation, sign-up)

### High (Sprint 2)
- [ ] **REL-1** Add `onError` reconnect handler to `AppOrderStore._remoteSub`
- [ ] **REL-2** Implement write-retry queue for `NetworkFailure` on order mutations
- [ ] **SCALE-1** Fix driver order stream to use server-side filter (RLS + composite stream)
- [ ] **OBS-2** Add structured logger to replace `debugPrint` calls

### Medium (Sprint 3)
- [ ] **NOTIF-1** Add `firebase_messaging` + Supabase trigger → FCM pipeline
- [ ] **LOC-1** Add `connectivity_plus` and surface offline banner in home views
- [ ] **TEST-1** Write integration tests for auth sign-up → OTP → profile creation flow
- [ ] **TEST-2** Write widget tests for order submission flow (supplier + driver)

### Medium (Sprint 4–5)
- [ ] **AI-1** Replace `mock_ai_marketplace_service` with Supabase Edge Function
- [ ] **AI-2** Unify `RewardService.calculate` with `calculate_reward` Edge Function
- [ ] **INIT-1** Show user-visible error screen when Supabase init fails in release builds
- [ ] **LOC-2** Persist user locale preference in `LocalStore` (currently only in `SharedPreferences` via `AppLangNotifier`)

### Low (Backlog)
- [ ] **PHONE-1** Activate Twilio + phone OTP sign-up path
- [ ] **PERF-1** Paginate `orders` stream (cursor-based) once dataset exceeds ~1000 rows
- [ ] **MODEL-1** Add `LocalStore` order schema versioning + migration guard
- [ ] **LOC-3** Add missing `LocationPublisher` network-loss buffering
- [ ] **AI-3** Upgrade `DawaChatbotService` to LLM-backed Edge Function

---

## Appendix A: File Responsibility Map

```
lib/
├── main.dart                          Bootstrap, DI wiring
├── core/
│   ├── config/env.dart                Compile-time env constants
│   ├── result/result.dart             Result<T,E>, AppResult<T>
│   ├── services/
│   │   ├── supabase_service.dart      Supabase init + client accessor
│   │   ├── app_lang_notifier.dart     Locale ChangeNotifier
│   │   └── app_theme_notifier.dart    Theme ChangeNotifier
│   ├── theme/app_theme.dart           ThemeData
│   └── utils/                         Misc helpers
├── domain/
│   ├── entities/auth_session.dart     Pure domain entity (no Supabase imports)
│   ├── failures/app_failure.dart      Sealed failure hierarchy
│   ├── repositories/                  Abstract interfaces only
│   ├── requests/                      DTO input objects
│   └── services/                      AI + location service interfaces
├── data/
│   ├── local/local_store.dart         SharedPrefs wrapper
│   ├── mock/                          Seed data (test + dev only)
│   ├── models/                        Order, UserRole, RewardBreakdown, …
│   ├── repositories/                  Supabase + Mock implementations
│   └── services/
│       ├── app_order_store.dart       Central order state (ChangeNotifier)
│       ├── app_order_store/           Part files (domain-specific extensions)
│       ├── driver_order_store.dart    Role proxy
│       ├── supplier_order_store.dart  Role proxy
│       ├── recycling_order_store.dart Role proxy
│       ├── supabase_auth_service.dart Supabase auth operations
│       ├── supabase_auth_service/     Part files (signup + auth helpers)
│       ├── user_signup_service.dart   Thin delegation layer
│       ├── reward_service.dart        Local reward calculation
│       ├── location_publisher.dart    GPS → Supabase upsert
│       └── driver_location_stream.dart Realtime LatLng stream
└── ui/
    ├── common/                        Shared widgets
    └── features/
        ├── auth/                      Login, OTP, SignUp, PasswordReset views + VMs
        ├── home/
        │   ├── home_router.dart       Role-based navigation dispatcher
        │   ├── driver/               Driver home + tabs + widgets + VM
        │   ├── supplier/             Supplier home (individual + business) + VM
        │   ├── recycling/            RecyclingCo home + tabs + VM
        │   └── shared/               Shared order widgets
        ├── chatbot/                   Dawa chatbot + ML Kit scan
        └── splash/                    Splash + session rehydration
```

---

*Report generated: Architecture analysis of `lib/` codebase — Dawer v0.1.0*
