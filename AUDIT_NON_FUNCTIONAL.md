# Dawer — Non-Functional Features Audit + Roadmap

**Original Audit**: 2026-06-25  
**Last Updated**: 2026-06-28  
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

## ✅ FIXED — Completed in LAITH Branch

### ~~1. `/error` Route Crashes the App~~ ✅ FIXED
**Commit**: `611976c`  
Created `lib/ui/features/error/backend_error_screen.dart`, added GoRouter + wired `/error` route.

---

### ~~5. Chatbot (Dawa) — No Real AI~~ ✅ FIXED
**Commit**: `d6d12c9`  
- `GeminiChatService` wraps a persistent Gemini 1.5 Flash `ChatSession` with Arabic system prompt
- Typing indicator (`داوة تفكر...`) shown while Gemini generates
- Auto-scroll via ViewModel listener
- Standard follow-up chips on every AI reply
- `_disposed` guard prevents post-dispose `notifyListeners()` crash
- Session survives widget disposal (bottom-sheet swipe-down no longer resets conversation)
- Errors logged with `debugPrint` instead of silently swallowed

---

### ~~7. Live Tracking Map — Polyline + ETA~~ ✅ FIXED
**Commit**: `f4fc79a`  
- `DirectionsService` calls Google Directions API via HTTP, decodes encoded polyline
- `MapsConfig` reads `MAPS_API_KEY` from `.env.local` — graceful degradation when absent
- `LiveTrackingMapView` draws green `Polyline` overlay on `GoogleMap`
- Re-fetches route when driver moves ≥150 m (throttled)
- Live ETA chip shows Directions API duration; falls back to parent-supplied `etaMinutes`
- `MAPS_API_KEY` added to `.env.local` and `android/local.properties`

> Note: GPS streaming to `LiveTrackingMapView` was already wired via `DriverLocationStream` +  
> Supabase Realtime for UUID orders. The audit's Phase 6 was already complete.

---

---

## CRITICAL — Breaks or Deceives Users

### 2. Hardcoded Supabase Credentials in `main.dart`
**File**: `lib/main.dart:42–43`  
The production Supabase URL and anon key are hardcoded as fallback strings. Even when env vars aren't passed, the app silently uses real credentials.  
**Fix**: Remove fallback strings. Replace with a `_BackendMissingErrorApp` guard that shows an Arabic error screen instead of crashing.  
**Requires**: Supabase

---

### 3. Driver Selection — Hardcoded Fake Drivers
**File**: `lib/ui/features/home/supplier/views/driver_selection_view.dart:27–58`  
The "assign a driver" screen shows **3 fictional hardcoded drivers** with hardcoded distance "١.٢ كم":

| Name | ID | Rating |
|---|---|---|
| أحمد صالح | DRV-001 | 4.9 |
| سامر علي | DRV-002 | 4.7 |
| محمود حسن | DRV-003 | 4.8 |

The Supabase `nearby_drivers()` SQL function exists in migrations but is **never called**.  
**Fix**: Replace fake list with real loading + empty states. Wire to `nearby_drivers()`.  
**Requires**: Supabase (partial — UI fix is standalone)

---

---

## HIGH — Features That Appear to Work But Don't

### 4. All 5 AI Services Are Mocked

Every AI feature returns hardcoded responses with no real analysis.

| Service | File | What It Fakes |
|---|---|---|
| `MockAiValidationService` | `lib/data/services/mock_ai_validation_service.dart` | Passes/fails based on whether filename contains "fail" |
| `MockAiLicenseValidationService` | `lib/data/services/mock_ai_license_validation_service.dart` | Returns same 4–5 categories per role regardless of document |
| `MockAiMarketplaceService` | `lib/data/services/mock_ai_marketplace_service.dart` | Returns pre-written template string |
| `MockBrandProfileAiService` | `lib/data/services/mock_brand_profile_ai_service.dart` | Ignores company name; always returns same 10 categories |
| `MockAiSimulationService` | `lib/data/services/mock_ai_simulation_service.dart` | Checks if business name contains "italian" or "pizza" |

**Fix**: Deploy Cloud Run `dawer-ai-service` with real endpoints.  
**Requires**: Cloud Run / Gemini API

---

### 6. Push Notifications — Not Implemented
DB schema ready (`notifications` table, `fcm_token` column on users, DB trigger for `pointsEarned`).  
In the Flutter app: zero Firebase Messaging code.
- No `firebase_messaging` package
- No FCM token registration
- No `onMessage` / `onMessageOpenedApp` listeners

