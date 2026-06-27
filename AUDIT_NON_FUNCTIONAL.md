# Dawer — Non-Functional Features Audit

**Date**: 2026-06-25  
**Project**: Dawer (دوّر) — Arabic-first waste-recycling logistics marketplace for Jordan  
**Stack**: Flutter + Supabase (planned migration to Firebase/GCP)  
**Roles**: Supplier · Driver · Recycling Company

---

## What Is This App?

A three-sided mobile platform connecting:
- **Suppliers** — individuals/businesses that generate recyclable waste and request pickups
- **Drivers** — accept orders and transport waste to recycling companies
- **Recycling Companies** — post collection jobs and purchase waste materials

---

## CRITICAL — Breaks or Deceives Users

### 1. `/error` Route Crashes the App
**File**: `lib/core/routing/app_router.dart`  
`BackendErrorScreen` is referenced at the `/error` route but never imported.  
Navigating to `/error` (e.g., on Supabase init failure) causes a **runtime crash** instead of showing the error screen.  
**Fix**: Add the missing import from `lib/ui/features/splash/views/splash_view.dart`.

---

### 2. Hardcoded Supabase Credentials in `main.dart`
**File**: `lib/main.dart:42–43`  
The production Supabase URL and anon key are hardcoded as fallback strings. Even when `--dart-define` env vars aren't passed, the app silently uses real credentials.  
**Fix** (PHASES.md P1-T1): Remove fallback strings. Replace with a `_BackendMissingErrorApp` guard that shows an Arabic error screen instead of crashing.

---

### 3. Driver Selection — Hardcoded Fake Drivers
**File**: `lib/ui/features/home/supplier/views/driver_selection_view.dart:27–58`  
The "assign a driver" screen shows **3 fictional hardcoded drivers** with a hardcoded distance of "١.٢ كم":

| Name | ID | Rating |
|---|---|---|
| أحمد صالح | DRV-001 | 4.9 |
| سامر علي | DRV-002 | 4.7 |
| محمود حسن | DRV-003 | 4.8 |

The Supabase `nearby_drivers()` SQL function exists in migrations but is **never called**.  
Real users see fake drivers when trying to assign a pickup.

---

## HIGH — Features That Appear to Work But Don't

### 4. All 5 AI Services Are Mocked

Every AI feature in the app returns hardcoded responses with no real analysis.

| Service | File | What It Fakes |
|---|---|---|
| `MockAiValidationService` | `lib/data/services/mock_ai_validation_service.dart` | Photo validation — passes/fails based on whether the filename contains the word "fail" |
| `MockAiLicenseValidationService` | `lib/data/services/mock_ai_license_validation_service.dart` | License scanning — returns the same 4–5 hardcoded waste categories per role regardless of what document is scanned |
| `MockAiMarketplaceService` | `lib/data/services/mock_ai_marketplace_service.dart` | Marketplace AI suggestions — returns a pre-written template string |
| `MockBrandProfileAiService` | `lib/data/services/mock_brand_profile_ai_service.dart` | Brand profile generation — ignores company name/tagline entirely; always returns the same 10 categories |
| `MockAiSimulationService` | `lib/data/services/mock_ai_simulation_service.dart` | Restaurant document verification — checks if the business name contains "italian" or "pizza" to slightly vary the output |

All three onboarding ViewModels inject mock AI services with explicit TODO comments:

- `lib/ui/features/auth/viewmodels/individual_supplier_onboarding_viewmodel.dart:116`
- `lib/ui/features/auth/viewmodels/store_onboarding_viewmodel.dart:108`
- `lib/ui/features/auth/viewmodels/recycling_co_onboarding_viewmodel.dart:130`

```dart
/// TODO: Replace MockAiService with real AI API — see mock_ai_service.dart
```

**Fix** (PHASES.md Phase 9): Deploy a Cloud Run `dawer-ai-service` with real endpoints.

---

### 5. Chatbot (Dawa) — No Real AI
**File**: `lib/ui/features/chatbot/dawa_chatbot_service.dart`  
The chatbot uses **static keyword-matching** against 6 hardcoded knowledge-base files. It cannot handle any question outside those scripts. Responses are canned — it is not connected to any LLM.

