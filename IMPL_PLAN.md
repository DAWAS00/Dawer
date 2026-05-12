# Implementation Plan — Fixes + Features

Priority order: data-layer fixes first (unblock everything), then features by value/effort ratio.

---

## Part A — Fixes (Technical Debt)

### Fix 1 · ETA computed from `etaMinutes` instead of hardcoded string

**Problem:** `driver_actions.dart:49` sets `eta: 'جاري الحساب...'` and never updates it.  
`Order.etaMinutes` (int?) already exists but is never populated on accept.

**Files touched:**
- `lib/data/services/app_order_store/driver_actions.dart`
- `lib/data/models/order.dart` (no change needed — field exists)
- `lib/ui/features/home/driver/tabs/driver_home_tab.dart` (or wherever ETA is rendered)

**Plan:**
1. In `acceptOrder()`, remove `eta: 'جاري الحساب...'`.
2. Compute `etaMinutes` from `distanceKm` (rough: 1 km ≈ 2 min in urban Jordan) when `distanceKm` is known; otherwise leave null.
3. Add a computed getter on `Order`:
   ```dart
   String get etaLabel {
     if (etaMinutes == null) return 'جاري الحساب...';
     if (etaMinutes! < 60) return '$etaMinutes دقيقة';
     return '${(etaMinutes! / 60).round()} ساعة';
   }
   ```
   Add this getter in `lib/data/models/order_labels.dart` (already exists for display labels).
4. Replace all `order.eta` reads in UI with `order.etaLabel`.
5. When the driver calls `markInTransit()`, clear `etaMinutes` (null — trip started).

**Effort:** 1–2 h. Zero schema change.

---

### Fix 2 · Driver completed IDs not hardcoded

**Problem:** `app_order_store.dart:65` — `_driverCompletedIds = ['ORD-H01', 'ORD-H02']`.  
Completing an order adds the ID live (`_driverCompletedIds.add(...)` in `completeOrder()`), but the seed list is hardcoded.

**Files touched:**
- `lib/data/services/app_order_store.dart`
- `lib/data/local/local_store.dart`

**Plan:**
1. Persist `_driverCompletedIds` in `LocalStore`. Add:
   ```dart
   List<String> readDriverHistory();
   Future<void> writeDriverHistory(List<String> ids);
   ```
2. In `_bootstrap()`, load from store (empty list on first launch instead of hard-coded).
3. In `completeOrder()`, call `_store?.writeDriverHistory(_driverCompletedIds)` after mutating the list.
4. Remove the hardcoded `['ORD-H01', 'ORD-H02']` entirely.  
   Seed orders `ORD-H01`/`ORD-H02` in `OrderMockData` can stay; just don't pre-mark them as "completed".

**Effort:** 2 h. No UI change.

---

### Fix 3 · `pickupAddress` resolved from coordinates

**Problem:** `order_supabase_ext.dart:66` — `pickupAddress: 'موقع السحب المختار'`.  
Supabase stores `pickup_location` as PostGIS POINT but we never reverse-geocode it.

**Files touched:**
- `lib/data/models/order_supabase_ext.dart`
- `lib/data/repositories/supabase_order_repository.dart`
- New: `lib/data/services/geocoding_service.dart`

**Plan:**
1. Add `geocoding` package (already common in Flutter; or use Supabase Edge Function for Arabic address lookup).
2. Create `GeocodingService`:
   ```dart
   abstract interface class IGeocodingService {
     Future<String> reverseGeocode(double lat, double lng);
   }
   ```
3. Parse POINT coordinates from Supabase JSON in `orderFromSupabaseJson`:
   ```dart
   // 'pickup_location' → 'POINT(lng lat)' 
   (pickupLat, pickupLng) = _parsePoint(json['pickup_location'] as String?);
   ```
   Write `_parsePoint()` helper in the same file.
4. In `SupabaseOrderRepository.watchOrders()`, after fetching, pass orders through `GeocodingService.reverseGeocode()` to populate `pickupAddress`.
5. Fallback: if geocoding fails, display `'${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'` — never the dummy string.

**Effort:** 4 h. Requires adding `geocoding: ^3.0.0` to `pubspec.yaml`.

---

### Fix 4 · Replace mock AI services with real implementations

**Current mocks:**
- `mock_ai_marketplace_service.dart` — price suggestion
- `mock_ai_license_validation_service.dart` — driver license OCR
- `mock_ai_validation_service.dart` — waste classification
- `mock_brand_profile_ai_service.dart` — brand profile fill
- `mock_ai_simulation_service.dart` — route simulation

**Files touched:**
- `lib/data/services/ai/` directory (all mocks)
- New: `lib/data/services/ai/gemini_ai_service.dart`
- New: `lib/domain/repositories/i_ai_service.dart`

**Plan (phased — do not block on this):**