**Fix**: Integrate Firebase Messaging, deploy Cloud Function `notifyOnStatusChange`.  
**Requires**: Firebase

---

---

## MEDIUM — Incomplete Functionality

### 8. Store Onboarding Data Not Saved
**File**: `lib/ui/features/auth/viewmodels/store_onboarding_viewmodel.dart:205`

```dart
// TODO: persist selectedCategories + tagline to 'store_profiles' table
```

Selected waste categories and business tagline are held in ViewModel memory but **never written to the database**. Lost on app close.  
**Requires**: Supabase

---

### 9. First Launch Shows 30+ Fake Orders
**File**: `lib/data/mock/order_mock_data.dart`  
`AppOrderStore` seeds itself with 30+ fabricated orders on first launch. Real Supabase data loads on top after auth, but a fresh session starts with fake data visible.  
**Fix**: Gate mock seed behind `kDebugMode`.  
**Requires**: Pure Dart — no backend

---

### 10. AppOrderStore Has No Stream Reconnect
**File**: `lib/data/services/app_order_store.dart`  
If the Supabase Realtime subscription drops, the store **does not reconnect**. No retry logic, no offline queue, no connectivity monitor. Users silently stop receiving live updates.

**Fix**:
```dart
void _scheduleReconnect() {
  Future.delayed(const Duration(seconds: 5), () => _subscribe(userId, role));
}
```
**Requires**: Pure Dart (re-calls existing subscribe method)

---

### 11. MockAuthRepository Active on Fallback Path
**File**: `lib/main.dart:165`  
When Supabase fails, app falls back to mock auth that accepts any credentials and never persists sessions. Users may appear to log in but reach a non-functional state.  
**Fix**: Remove mock auth branch entirely; surface init failures as an error screen.  
**Requires**: Supabase / Firebase

---

---

## LOW — Minor / Localization / Navigation

### 12. Restaurant Signup Uses Deprecated Navigation
**File**: `lib/ui/features/auth/views/login_view.dart:108`

```dart
// TODO(Sprint2): replace with context.push('/signup/restaurant')
```

Uses `Navigator.push` instead of GoRouter's `context.push`. Bypasses routing layer.  
**Requires**: Pure Dart — no backend

---

### 13. Hardcoded Arabic Strings — Won't Localize
Three files use hardcoded Arabic instead of `AppLocalizations`:
- `lib/ui/features/auth/views/widgets/license_scan_section.dart` — 10+ strings
- `lib/ui/features/home/shared/widgets/marketplace_suggestion_banner.dart:71,124`
- `lib/ui/features/auth/views/widgets/restaurant_step_verification.dart:49`

**Requires**: Pure Dart — no backend

---

### 14. Firebase / GCP Migration Not Started
Phases 2–10 of PHASES.md have not been started.

| Planned Feature | Current State | Phase |
|---|---|---|
| Firebase Auth | Using Supabase | 3 |
| Firestore database | Using Supabase Postgres | 4 |
| Firebase Storage | Using Supabase Storage | 6 |
| Firebase Realtime DB (GPS) | Using Supabase tables | 6 |
| Cloud Run: Auth Service | Not deployed | 3 |
| Cloud Run: AI Service | Not deployed | 9 |
| Cloud Run: Reward Service | Not deployed | 6 |
| Push notifications (FCM) | Not implemented | 8 |
| Offline write-retry queue | Not implemented | 8 |
| Offline banner UI | Not implemented | 8 |

---

---

## 🆕 NEW — Investor Demo Features (Dr. Mansour Vision)

*Added 2026-06-28. These are new feature additions for the investor pitch, not bug fixes.*

---

### D1. Live Command Center Screen
**Priority**: HIGH — Core investor demo feature  
**Description**: A real-time admin/demo dashboard screen showing the platform alive.

Required components:
- Full-screen Google Map of Amman with live markers for active orders
- Order cards appearing in real-time as they are created
- Animated driver marker moving toward pickup
- Live CO₂ savings counter (kg CO₂ avoided, updating in real-time)
- Total rescued oil metric (cumulative kg, live)
- Live earnings ticker (JOD, updating per completed order)

**Implementation notes**:
- Streams from `AppOrderStore` already provide order data
- Driver markers: extend `DriverLocationStream` to support multiple simultaneous drivers
- CO₂ and oil metrics: derive from order `wasteWeightKg` × material-specific emission factors
- Earnings: sum `order.driverEarnings` across completed orders in real-time