The "scan" quick-actions (`scan_oil_sample`, `scan_wood_sample`) run ML Kit on **bundled demo images** in `assets/images/` — they are not real user waste scans.

**Fix** (PHASES.md P9-T1): Deploy Cloud Run `/ai/chat` endpoint backed by an LLM. Load FAQ from Firestore (P9-T3).

---

### 6. Push Notifications — Not Implemented
The database schema is ready (`notifications` table in `supabase/migrations/00001_initial_schema.sql:123–133`, `fcm_token` column on users), and a DB trigger even inserts "pointsEarned" notifications automatically.

But in the Flutter app: **zero Firebase Messaging code exists**.
- No `firebase_messaging` package
- No FCM token registration
- No `onMessage` / `onMessageOpenedApp` listeners

The only notification in the entire app is the Android foreground service notification used to keep GPS tracking alive in the background.

**Fix** (PHASES.md Phase 8): Integrate Firebase Messaging, deploy Cloud Function `notifyOnStatusChange`.

---

### 7. Live Tracking Map — Not Wired to Real GPS
**File**: `lib/ui/common/map/live_tracking_map_view.dart`  
The map view correctly accepts a `driverStream` parameter, but **no parent component currently wires this to real GPS data**. Whether a user sees real or fake location depends entirely on the caller — and current callers do not pass a real stream.

Additional missing capabilities on the tracking map:
- No route polyline (requires Directions API — Phase 7)
- No live ETA (requires Distance Matrix API — Phase 7)

**Fix** (PHASES.md Phase 6 + Phase 7): Wire `FirebaseDriverLocationStream` → `LiveTrackingMapView`, then add polyline + ETA.

---

## MEDIUM — Incomplete Functionality

### 8. Store Onboarding Data Not Saved
**File**: `lib/ui/features/auth/viewmodels/store_onboarding_viewmodel.dart:205`

```dart
// TODO: persist selectedCategories + tagline to 'store_profiles' table
```

After a store completes onboarding, their selected waste categories and business tagline are held in ViewModel memory but **never written to the database**. This data is lost when the app is closed.

---

### 9. First Launch Shows 30+ Fake Orders
**File**: `lib/data/mock/order_mock_data.dart`  
On first app launch, `AppOrderStore` seeds itself with **30+ fabricated orders** and fake marketplace listings (fictional suppliers, drivers, Jordanian coordinates). Real Supabase data loads on top after authentication, but a fresh user session starts with fake data visible.

This is intentional for demo/development purposes but misleading in production.

---

### 10. AppOrderStore Has No Stream Reconnect
**File**: `lib/data/services/app_order_store.dart`  
If the Supabase Realtime subscription drops due to a network interruption, the store **does not attempt to reconnect**. There is no retry logic, no offline queue, and no connectivity monitor.

Affected users silently stop receiving live order updates with no error shown.

**Fix** (PHASES.md P5-T4, Gap REL-1):
```dart
void _scheduleReconnect() {
  Future.delayed(const Duration(seconds: 5), () => _subscribe(userId, role));
}
```
Full offline resilience (write-retry queue + offline banner) is Phase 8.

---

### 11. MockAuthRepository Active on Fallback Path
**File**: `lib/main.dart:165`, `lib/data/repositories/mock_auth_repository.dart`  
When Supabase fails to initialize, the app **silently falls back** to a mock auth repository that:
- Accepts any non-empty email/password
- Never persists sessions
- Returns empty streams for everything

Users on a broken connection may appear to log in but reach a non-functional app state.

**Fix** (PHASES.md P1-T2): Remove the mock auth branch entirely; surface init failures as an error screen.

---

## LOW — Minor / Localization / Navigation

### 12. Restaurant Signup Uses Deprecated Navigation
**File**: `lib/ui/features/auth/views/login_view.dart:108`

```dart
// TODO(Sprint2): replace with context.push('/signup/restaurant')
```