Phase A — Abstract the interface (1 day):
1. Create `IAiMarketplaceService`, `IAiValidationService` interfaces in `lib/domain/repositories/`.
2. Register mocks in DI via interface — keep current behavior, zero breakage.

Phase B — Gemini integration (3 days):
1. Add `google_generative_ai: ^0.4.0` to pubspec.
2. Create `GeminiAiService` implementing the two most valuable interfaces:
   - `IAiValidationService.classifyWaste(XFile photo)` → returns `WasteType`  
     Prompt: Arabic system prompt + Base64 image → JSON `{ waste_type: "metal" }`.
   - `IAiMarketplaceService.suggestPrice(WasteType type, double kg)` → `double`  
     Prompt: market rates context + type + weight → price in JD.
3. Wire via `const useRealAI = bool.fromEnvironment('USE_REAL_AI', defaultValue: false)` — same feature flag pattern already established.
4. License OCR (`mock_ai_license_validation_service`): use ML Kit `google_mlkit_text_recognition` — it's already in the project per `ARCHITECTURE.md`.

Phase C — remaining mocks (1–2 days each, low priority):
- Route simulation → replace with Google Maps Directions API call.
- Brand profile fill → Gemini with structured output.

**Effort:** Phase A 1 day, Phase B 3 days, Phase C deprioritize.

---

### Fix 5 · Order model — sealed subclasses (long-term refactor)

**Problem:** One `Order` class has 40+ fields, most null for any given `OrderType`. Makes pattern matching impossible and UI littered with `if (order.type == ...)` branches.

**Files touched:** Almost every file that imports `order.dart` — **highest-blast-radius fix in the codebase**. Do last.

**Plan:**
1. Create sealed hierarchy in `lib/data/models/order_sealed.dart`:
   ```dart
   sealed class OrderBase { ... } // shared fields only
   final class PickupRequest extends OrderBase { ... }
   final class CollectionJob extends OrderBase { ... }
   final class CollectionSale extends OrderBase { ... }
   final class MarketplaceListing extends OrderBase { ... }
   ```
2. Migrate one VM at a time: `DriverOrderStore` first (only needs `PickupRequest`).
3. Keep `Order` as a compatibility typedef during migration:
   ```dart
   typedef Order = OrderBase; // remove after all consumers migrated
   ```
4. Update all `switch (order.type)` to `switch (order)` with exhaustive patterns.
5. Update `order_json.dart` and `order_supabase_ext.dart` with factory constructors per subclass.

**Effort:** 2–3 days. Do after Fixes 1–4 are merged. Branch: `refactor/order-sealed`.

---

## Part B — New Features

### Feature 1 · Carbon Footprint Counter (pure client — ship first)

**Value:** High visibility, zero backend, ships in 1 day.

**Files:**
- New: `lib/domain/services/carbon_calculator.dart`
- New: `lib/ui/features/home/shared/widgets/carbon_badge.dart`
- Touch: `lib/ui/features/home/supplier/tabs/supplier_profile_tab.dart`
- Touch: `lib/ui/features/home/recycling/tabs/recycling_profile_tab.dart`

**Plan:**
1. `CarbonCalculator` — pure functions, no state:
   ```dart
   abstract final class CarbonCalculator {
     // kg CO₂ saved per kg of waste diverted from landfill (IPCC defaults)
     static const Map<WasteType, double> _kgCo2PerKg = {
       WasteType.metal: 1.8,
       WasteType.paper: 1.1,
       WasteType.plastic: 1.5,
       WasteType.glass: 0.3,
       WasteType.oil: 2.2,
     };
     static double savedKgCo2(WasteType type, double weightKg) =>
         weightKg * (_kgCo2PerKg[type] ?? 0.5);
   }
   ```
2. `CarbonBadge` widget: shows leaf icon + `X.X كغ CO₂ موفّر`.
3. Compute over `driverHistory` / `supplierOrders` where `status == completed && weightKg != null`.
4. Show on profile tabs.

**Effort:** 4 h.

---

### Feature 2 · Driver Earnings Dashboard

**Value:** `RewardService` + `RewardTransaction` already exist but are never displayed.

**Files:**
- New: `lib/ui/features/home/driver/tabs/driver_earnings_tab.dart`
- New: `lib/ui/features/home/driver/viewmodels/driver_earnings_viewmodel.dart`
- Touch: `lib/ui/features/home/driver/driver_home_view.dart` (add tab)
- Touch: `lib/data/services/reward_service.dart` (wire to real orders)

**Plan:**
1. `DriverEarningsViewModel extends ChangeNotifier`:
   - Holds `List<RewardTransaction> _transactions`.
   - Computes `double totalPoints`, `double totalJd`, breakdown by `WasteType`.
   - Sources: `AppOrderStore.driverHistory` → pass each completed order through `RewardService.calculate(order)`.