**Files to create**:
- `lib/ui/features/admin/command_center/command_center_screen.dart`
- `lib/ui/features/admin/command_center/command_center_view_model.dart`
- `lib/data/services/sustainability_metrics_service.dart` (CO₂/oil calculations)

---

### D2. Advanced AI Oil Quality Analysis
**Priority**: HIGH — Hard-to-replicate differentiator  
**Description**: User photographs collected oil; Gemini Vision analyzes the image and returns a structured quality report.

AI outputs required:
- ✅ / ❌ Is it actually used cooking oil?
- 💧 Water content estimate (none / low / high)
- 🔴 Impurity/contamination level (clean / moderate / heavily contaminated)
- ⭐ Quality grade (A / B / C / rejected)
- 📦 Quantity estimate (liters, based on container size in frame)
- 💰 Estimated payout range (JOD, based on quality + quantity)

**Implementation notes**:
- Extend `GeminiService` with `analyzeImage(Uint8List imageBytes)` using Gemini Vision (inline image parts)
- Create structured prompt that returns JSON: `{isOil, waterContent, impurityLevel, grade, estimatedLiters, estimatedPayoutJod}`
- Parse response and display in a rich result card with color-coded indicators
- Integrate into `DawaChatViewModel.handleImagePick` as an alternative analysis path
- Fallback: if not oil, show current ML Kit waste classification result

**Files to create**:
- `lib/data/services/gemini_oil_analysis_service.dart`
- `lib/ui/features/chatbot/widgets/oil_analysis_result_card.dart`
- `lib/data/models/oil_analysis_result.dart`

---

### D3. Enhanced Rewards System
**Priority**: MEDIUM — Retention + engagement feature  
**Description**: Gamified point system tied to real waste collection activity.

Required features:
- **Points engine**: 1 kg collected oil = configurable points (default: 10 pts/kg)
- **Eco Hero badge**: awarded at 100 kg lifetime collected; shown on profile
- **Amman neighborhood leaderboard**: rank suppliers by kg collected per district
- **Restaurant discount coupons**: partners unlock discounts at reward milestones
- **Driver fuel vouchers**: drivers earn JOD fuel credit per completed delivery

**Implementation notes**:
- Points already partially wired in `rewards` table (Supabase schema exists)
- Leaderboard: aggregate `order.wasteWeightKg` grouped by supplier `district` field
- Badge: new `achievements` collection/table with `type`, `earnedAt`, `userId`
- Discount/voucher: MVP can be a static list of codes shown in the rewards tab

**Files to create/modify**:
- `lib/data/services/rewards_service.dart` (extend existing)
- `lib/ui/features/home/shared/rewards/eco_hero_badge_widget.dart`
- `lib/ui/features/home/shared/rewards/neighborhood_leaderboard_view.dart`
- `lib/ui/features/home/shared/rewards/voucher_card_widget.dart`

---

### D4. AI Expansion Advisor Screen
**Priority**: MEDIUM — B2B / enterprise pitch feature  
**Description**: A screen for recycling companies showing AI-generated expansion recommendations.

Required outputs:
- 📍 Where to open the next collection hub (best-fit district)
- 👷 Where to hire more drivers (underserved zones)
- 🗺️ Coverage gap map (districts with demand but no active drivers)
- 💰 Most profitable zones (revenue per km² heatmap)
- 📊 Demand forecast (predicted order volume by district, next 30 days)

**Implementation notes**:
- Input data: historical orders (pickup coordinates + weight + material type), driver last-known locations, completed collection job locations
- Analysis: call Gemini with a structured prompt containing aggregated stats per district; ask for ranked recommendations
- Visualization: Google Maps heatmap overlay (`Heatmap` layer — requires Maps JavaScript API for web, or custom polygon overlay for mobile)
- MVP: text-based ranked list with district names; heatmap is Phase 2

**Files to create**:
- `lib/ui/features/home/recycling/expansion_advisor/expansion_advisor_screen.dart`
- `lib/ui/features/home/recycling/expansion_advisor/expansion_advisor_view_model.dart`
- `lib/data/services/expansion_analysis_service.dart`

---

### D5. Revenue Dashboard (Business Model Proof)
**Priority**: MEDIUM — Investor pitch clarity  
**Description**: A screen (admin or recycling company view) that shows the monetization model with real numbers.

Revenue streams to display:
- Order commission (5–10% per transaction) — live running total
- Factory subscription status (monthly subscription badge per enrolled factory)
- Sustainability data B2B panel (data export readiness indicator)
- Carbon credit report generator (PDF export of CO₂ offset metrics)
- Green advertising slots (banner showing available ad inventory)

