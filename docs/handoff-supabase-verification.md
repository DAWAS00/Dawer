# Supabase Live Verification & Hardening — Handoff Plan

> **For:** Claude (or any agent) with the Supabase MCP connected.
> **Project:** `bbpleeddaquwwvexzmdc` (Dwaar, ap-southeast-1)
> **Repo:** `C:\Users\dawas\dwaar`, branch `mohammad`
> **Author:** prior session that restored the backend + fixed review findings.

## Context (read this first)

The Dwaar Flutter app's Supabase backend was restored and reconciled in prior
sessions. The **code is done and verified** (`flutter analyze` clean,
`flutter test` 306/306 pass). The **live DB has all tables and the key columns**
(already confirmed via PostgREST probes with the anon key). What remains is the
**live verification that needs authenticated/MCP access**, plus **3 security
hardening fixes** flagged in code review.

This plan is what a Claude session with the Supabase MCP should execute. Do the
phases in order — stop on the first failure and fix before continuing.

---

## What's ALREADY verified (don't redo these)

- All 6 tables exist on the live DB and respond to anon-key REST probes:
  `profiles, orders, chat_messages, driver_locations, driver_wallet, notifications`.
- `orders` accepts the exact JSON shape `lib/data/models/order_supabase_ext.dart`
  produces — an unauthenticated insert returns `42501 RLS policy violation`
  (auth block), **not** a schema/type error.
- The PostGIS fix columns are live: `orders.pickup_lat/pickup_lng/dropoff_lat/dropoff_lng`
  and `profiles.location_lat/location_lng` all exist (HTTP 200 on column probe).
- `.env.local` targets `bbpleeddaquwwvexzmdc` with a valid anon key.
- Code compiles; 306 tests pass; no secrets in the diff.

## What's NOT yet verified (the open work)

1. Are all 10 migrations **actually applied** (not just the tables)? Run `list_migrations`.
2. Do the **PostGIS triggers** exist (not just the columns)? A column existing doesn't mean `trg_sync_orders_geography` was created.
3. Does the `verify_driver_arrival` **RPC** exist and work? (Defined in `20260522_driver_locations.sql`.)
4. Does an **authenticated** full round-trip work (signup → order → accept → chat)?
5. Are the 3 security issues still present? (They are, in the repo SQL — see Phase 3.)

---

## Phase 1 — Verify schema state (read-only)

For each, run the MCP tool and compare against the repo's `supabase/migrations/`.

### 1.1 List applied migrations
```
list_migrations(project_id="bbpleeddaquwwvexzmdc")
```
**Expect:** all 10 in this order:
```
00001_initial_schema, 00002_add_user_categories, 00003_chat,
00004_postgis_compat, 20260519_security_tables, 20260522_driver_locations,
20260522_marketplace_limits, 20260522_transaction_commission,
20260522_vehicle_type, 20260522_wallet_functions
```
If any are missing, apply them via `apply_migration` (read the file content from
`supabase/migrations/<name>.sql` in the repo).

