# 12. Production Readiness

This document is the authoritative checklist for going from the current MVP demo state to a live production build. Items are grouped by priority. A developer picking up this project should start here.

---

## Current State Summary

The app is **feature-complete in mock/demo mode**. All three role shells (Driver, Supplier, Recycling Company) are built and working. The Supabase backend schema is production-grade. The gap is the Flutter ↔ Supabase wiring.

**Boot path today:**
```
.env.local loaded → Supabase initialized → mockAuth = true → MockAuthRepository bound
→ App boots with fake users, local order seed data
```

**Target production path:**
```
.env.local loaded → Supabase initialized → mockAuth = false → SupabaseAuthRepository bound
→ Real phone OTP → Real user profile → Real orders from Postgres
```

---

## Priority 1: Must-do before any real users

### 1.1 Flip mockAuth

**File:** `lib/main.dart:72`

```dart
// Change this:
const mockAuth = true;

// To this:
const mockAuth = false;
```

**What this unlocks:** `SupabaseAuthRepository` and `SupabaseSignupOrchestrator` are bound instead of their mock equivalents. Phone OTP becomes the real login path.

**Prerequisite:** Supabase project must have Phone provider enabled (Twilio or Supabase's built-in SMS).

---

### 1.2 Complete the signup → profile write

**File:** `lib/data/repositories/supabase_auth_repository.dart`

After a successful phone OTP, `signUp` must INSERT a row into `public.profiles`. The `SupabaseSignupOrchestrator` already calls `updateProfile`, but verify:
- `auth_id` = `auth.uid()` — confirmed via migration schema
- All required fields populated: `name`, `phone`, `role`, `supplier_type` (for suppliers)
- Vehicle fields populated for drivers (from signup wizard data)

**Test:** Sign up with a real phone, verify the `profiles` row appears in Supabase.

---

### 1.3 Verify session persistence across restarts

After login, `AuthSession` must survive app restart:

**File:** `lib/data/repositories/supabase_auth_repository.dart`

Supabase SDK stores the session token in secure storage automatically. But `currentSession` in the app needs to be loaded from `LocalStore` or from `Supabase.instance.client.auth.currentSession` on cold start.

**Test:** Log in → force-kill app → reopen → you should land on HomeRouter, not LoginView.

---

### 1.4 Remove hardcoded Supabase credentials from code

**File:** `lib/core/services/supabase_service.dart` (or wherever the fallback URL/key appears)

The fallback URL `https://bpzuwwbtqqrpohfqjcuo.supabase.co` and anon key are committed in code. This is acceptable for development but not for a public repo or production build. Move all credentials exclusively to `.env.local` and remove fallbacks.

---

### 1.5 Bind the real wallet repository

**File:** `lib/main.dart`

```dart
// The wallet is bound to NoOpWalletRepository by default.
// Change to:
Provider<IWalletRepository>(
  create: (_) => useSupabase
      ? SupabaseWalletRepository(SupabaseService.client)
      : const NoOpWalletRepository(),
),
```

This is already done in the current `main.dart` — confirm `SupabaseWalletRepository` is actually used when `useSupabase = true`.

---

## Priority 2: Required for a useful v1

### 2.1 Push notifications (FCM)

**Current state:** `NoopNotificationService` is bound. No notifications reach any device.

**What is needed:**
1. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the platform folders.
2. Implement `FcmNotificationService` (already exists in `lib/data/services/` — check if it's complete).
3. Bind it in `main.dart` instead of `NoopNotificationService`.
4. Supabase Edge Function `send_push` already exists — it should fire when orders change status.

**Impact:** Without this, drivers don't know when new orders appear, suppliers don't know when their order is accepted, companies don't know when a sale is committed.

---

### 2.2 Real-time driver tracking on the customer side

**Current state:** `LocationPublisher` publishes GPS to `driver_locations` table. But the supplier's tracking screen (`live_tracking_map_view.dart`) uses a static placeholder map.

**What is needed:**
- Subscribe to `driver_locations` for the active order's `driver_id` using Supabase Realtime.
- Update the map marker on each new location event.

---

### 2.3 Unread chat badges

**Current state:** `IChatRepository.unreadCount()` is implemented in both mock and Supabase repositories. But `OrderCard` and `SupplierOrderCard` do not call it, so there is no badge.

**What is needed:**
- Call `unreadCount(orderId, currentUserId)` in the order card widget tree.
- Show a red badge count on the chat icon when count > 0.

---

### 2.4 Payout flow

**Current state:** The driver wallet holds and releases amounts via `SupabaseWalletRepository`. But the "Withdraw" button in `PaymentWalletCard` has no target screen.

**What is needed:**
- A withdrawal screen that calls the `process_payout` Edge Function.
- eFawateercom biller registration with the Central Bank of Jordan (required for regulated payouts).

---

## Priority 3: Quality and hardening

### 3.1 Replace the User object with real profile data

Many viewmodels construct a hardcoded `User` object for driver details:

```dart
// Example in driver_home_tab.dart
final driver = User(
  name: 'أحمد السائق',
  phone: '+962791234567',
  rating: 4.8,
  vehicleModel: 'تويوتا هايلكس',
  // ...
);
```

**Fix:** Load the real profile from `IAuthRepository.currentSession` and join with the `profiles` table row.

---

### 3.2 Error boundaries for remote write failures

`AppOrderStore` captures remote write errors in `lastError` and `HomeRouter` surfaces them as a SnackBar. But this only works when `HomeRouter` is mounted. Writes that fail before `HomeRouter` (during startup) or in modal flows are silently swallowed.

**Fix:** Add consistent error handling in each feature's ViewModel for its own write operations.

---

### 3.3 Code generation must run after every model change

Any change to `lib/data/models/order/order.dart` or other Freezed files requires:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Add this to the onboarding checklist so new developers don't get confused by stale `.freezed.dart` files.

---

### 3.4 Test coverage

Existing tests in `test/` cover:
- `AppOrderStore` lifecycle and persistence (`test/data/services/`)
- `ChatViewModel` send/receive/lock behavior (`test/ui/features/chat/`)
- `ChatView` widget rendering (`test/ui/features/chat/`)

Missing coverage:
- `RewardService` edge cases (zero weight, max payout cap)
- `SupabaseOrderRepository` (requires mock Supabase client)
- Driver proximity flow (geofence trigger → state machine)
- Auth flows (OTP success/failure)

---

### 3.5 Localization completeness

New strings added since the last ARB update are hardcoded in Arabic in the widget files. Before any release, sweep for hardcoded Arabic strings and add them to `lib/l10n/app_ar.arb` + `lib/l10n/app_en.arb`.

Run:
```bash
flutter gen-l10n
```

---

## Environment Setup for a New Developer

```bash
# 1. Clone repo
git clone https://github.com/DAWAS00/Dawer.git
cd dwaar

# 2. Install Flutter dependencies
flutter pub get

# 3. Generate Freezed/JSON models
dart run build_runner build --delete-conflicting-outputs

# 4. Create the env file
cp .env.example .env.local   # or create manually

# Contents of .env.local:
SUPABASE_URL=https://<your-project>.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
GEMINI_API_KEY=<your-gemini-key>

# 5. Run on a connected device or emulator
flutter run
```

If `.env.local` is missing or empty, the app boots in offline/mock mode (no Supabase, no AI).

---

## Mock Login Credentials (dev mode only)

When `mockAuth = true`, these phone numbers log in instantly without OTP:

| Phone | Role | Name |
|---|---|---|
| `+962790000001` | Driver | أحمد السائق |
| `+962790000002` | Supplier (individual) | خالد المورد |
| `+962790000003` | Supplier (store) | مطعم أبو علي |
| `+962790000004` | Recycling Company | شركة تدويركم |

Any OTP code is accepted in mock mode.

---

## Migration Apply Order

Apply Supabase migrations in this exact order:

```
00001_initial_schema.sql        ← tables, enums, RLS, storage buckets
00002_add_user_categories.sql   ← adds categories[] to profiles
00003_chat.sql                  ← chat_messages table + RLS
00004_postgis_compat.sql        ← PostGIS search-path fix
00005_chat_media.sql            ← kind column + chat-attachments bucket
00005_security_hardening.sql    ← revokes, scoped RLS
00006_revoke_public_execute.sql ← hardens function permissions
00007_reset_postgis_search_path.sql
00008_fix_orders_rls.sql        ← patches pending-order driver visibility
20260519_security_tables.sql    ← fraud_audit, additional timestamps
20260522_driver_locations.sql   ← driver_locations table + realtime
20260522_marketplace_limits.sql ← per-user marketplace listing limits
20260522_transaction_commission.sql ← commission_rate column
20260522_vehicle_type.sql       ← vehicle_type enum on profiles
20260522_wallet_functions.sql   ← hold/release/payout RPCs + driver_wallet
```

**Note:** `00005_chat_media.sql` and `00005_security_hardening.sql` share the same prefix — apply security_hardening AFTER chat_media to avoid conflicts.

---

## Known Issues and Workarounds

| Issue | Workaround |
|---|---|
| `shaders/ink_sparkle.frag` version error on `flutter test` | Run `flutter clean` first (stale build cache after SDK update) |
| Build runner conflicts on Freezed regeneration | Pass `--delete-conflicting-outputs` flag |
| Supabase Realtime not receiving events | Confirm `supabase_realtime` publication includes the relevant table; check RLS allows SELECT for the current user |
| Arabic text renders LTR in some widgets | Wrap with `Directionality(textDirection: TextDirection.rtl, child: ...)` or use `context.l10n` keys which trigger RTL automatically |
| `go_router` is in pubspec but not used | Safe to ignore; eventual migration target but not blocking |