2. `DriverEarningsTab` UI:
   - Summary card: total JD + points + CO₂ saved.
   - Scrollable list of `RewardTransaction` items.
   - Weekly bar chart (use `fl_chart` — check if already in pubspec; if not, add).
3. Add tab to `DriverHomeView` bottom nav (currently: Home, Orders, Profile → add Earnings as 4th tab or replace Orders History sub-tab).

**Effort:** 1.5 days.

---

### Feature 3 · Waste Photo → Auto `WasteType` (ML Kit)

**Value:** Removes biggest friction point in supplier order creation.

**Files:**
- New: `lib/data/services/ai/waste_classifier_service.dart`
- New: `lib/domain/repositories/i_waste_classifier.dart`
- Touch: `lib/ui/features/home/supplier/tabs/` — order creation flow

**Plan:**
1. Wrap `google_mlkit_image_labeling` (already in project):
   ```dart
   class WasteClassifierService implements IWasteClassifier {
     static const Map<String, WasteType> _labelMap = {
       'Bottle': WasteType.plastic,
       'Can': WasteType.metal,
       'Paper': WasteType.paper,
       'Cardboard': WasteType.paper,
       'Glass': WasteType.glass,
     };
     Future<WasteType?> classify(XFile image) async { ... }
   }
   ```
2. After supplier picks a photo in order creation, call classifier → pre-select `WasteType` chip.
3. Show confidence indicator (if confidence < 0.6 → show "اقتراح: X" label, not auto-select).
4. Provide `MockWasteClassifier` for tests.

**Effort:** 1 day.

---

### Feature 4 · Scheduled Recurring Pickups

**Value:** Locks in supplier retention (restaurants, hotels on weekly schedule).

**Files:**
- New: `lib/data/models/recurring_schedule.dart`
- New: `lib/domain/repositories/i_schedule_repository.dart`
- New: `lib/data/repositories/supabase_schedule_repository.dart`
- New: `lib/ui/features/home/supplier/views/schedule_pickup_view.dart`
- New Supabase table: `recurring_schedules` (migration below)

**Supabase migration:**
```sql
create table recurring_schedules (
  id          uuid primary key default gen_random_uuid(),
  supplier_id uuid references users(id) on delete cascade,
  waste_types text[],
  frequency   text not null,        -- 'weekly' | 'biweekly' | 'monthly'
  day_of_week smallint,             -- 0=Sun … 6=Sat
  time_of_day time,
  notes       text,
  is_active   boolean default true,
  created_at  timestamptz default now()
);
alter table recurring_schedules enable row level security;
create policy "supplier owns their schedules"
  on recurring_schedules for all
  using (supplier_id = auth.uid());
```

**Plan:**
1. `RecurringSchedule` model (immutable, copyWith, toJson/fromJson).
2. `IScheduleRepository` with `watchSchedules()`, `createSchedule()`, `deleteSchedule()`.
3. Supabase implementation backed by above table.
4. `SchedulePickupView`: day-of-week picker + time picker + waste type multi-select.
5. Cron job (Supabase Edge Function or pg_cron) to auto-create pickup orders from active schedules. Wire later — UI ships first.

**Effort:** 2.5 days (UI + repo). Edge Function: +1 day.

---

### Feature 5 · Driver Multi-Stop Batching

**Value:** Reduces empty-leg trips; higher driver earnings per shift.

**Files:**
- New: `lib/data/models/batch_trip.dart`
- New: `lib/data/services/app_order_store/batch_actions.dart` (new part file)
- New: `lib/ui/features/home/driver/views/batch_trip_view.dart`
- Touch: `lib/data/services/app_order_store.dart` (add part declaration)

**Plan:**
1. `BatchTrip` model:
   ```dart
   class BatchTrip {
     final String id;
     final List<String> orderIds;  // ordered by route
     final String? currentLegOrderId;
     final BatchTripStatus status; // assembling | active | completed
   }
   ```
2. `AppOrderStoreBatchActions` extension:
   - `proposeBatch(List<String> orderIds)` — driver selects up to 3 nearby pending orders.
   - `startBatch(String batchId)` — locks in, sets all orders to `accepted`.
   - `completeLeg(String orderId)` — marks one stop done, advances to next.
3. `BatchTripView`: map showing stops in order + leg-by-leg action buttons.
4. Constraint: only allowed when `!driverHasActiveOrder` (single-order guard already exists).

**Effort:** 3 days. Depends on Fix 5 (sealed Order) being done first for clean pattern matching, but can ship without it.

---

### Feature 6 · Price Alerts for RecyclingCo (FCM)

**Value:** Notifies companies when a supplier lists matching waste at target price.