### 1.2 Verify the PostGIS triggers exist
```sql
-- via execute_sql
SELECT tgname, tgrelid::regclass, tgenabled
FROM pg_trigger
WHERE tgname IN ('trg_sync_orders_geography', 'trg_sync_profiles_geography');
```
**Expect:** 2 rows, both `tgenabled = 'O'` (origin). If missing, re-apply
`00004_postgis_compat.sql` (it's idempotent — uses `DROP TRIGGER IF EXISTS`).

### 1.3 Verify `verify_driver_arrival` RPC exists
```sql
SELECT proname, prosrc IS NOT NULL AS has_body
FROM pg_proc WHERE proname = 'verify_driver_arrival';
```
**Expect:** 1 row, `has_body = true`. If missing, apply the function from
`20260522_driver_locations.sql` (the `CREATE OR REPLACE FUNCTION verify_driver_arrival` block).

### 1.4 Verify realtime publication membership
```sql
SELECT tablename FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;
```
**Expect at minimum:** `orders`, `chat_messages`, `driver_locations`. If any
missing, run `ALTER PUBLICATION supabase_realtime ADD TABLE public.<table>;`
(note: this errors if already a member — wrap in a DO block or check first).

### 1.5 Run advisor checks
```
get_advisors(project_id="bbpleeddaquwwvexzmdc", type="security")
get_advisors(project_id="bbpleeddaquwwvexzmdc", type="performance")
```
Triage the output. **Expected known warnings** (not blockers): the `auto_confirm_user`
trigger (Phase 3 fixes it) and possibly missing indexes on FK columns. Report
anything critical.

---

## Phase 2 — Authenticated smoke tests

These need a real user. **Create a test user first**, then run inserts as them.

### 2.1 Create a test supplier + driver pair
Use the Supabase dashboard Auth (or `admin.createUser` via MCP if available) to
create two test users with **phone OTP disabled** (or use a test phone like
`+962790000001` if the mock-OTP pattern is active):

- Supplier: phone `+962799900001`, role `supplier`
- Driver: phone `+962799900002`, role `driver`

After each signup, verify a `profiles` row was created:
```sql
SELECT auth_id, name, phone, role FROM public.profiles ORDER BY created_at DESC LIMIT 2;
```

### 2.2 Test the PostGIS trigger (THE critical test)
As the supplier (authenticated), insert an order and verify the geography column
gets populated from the numeric lat/lng by the trigger:
```sql
-- Insert with numeric lat/lng (what the Dart ext sends)
INSERT INTO public.orders (
  type, status, supplier_id, waste_types, pickup_target,
  pickup_lat, pickup_lng, is_marketplace_shared, requires_rider
) VALUES (
  'pickup', 'pending',
  (SELECT auth_id FROM profiles WHERE phone='+962799900001'),
  ARRAY['plastic'], 'company',
  31.9539, 35.9106, false, false
)
RETURNING id, pickup_lat, pickup_lng,
  ST_AsText(pickup_location) AS pickup_geography;
```
**Success:** returns a row where `pickup_geography` = `POINT(35.9106 31.9539)`
(not null). This confirms the trigger works end-to-end. **If `pickup_location`
is null, the trigger is broken** — re-check Phase 1.2.

### 2.3 Test the full order lifecycle
```sql
-- 1. Supplier creates order (done in 2.2 — capture the returned id)
-- 2. Driver accepts
UPDATE public.orders SET status='accepted', driver_id='<driver_auth_id>',
  accepted_at=now() WHERE id='<order_id_from_2.2>';

-- 3. Driver arrives at pickup (trigger should auto-stamp arrived_at_pickup_at)
UPDATE public.orders SET status='arrivedAtPickup' WHERE id='<order_id>';
SELECT status, arrived_at_pickup_at FROM public.orders WHERE id='<order_id>';
-- Expect: arrived_at_pickup_at is NOT null (trigger auto-stamps it)

-- 4. Invalid transition should be REJECTED by enforce_order_status_transition
UPDATE public.orders SET status='completed' WHERE id='<order_id>';
-- Expect: ERROR — can't skip accepted→inTransit→arrivedAtDropoff
```

### 2.4 Test `verify_driver_arrival` RPC
First seed a `driver_locations` row (the driver must have published GPS):
```sql
INSERT INTO public.driver_locations (driver_id, order_id, lat, lng)
VALUES ('<driver_auth_id>', '<order_id>', 31.9539, 35.9106);
-- Then call the RPC with a target near that point
SELECT verify_driver_arrival('<order_id>', 31.9539, 35.9106);
-- Expect: true (within 200m)

-- And a far target
SELECT verify_driver_arrival('<order_id>', 32.0000, 36.0000);
-- Expect: false + a row inserted into fraud_audit
SELECT count(*) FROM public.fraud_audit WHERE order_id='<order_id>';
```

### 2.5 Test chat round-trip
```sql
INSERT INTO public.chat_messages (room_id, sender_id, sender_name, sender_role, content)
VALUES ('<order_id>', '<supplier_auth_id>', 'Test Supplier', 'supplier', 'مرحبا');
SELECT id, content, is_read FROM public.chat_messages WHERE room_id='<order_id>';
-- Expect: 1 row

-- markRead equivalent (as the driver)
UPDATE public.chat_messages SET is_read=true
WHERE room_id='<order_id>' AND sender_id <> '<driver_auth_id>';
```

### 2.6 Cleanup test data
```sql
DELETE FROM public.chat_messages WHERE room_id LIKE '%<order_id>%';
DELETE FROM public.driver_locations WHERE order_id='<order_id>';
DELETE FROM public.fraud_audit WHERE order_id='<order_id>';
DELETE FROM public.orders WHERE id='<order_id>';
-- Leave the test profiles for reuse, or delete them
```

---

## Phase 3 — Security hardening (3 fixes from code review)

These are **confirmed real issues** in the repo SQL. Apply each as a new
migration (e.g., `00005_security_hardening.sql`) so the repo stays the source of
truth, AND apply to the live DB via `apply_migration`.

### 3.1 Delete the dead `verify_arrival` Edge Function
**Why:** It's dead code (the `verify_driver_arrival` RPC superseded it), AND it
has an IDOR — it trusts a client-supplied `driverId` parameter while using the
service-role key (bypasses RLS), so any authenticated user could verify arrival
against any driver's GPS.

**Action:** Delete `supabase/functions/verify_arrival/` from the repo, and run
```
# Via MCP or dashboard:
supabase functions delete verify_arrival --project-ref bbpleeddaquwwvexzmdc
```
(If the function was never deployed, just delete the directory.)

### 3.2 Stop leaking `fcm_token` from `nearby_drivers()`
**Why:** `nearby_drivers()` is `SECURITY DEFINER` (bypasses profiles RLS) and
returns `fcm_token` — any authenticated user can harvest every driver's push
token + name + location globally.

**Fix** (redefine the function without `fcm_token`):
```sql
CREATE OR REPLACE FUNCTION nearby_drivers(
  lat FLOAT, lng FLOAT, radius_km FLOAT DEFAULT 10
) RETURNS TABLE (id UUID, name TEXT, distance_m FLOAT)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT u.auth_id AS id,
         u.name,
         (ST_Distance(u.location, ST_MakePoint(lng, lat)::geography)) AS distance_m
  FROM public.profiles u
  WHERE u.role = 'driver'
    AND u.is_available = true
    AND u.location IS NOT NULL
    AND ST_DWithin(u.location, ST_MakePoint(lng, lat)::geography, radius_km * 1000)
  ORDER BY distance_m ASC
  LIMIT 20;
$$;
```
⚠️ **Verify the actual current function signature first** — read
`00001_initial_schema.sql` lines ~196-205 for the exact current definition, and
make sure the column names (`is_available`, `location`) match what's live before
redefining. If `nearby_drivers` isn't used by the Dart code (grep
`nearby_drivers` in `lib/`), this is lower priority but still worth fixing.

