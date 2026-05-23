# Backend Status & Completion Plan
**Date:** 2026-05-23  
**Project:** Dawer (دوّر) — Supabase project `bpzuwwbtqqrpohfqjcuo`

---

## What Was Done Today

### 8 DB Migrations Applied to Live Supabase

#### 1. `security_tables`
- Added security columns to `orders`: `arrived_at_pickup_at`, `arrived_at_dropoff_at`, `arrival_confirmation_status`, `supplier_hold_amount`, `driver_compensation_amount`, `fraud_attempt_count`, `weight_variance_flag`, `proof_image_path`, `proof_captured_at`, `proof_lat`, `proof_lng`, `proof_checksum`
- Created `fraud_audit` table — logs every proximity block, no-show, fast completion, and weight variance event
- Created `driver_wallet` table — one row per driver, tracks `balance` and `held_amount` (escrow)
- Created `wallet_transactions` table — immutable ledger of every hold, release, refund, and penalty
- Enabled RLS on all three new tables with correct service_role / driver-scoped policies

#### 2. `driver_locations`
- Created `driver_locations` table — live GPS upserted by LocationPublisher every 10m
- Enabled RLS: drivers write their own row only; authenticated users (suppliers/companies) can read for live map
- Added table to `supabase_realtime` publication so DriverLocationStream receives real-time updates

#### 3. `vehicle_type`
- Created `vehicle_type` ENUM: `motorcycle`, `car`, `pickup`, `van`, `truck`, `heavyTruck`
- Added `vehicle_type` and `has_chemical_permit` columns to `users`
- Added `required_vehicle_type`, `requires_chemical_permit`, `admin_approval_status` columns to `orders`
- Replaced `orders_waste_types_check` constraint to include new `copperAluminium` waste type
- Added filtered index `orders_required_vehicle_type_idx` for fast driver feed queries

#### 4. `transaction_commission`
- Added full pricing breakdown columns to `transactions`: `weight_surcharge_jd`, `gross_fee_jd`, `platform_cut_jd`, `driver_payout_jd`, `vehicle_type`, `needs_manual_review`
- Added `transactions_driver_created_idx` for finance reports

#### 5. `wallet_functions`
- Created `driver_wallet_hold(order_id, amount)` RPC — called when driver accepts an order, escrows expected payout
- Created `driver_wallet_release(order_id, amount)` RPC — called on order completion, moves held → balance
- Created `auto_credit_driver_compensation()` trigger — fires after `orders` status → `cancelled`, automatically credits driver compensation from the held amount

#### 6. `marketplace_limits`
- Added `expires_at` column to `orders` (14 days for individuals, 30 days for businesses — set at listing creation)
- Created `record_order_transaction(...)` RPC — SECURITY DEFINER function so drivers can write their own payout row without needing service_role

#### 7. `waste_rates` *(new — no prior migration file)*
- Created `waste_rates` table with `base_rate_jd`, and generated `floor_rate_jd` (×0.5) and `ceiling_rate_jd` (×3.0) columns
- Seeded all 15 material types with rates from the pricing plan
- RLS: authenticated users can read; only service_role can update (admin-updatable without app release)

#### 8. `vat_and_supplier_commission` *(new — no prior migration file)*
- Added `vat_amount_jd`, `is_vat_applicable`, `supplier_fee_jd` to `orders`
- Added `vat_amount_jd` to `transactions` for full audit trail

---

## What Still Needs to Be Done

### 1. Deploy `verify_arrival` Edge Function ← NEXT STEP
**Status:** File exists at `supabase/functions/verify_arrival/index.ts`, not yet deployed.  
**What it does:** Server-side geofence gate — reads `driver_locations`, computes haversine distance to target, returns `{ allowed, distanceMeters }`, logs fraud_audit on block.  
**Commands to run:**
```bash
supabase link --project-ref bpzuwwbtqqrpohfqjcuo
supabase functions deploy verify_arrival
```
No code changes needed — the file is complete.

---