**Files:**
- New: `lib/data/models/price_alert.dart`
- New: `lib/domain/repositories/i_price_alert_repository.dart`
- New: `lib/data/repositories/supabase_price_alert_repository.dart`
- New: `lib/ui/features/home/recycling/views/price_alert_setup_view.dart`
- New Supabase Edge Function: `notify-price-match`

**Supabase migration:**
```sql
create table price_alerts (
  id          uuid primary key default gen_random_uuid(),
  company_id  uuid references users(id) on delete cascade,
  waste_type  text not null,
  max_price_per_kg numeric(8,3),
  min_weight_kg    numeric(8,2),
  is_active   boolean default true,
  created_at  timestamptz default now()
);
```

**Plan:**
1. `PriceAlert` model + repository (CRUD only, ~80 lines each).
2. `PriceAlertSetupView`: waste type selector + price threshold slider.
3. Supabase Edge Function (`notify-price-match`) triggered by `INSERT` on `orders` where `is_marketplace_shared = true`:
   - Queries matching `price_alerts`.
   - Sends FCM push via `firebase-admin` SDK.
4. Flutter side: receive FCM notification (use `firebase_messaging` package — add to pubspec).

**Effort:** 2 days (Flutter UI + repo) + 1 day (Edge Function).

---

### Feature 7 · Business Supplier Verification Badge

**Value:** Trust signal; reduces fake listings. Straightforward admin flow.

**Files:**
- Touch: `lib/data/models/user.dart` (add `isVerified: bool`)
- New: `lib/ui/widgets/verified_badge.dart`
- Touch: `lib/data/models/order_supabase_ext.dart` (read `is_verified` from supplier join)
- Supabase: `users.is_verified boolean default false` + admin-only update policy

**Plan:**
1. Add `is_verified` column to `users` table (migration).
2. Add `isVerified` field to `User` model.
3. `VerifiedBadge` widget: small green checkmark + "موثّق" label, reused on:
   - Order cards (beside supplier name).
   - Supplier profile tab.
   - Marketplace listings.
4. Admin verification: mark via Supabase dashboard (no in-app admin UI needed now).
5. Display-only — no behavioral change in orders.

**Effort:** 4 h.

---

### Feature 8 · RecyclingCo Analytics Tab

**Value:** Shows tonnage, spend, top waste types — high perceived value for B2B users.

**Files:**
- New: `lib/ui/features/home/recycling/tabs/recycling_analytics_tab.dart`
- New: `lib/ui/features/home/recycling/viewmodels/recycling_analytics_viewmodel.dart`
- Touch: `lib/ui/features/home/recycling/recycling_home_view.dart` (add tab)

**Plan:**
1. `RecyclingAnalyticsViewModel`:
   - Sources from `RecyclingOrderStore` (already has completed orders).
   - Computes: total kg per `WasteType`, total JD spent, monthly trend (group by `completedAt.month`).
   - Uses `ViewState<AnalyticsSummary>` (use the new `ViewState<T>` sealed class).
2. `AnalyticsSummary` value object:
   ```dart
   class AnalyticsSummary {
     final double totalKg;
     final double totalSpendJd;
     final Map<WasteType, double> kgByType;
     final List<MonthlyTotals> monthly; // last 6 months
   }
   ```
3. UI sections:
   - Summary row (3 stat chips).
   - Horizontal bar chart (kg by waste type) using `fl_chart`.
   - Monthly spend line chart.
   - Top 3 suppliers list.
4. Add `fl_chart: ^0.68.0` to pubspec if not present.

**Effort:** 2 days.

---

## Execution Order

| # | Item | Effort | Blocks |
|---|------|--------|--------|
| 1 | Fix 1 — ETA label | 2 h | nothing |
| 2 | Fix 2 — driver history persistence | 2 h | nothing |
| 3 | Feature 7 — verification badge | 4 h | nothing |
| 4 | Feature 1 — carbon counter | 4 h | nothing |
| 5 | Fix 3 — pickupAddress geocoding | 4 h | nothing |
| 6 | Feature 2 — earnings dashboard | 1.5 d | Fix 2 (history) |
| 7 | Feature 3 — waste photo classifier | 1 d | nothing |
| 8 | Feature 8 — analytics tab | 2 d | nothing |
| 9 | Fix 4A — abstract AI interfaces | 1 d | nothing |
| 10 | Feature 4 — scheduled pickups | 2.5 d | Supabase migration |
| 11 | Fix 4B — Gemini integration | 3 d | Fix 4A |
| 12 | Feature 5 — multi-stop batching | 3 d | nothing (better after Fix 5) |
| 13 | Feature 6 — price alerts + FCM | 3 d | Supabase migration |
| 14 | Fix 5 — sealed Order subclasses | 3 d | everything else done first |

Items 1–5 are parallelizable in a single sprint. Items 6–9 are a second sprint. 10–14 are sprint 3+.