### 3.3 Drop the `auto_confirm_user` trigger
**Why:** It force-confirms every new account's email at creation — defeats email
verification entirely (anyone can sign up with a victim's email and own a
confirmed account).

**Fix:**
```sql
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS auto_confirm_user();
```
⚠️ **Caveat:** After dropping this, signup requires real email/OTP confirmation.
If the app's signup flow doesn't handle the "unverified" state gracefully, this
could block logins in dev. Check `lib/data/repositories/supabase_auth_repository.dart`
— `verifyOtp` already checks `response.session == null` before trusting the OTP,
so removing the trigger should be safe. But test signup after applying.

---

## Phase 4 — Fix anything found broken

If Phase 1 or 2 reveals a missing migration/column/RPC/trigger:
1. **First choice:** apply the existing repo migration file (read it from
   `supabase/migrations/` and pass its content to `apply_migration`).
2. **If the repo file is itself wrong:** fix the repo file first, commit it,
   then apply.
3. Keep migrations idempotent (`CREATE TABLE IF NOT EXISTS`, `DROP ... IF EXISTS`).

---

## Phase 5 — Final verification + report

After Phases 1-4, re-run:
```
get_advisors(type="security")
get_advisors(type="performance")
```
and confirm no new critical warnings.

Then report:
- ✅/❌ for each phase
- Any drift found between repo and live DB (and which side was fixed)
- The test user IDs created (for cleanup)
- Whether the app's signup→order→chat round-trip would now work end-to-end

---

## Reference: the 10 repo migration files (apply order)

```
supabase/migrations/
  00001_initial_schema.sql          # profiles, orders, notifications, transactions, RLS, triggers, storage
  00002_add_user_categories.sql     # profiles.categories
  00003_chat.sql                    # chat_messages + RLS + realtime
  00004_postgis_compat.sql          # numeric lat/lng cols + geography triggers (THE PostGIS fix)
  20260519_security_tables.sql      # fraud_audit, driver_wallet, wallet_transactions, arrival cols
  20260522_driver_locations.sql     # driver_locations + RLS + verify_driver_arrival RPC + realtime
  20260522_marketplace_limits.sql   # listing TTL + record_order_transaction RPC
  20260522_transaction_commission.sql # commission breakdown cols
  20260522_vehicle_type.sql         # vehicle_type enum + chemical permit + admin approval
  20260522_wallet_functions.sql     # driver_wallet_hold/release RPCs + auto-credit trigger
```

## Reference: key Dart ↔ SQL contracts

| Dart (file) | SQL object | Contract |
|---|---|---|
| `order_supabase_ext.dart:5` `toSupabaseMap` | `orders` table | Writes `type` (not `order_type`), `pickup_lat/lng` (not WKT), conditional columns |
| `supabase_auth_repository.dart` | `profiles` table | Inserts `auth_id`, reads `.eq('auth_id', uid)` |
| `supabase_order_repository.dart:163` `verifyArrival` | `verify_driver_arrival(text, float8, float8) → bool` | `rpc('verify_driver_arrival', {p_order_id, p_lat, p_lng})` |
| `supabase_wallet_repository.dart` | `driver_wallet_hold`/`release` RPCs | `rpc('driver_wallet_hold', {p_order_id, p_amount})` |
| `supabase_chat_repository.dart` | `chat_messages` table | `.stream().eq('room_id', orderId)`, insert with `room_id`/`sender_id` |
| `location_publisher.dart:86` | `driver_locations` table | Upserts `{driver_id, order_id, lat, lng, updated_at}` |

---

## Known follow-ups NOT in this plan (track separately)

- **Order ID reconciliation:** when Supabase generates a UUID for a new order,
  the Dart `AppOrderStore` may not capture it back (the ext only sends `id` if
  it's 36 chars). This affects `verifyArrival` matching client-side IDs vs server
  UUIDs. Bigger refactor; not a blocker for basic CRUD.
- **`markArrivedAtPickup` remote status desync:** `AppOrderStore` pushes
  `markInTransit` while local shows `arrivedAtPickup`. UI flicker risk.
- **Migration idempotency polish:** bare `CREATE TYPE/POLICY/TRIGGER` aren't
  re-runnable. Fine for first-apply; matters if iterating locally.