### 2. Write & Deploy `daily_payout` Edge Function
**Status:** Planned in pricing_formula_plan.md, not yet written.  
**What it does:** Runs at 02:00 AM Amman time (23:00 UTC) via pg_cron. For every driver with `balance > 0` and no active holds, transfers net balance to their account, inserts a `wallet_transaction(type='payout')`, resets balance to 0, sends push notification.  
**Files to create:**
- `supabase/functions/daily_payout/index.ts`
- pg_cron schedule: `SELECT cron.schedule('daily-payout', '0 23 * * *', 'SELECT net.http_post(...)')`

---

### 3. Add `waste_rates` Read to Supplier Listing Flow
**Status:** Table exists and is seeded. App not yet wired to read from it.  
**What to do:** In `post_to_market_sheet.dart`, replace hardcoded price suggestions with a live fetch from `waste_rates` so the suggested price and floor/ceiling validation use the DB values.

---

### 4. Wire `record_order_transaction` RPC from App
**Status:** RPC exists in DB. App's `supabase_order_repository.dart` not yet calling it.  
**What to do:** On order completion in the driver flow, call `record_order_transaction(...)` with the full `RewardBreakdown` fields instead of (or in addition to) writing locally.

---

### 5. Wire `driver_wallet_hold` / `driver_wallet_release` RPCs from App
**Status:** RPCs exist in DB. App not yet calling them.  
**What to do:**
- Call `driver_wallet_hold` when driver accepts an order (`OrderStatus.accepted`)
- Call `driver_wallet_release` when order completes (`OrderStatus.completed`)
- Both calls go through `supabase_wallet_repository.dart`

---

### 6. Wire VAT Logic from App to DB
**Status:** `vat_amount_jd` and `is_vat_applicable` columns exist. App's `RewardService` calculates VAT but doesn't persist it.  
**What to do:** When creating/completing an order, write `vat_amount_jd` and `is_vat_applicable` to the `orders` row based on whether both parties are `storeBusiness` or `recyclingCo`.

---

### 7. Listing Expiry Enforcement
**Status:** `expires_at` column exists. App doesn't set it on listing creation or filter expired listings.  
**What to do:**
- In `post_to_market_sheet.dart`, set `expires_at = now() + 14 days` (individual) or `+ 30 days` (business) when inserting an order
- In the marketplace feed query, add `AND (expires_at IS NULL OR expires_at > now())` filter

---

### 8. Admin Approval Flow for Chemicals
**Status:** `admin_approval_status` column exists. No admin-side logic implemented.  
**What to do:**
- When supplier posts `WasteType.chemicals`, set `admin_approval_status = 'pendingApproval'` and `status = 'pending'` (hidden from feed)
- Build or stub an admin dashboard / Supabase Edge Function endpoint to approve/reject
- On approval, flip `admin_approval_status = 'approved'` → listing becomes visible

---

## Current DB Schema Summary

| Table | Status |
|---|---|
| `users` | ✅ vehicle_type, has_chemical_permit added |
| `orders` | ✅ vehicle, security, VAT, expiry, proof, admin approval columns added |
| `transactions` | ✅ full pricing breakdown + VAT added |
| `driver_locations` | ✅ live GPS table with RLS + Realtime |
| `driver_wallet` | ✅ balance + escrow |
| `wallet_transactions` | ✅ immutable ledger |
| `fraud_audit` | ✅ proximity and fraud event log |
| `waste_rates` | ✅ seeded with 15 material rates |
| `notifications` | ✅ existed before (no changes needed) |

## Edge Functions

| Function | Status |
|---|---|
| `verify_arrival` | File ready — needs `supabase functions deploy` |
| `daily_payout` | Not written yet |

---

## Priority Order to Finish

1. **Deploy `verify_arrival`** — 1 terminal command, unblocks driver arrival flow
2. **Wire wallet RPCs** (`hold` + `release`) — unblocks driver payout tracking
3. **Wire `record_order_transaction`** — completes the financial audit trail
4. **Wire VAT + expiry on listing creation** — completes marketplace correctness
5. **Write `daily_payout` Edge Function** — final payout automation
6. **Admin approval flow for chemicals** — last feature gate