**Implementation notes**:
- Commission: derive from `order.totalAmount × commissionRate` across completed orders
- Subscriptions: MVP — static enrolled factory list with subscription tier badge
- Carbon reports: generate simple PDF from `sustainability_metrics_service.dart` (D1)
- PDF export: add `pdf: ^3.10.0` package

**Files to create**:
- `lib/ui/features/admin/revenue/revenue_dashboard_screen.dart`
- `lib/ui/features/admin/revenue/revenue_dashboard_view_model.dart`
- `lib/data/services/revenue_metrics_service.dart`

---

### D6. Reverse Geocoding on Order Creation
**Priority**: LOW — UX polish, Maps API already available  
**Description**: When a supplier picks a location on the map, reverse geocode it to a human-readable Arabic address string and attach it to the order.

**Implementation notes**:
- Use `https://maps.googleapis.com/maps/api/geocode/json?latlng=...&language=ar&key=...`
- Extend `DirectionsService` with a `reverseGeocode(LatLng)` static method
- Display address string in order cards and confirmation screens

**Files to modify**:
- `lib/data/services/directions_service.dart` (add `reverseGeocode` method)
- Order creation ViewModel (attach `addressString` to order payload)

---

---

## What IS Functional

| Feature | Status |
|---|---|
| Email + Phone OTP login (Supabase) | ✅ Working |
| Password reset (full OTP cycle) | ✅ Working |
| File uploads — profile photos, ID docs | ✅ Working (Supabase Storage) |
| GPS location publishing (driver → Supabase) | ✅ Working |
| Realtime location subscription | ✅ Working |
| Order creation, acceptance, status updates | ✅ Working |
| Rewards & earnings calculation | ✅ Working (local math) |
| Recycling company collection jobs feed | ✅ Working |
| Driver earnings tab | ✅ Working |
| Marketplace listings | ✅ Working (after auth + data load) |
| ML Kit on-device waste image classification | ✅ Working |
| RTL Arabic / English localization (where wired) | ✅ Working |
| Analytics tab (calculated from real orders) | ✅ Working |
| GoRouter top-level navigation | ✅ Working |
| Role-dispatched home screens | ✅ Working |
| `/error` route with Arabic error screen | ✅ Fixed (LAITH `611976c`) |
| Dawa chatbot with real Gemini AI | ✅ Fixed (LAITH `d6d12c9`) |
| Live tracking map — route polyline + live ETA | ✅ Fixed (LAITH `f4fc79a`) |
| Google Maps API key wired to Directions API | ✅ Fixed (LAITH `f4fc79a`) |

---

---

## Full Task Priority Table

| # | Task | Type | Effort | Backend? | Priority |
|---|---|---|---|---|---|
| D1 | Live Command Center | New Feature | Large | Partial (streams) | 🔴 HIGH |
| D2 | AI Oil Quality Analysis | New Feature | Medium | No (Gemini Vision) | 🔴 HIGH |
| 3 | Fix driver selection UI | Bug Fix | Small | Partial (UI fix now) | 🔴 HIGH |
| 9 | Gate mock order seeding | Bug Fix | Tiny | No | 🟡 MEDIUM |
| 10 | AppOrderStore reconnect | Bug Fix | Small | No | 🟡 MEDIUM |
| 12 | Fix restaurant nav | Bug Fix | Tiny | No | 🟡 MEDIUM |
| 13 | Localize hardcoded strings | Bug Fix | Small | No | 🟡 MEDIUM |
| D3 | Enhanced Rewards System | New Feature | Large | Yes (Supabase) | 🟡 MEDIUM |
| D4 | AI Expansion Advisor | New Feature | Large | Partial (Gemini) | 🟡 MEDIUM |
| D5 | Revenue Dashboard | New Feature | Medium | Partial | 🟡 MEDIUM |
| D6 | Reverse Geocoding | Enhancement | Small | No (Maps API) | 🟢 LOW |
| 2 | Remove hardcoded Supabase creds | Bug Fix | Small | Yes | 🟢 LOW |
| 8 | Persist store onboarding data | Bug Fix | Small | Yes (Supabase) | 🟢 LOW |
| 6 | Push notifications | New Feature | Large | Yes (Firebase) | 🔵 Phase 8 |
| 4 | Replace mock AI services | New Feature | Large | Yes (Cloud Run) | 🔵 Phase 9 |
| 14 | Firebase/GCP migration | Migration | Massive | Yes | 🔵 Phase 2–10 |

---

*Original audit: 2026-06-25 · Updated with fixes + Dr. Mansour investor demo tasks: 2026-06-28*