The restaurant signup button uses `Navigator.push` instead of GoRouter's `context.push`. This bypasses the app's routing layer and won't work correctly once the full GoRouter migration (Phase 5) is complete.

---

### 13. Hardcoded Arabic Strings — Won't Localize
These UI elements use hardcoded Arabic text instead of localized strings. They will **not switch to English** when the user changes their locale:

- `lib/ui/features/auth/views/widgets/license_scan_section.dart` — 10+ strings with `// TODO: localize` comments (e.g., `'الكاميرا'`, `'معرض الصور'`)
- `lib/ui/features/home/shared/widgets/marketplace_suggestion_banner.dart:71,124`
- `lib/ui/features/auth/views/widgets/restaurant_step_verification.dart:49`

---

### 14. Entire Firebase / GCP Migration Not Started
The PHASES.md roadmap covers 10 phases. **Phases 2–10 have not been started.** As a result, the following infrastructure does not exist yet:

| Planned Feature | Current State | Phase |
|---|---|---|
| Firebase Auth | Using Supabase | 3 |
| Firestore database | Using Supabase Postgres | 4 |
| Firebase Storage | Using Supabase Storage | 6 |
| Firebase Realtime DB (GPS) | Using Supabase tables | 6 |
| Cloud Run: Auth Service | Not deployed | 3 |
| Cloud Run: AI Service | Not deployed | 9 |
| Cloud Run: Reward Service | Not deployed | 6 |
| Google Maps Directions polyline | Not implemented | 7 |
| Distance Matrix ETA | Not implemented | 7 |
| Reverse geocoding on order creation | Not implemented | 7 |
| Push notifications (FCM) | Not implemented | 8 |
| Offline write-retry queue | Not implemented | 8 |
| Offline banner UI | Not implemented | 8 |

---

## What IS Functional

| Feature | Status |
|---|---|
| Email + Phone OTP login (Supabase) | Working |
| Password reset (full OTP cycle) | Working |
| File uploads — profile photos, ID docs | Working (Supabase Storage) |
| GPS location publishing (driver → Supabase) | Working |
| Realtime location subscription | Working |
| Order creation, acceptance, status updates | Working |
| Rewards & earnings calculation | Working (local math) |
| Recycling company collection jobs feed | Working |
| Driver earnings tab | Working |
| Marketplace listings | Working (after auth + data load) |
| ML Kit on-device waste image classification | Working |
| RTL Arabic / English localization (where wired) | Working |
| Analytics tab (calculated from real orders) | Working |
| GoRouter top-level navigation | Working |
| Role-dispatched home screens | Working |

---

## Priority Fix List

| # | Fix | File | Severity |
|---|---|---|---|
| 1 | Import `BackendErrorScreen` in router | `lib/core/routing/app_router.dart` | CRITICAL |
| 2 | Remove hardcoded Supabase credentials | `lib/main.dart:42–43` | CRITICAL |
| 3 | Wire driver selection to `nearby_drivers()` | `lib/ui/features/home/supplier/views/driver_selection_view.dart` | HIGH |
| 4 | Wire live tracking map to real GPS stream | `lib/ui/common/map/live_tracking_map_view.dart` | HIGH |
| 5 | Remove mock auth fallback | `lib/main.dart:165` | HIGH |
| 6 | Persist store onboarding categories/tagline | `lib/ui/features/auth/viewmodels/store_onboarding_viewmodel.dart:205` | MEDIUM |
| 7 | Add stream reconnect to AppOrderStore | `lib/data/services/app_order_store.dart` | MEDIUM |
| 8 | Localize hardcoded Arabic strings | `license_scan_section.dart` + 2 others | LOW |
| 9 | Fix restaurant signup navigation | `lib/ui/features/auth/views/login_view.dart:108` | LOW |
| 10 | Replace 5 mock AI services (Phase 9) | `lib/data/services/mock_*.dart` | Phase 9 |
| 11 | Implement push notifications (Phase 8) | New Firebase Messaging integration | Phase 8 |
| 12 | Add offline resilience (Phase 8) | New `ConnectivityNotifier` + retry queue | Phase 8 |

---

*Audit completed: 2026-06-25*
