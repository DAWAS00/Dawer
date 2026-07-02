---
name: features-done-vs-next
description: Comprehensive list of what is implemented and working vs what is wired up but incomplete or not yet connected in Dwaar
metadata:
  type: concept
---

# Features — Done vs Next

## ✅ Done & Working

### Auth
- Login screen (phone + role selector) → OTP verification screen
- 4-step signup wizard with AI scanning (ID photo → vehicle photo)
- Mock auth fully functional for all 4 test accounts
- `SupabaseAuthRepository` written (password + OTP paths both implemented)
- `SupabaseAuthService` written (sign up with file upload, sign in, profile fetch)
- `UserSignUpService` wired to `SupabaseAuthService` at app boot

### Orders — Driver
- Available orders feed (filtered by vehicle type + chemical permit)
- Accept order → becomes active order
- Status progression: accepted → arrivedAtPickup → inTransit → arrivedAtDropoff → completed
- Arrival confirmation flow (supplier available/unavailable/timeout)
- Fraud detection (blocks markArrived > 200m away, increments counter)
- Ghost timer cancellation
- Driver earnings dashboard (mock data, charts, breakdown)
- Driver rating submission post-delivery
- Driver history tab

### Orders — Supplier
- Pickup request wizard (3 steps: material/photo → quantity/price → location/review)
- New order sheet (2-step sheet: ai_logic + location_logic + sections)
- Cancel pending order
- Assign driver manually (driver selection view)
- Supplier orders tab (4-section layout)
- Individual supplier home view + store business home view
- Rewards view with points system

### Orders — Recycling Company
- Post collection job (form with waste types, area, price model, expiry)
- Edit collection job in-place (`isEdited` flag)
- Delete collection job
- Incoming deliveries view
- Company KPI row (stats header)
- Accept/reject incoming collection sales view

### Marketplace
- Marketplace tab (shared across all roles): segments — items, collection jobs
- Post to market sheet (3 steps: details → images → location)
- Market item detail view (price card, info card, gallery, delivery options)
- Purchase choice: self-pickup or delivery (rider assigned)
- Recycling co receives at facility
- Collection job detail view + accept commitment sheet
- Collection sale detail view
- AI chatbot FAB on marketplace (Dawa chatbot)
- Marketplace AI suggestion banner

### AI Services
- Gemini vehicle registration scan → extracts plate, model, color
- Gemini license validation
- AI photo picker with laser scanner FX animation
- Mock AI services for all real AI services (swappable via interface)
- `DawaChatbot` (market AI assistant)
- `MarketAiService` (Gemini-backed marketplace suggestions)

### Infrastructure
- Supabase order repository (all CRUD + status updates + RPC for transactions)
- Supabase file storage (profile photo, identity document upload)
- LocalStore JSON persistence (survives restarts)
- FCM push notifications (soft fail if google-services.json absent)
- Location services (geolocator, geocoding, proximity detection)
- Live tracking map (Google Maps, dual real/mock modes)
- Driver location publisher stream
- Arabic/English localization (`.arb` files, `context.l10n`)
- Light/dark theme toggle
- Language picker (AR/EN)
- Responsive layout utilities (adaptive padding for screen widths)

### UI Components
- `OrderCard` (multi-mode: driver/supplier/recycling)
- `SupplierOrderCard`
- `CollectionJobCard` + `CollectionSaleCard`
- `MarketItemCard` + `MarketListingCard`
- `OrderDetailsView` (shared, 12 section widgets)
- `OrderMapSection` (4 rendering modes: live tracking, route, pickup, fallback)
- `DwaarElevatedCard`, `DwaarSkeleton`
- `CommonWizardProgressBar` + `CommonWizardTopBar`
- Earnings dashboard widgets (chart, trend, KPI row, stat scroll)
- Chat view (mock)

---

## 🔴 Not Yet Wired / Incomplete

### Critical Path — Auth Real Integration
**`IAuthRepository` in `main.dart` is `MockAuthRepository`.** `SupabaseAuthRepository` exists and is complete but is NOT injected. This is the single most important next step.

To swap:
```dart
// In main.dart MultiProvider, replace:
Provider<IAuthRepository>(create: (_) => MockAuthRepository())
// With:
Provider<IAuthRepository>(
  create: (ctx) => SupabaseAuthRepository(
    Supabase.instance.client,
    UserSignUpService(authService: ctx.read<SupabaseAuthService>()),
    ctx.read<LocalStore>(),
  ),
)
```
Also need to re-enable OTP validation in `MockAuthRepository.verifyOtp()` (disabled line marked `[DEV]`).

### Wallet / Payouts
- `SupabaseWalletRepository` written (`lib/data/repositories/supabase_wallet_repository.dart`)
- `AppOrderStore` receives `NoOpWalletRepository` — wallet holds/releases are no-ops
- Connect real wallet: pass `SupabaseWalletRepository` to `AppOrderStore` constructor

### Earnings Real Data
- `EarningsDashboardView` uses `MockEarningsRepository`
- `SupabaseOrderRepository` has `recordTransaction()` (calls `record_order_transaction` RPC)
- Missing: bind `SupabaseEarningsRepository` once Supabase earnings table is confirmed

### Driver Supabase Stream Filtering
- `SupabaseOrderRepository.watchOrdersForUser()` for `UserRole.driver` falls back to `watchOrders()` (full table)
- Comment in code: "RLS on the DB enforces visibility; client-side filter in AppOrderStore until pagination added in later sprint"
- Next: implement proper driver stream filter (pending orders with no driver_id)

### PDF Reports
- `lib/domain/services/pdf_report_service.dart` — interface exists
- No concrete implementation wired
- `pdf` package is in pubspec

### Navigation (go_router)
- `go_router: ^14.0.0` is in pubspec but **zero usage** in live code
- All navigation is imperative `Navigator.push`
- Next: migrate to named routes if deep linking or auth-guard is needed

### Admin Panel
- `AdminApprovalStatus` enum + field on `Order` implemented
- Chemical orders auto-set to `pendingApproval`
- No admin UI screen exists — approvals are backend-only

### Restaurant Home View Disambiguation
- `lib/ui/features/home/restaurant/restaurant_home_view.dart` is used for `storeBusiness` suppliers
- `lib/ui/features/home/restaurant/` folder name is misleading (not a separate role)

### Chat Real Backend
- `IChatRepository` → `MockChatRepository` only
- Chat messages are in-memory; no Supabase table wired

### Eco Impact
- `EcoImpactCalculator` implemented (CO2, water, energy savings)
- Not surfaced in any UI screen yet

---

## Related Pages

- [[concepts/app-architecture]]
- [[patterns/mock-to-real-swap]]
- [[patterns/auth-flow]]
