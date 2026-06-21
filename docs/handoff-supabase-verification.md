# Supabase Live Verification & Hardening — Execution Plan

> **Project:** `bbpleeddaquwwvexzmdc` (Dwaar, ap-southeast-1)
> **Repo:** `C:\Users\dawas\dwaar`, branch `mohammad`
> **Status:** Code done (flutter analyze ✅, 304/304 tests ✅). Execute phases in order.

---

## Already verified — skip these

- All 6 tables exist and respond to anon-key REST probes.
- `orders` RLS blocks unauthenticated inserts with `42501` (auth error, not schema error).
- PostGIS columns live: `orders.pickup_lat/lng/dropoff_lat/lng`, `profiles.location_lat/lng`.
- `.env.local` targets `bbpleeddaquwwvexzmdc` with valid anon key.
- 304 Flutter tests pass; no secrets in diff.

---

## Phase 0 — Pre-flight (run FIRST)

These catch problems the advisor checks miss.

### 0.1 Find unindexed FK columns

```sql
SELECT
  conrelid::regclass AS table_name,
  a.attname          AS fk_column
FROM pg_constraint c
JOIN pg_attribute a
  ON a.attrelid = c.conrelid
 AND a.attnum   = ANY(c.conkey)
WHERE c.contype = 'f'
  AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid
      AND a.attnum = ANY(i.indkey)
  )
ORDER BY table_name, fk_column;
```

**Blocker:** any row where `table_name='orders'` and `fk_column IN ('supplier_id','driver_id','company_id')`.
If any appear, apply them now via 0.2 — don't proceed to Phase 1 without fixing these.

### 0.2 Add missing FK indexes (run only for rows returned above)

```sql
CREATE INDEX IF NOT EXISTS orders_supplier_id_idx         ON public.orders (supplier_id);
CREATE INDEX IF NOT EXISTS orders_driver_id_idx           ON public.orders (driver_id);
CREATE INDEX IF NOT EXISTS orders_company_id_idx          ON public.orders (company_id);
CREATE INDEX IF NOT EXISTS driver_locations_order_id_idx  ON public.driver_locations (order_id);
CREATE INDEX IF NOT EXISTS driver_locations_driver_id_idx ON public.driver_locations (driver_id);
CREATE INDEX IF NOT EXISTS chat_messages_room_id_idx      ON public.chat_messages (room_id);
CREATE INDEX IF NOT EXISTS chat_messages_sender_id_idx    ON public.chat_messages (sender_id);
CREATE INDEX IF NOT EXISTS notifications_recipient_id_idx ON public.notifications (recipient_id);
```

### 0.3 Audit RLS policies for raw auth.uid() (100x performance bug)

```sql
SELECT schemaname, tablename, policyname, qual
FROM pg_policies
WHERE qual LIKE '%auth.uid()%'
  AND qual NOT LIKE '%(select auth.uid())%';
```

Any row returned = a policy calls `auth.uid()` once per row instead of once per query.
Record the affected policies — they get patched in `00005_security_hardening.sql` (Phase 3).

### 0.4 Verify status transition trigger handles NULL (INSERT guard)

```sql
SELECT prosrc FROM pg_proc WHERE proname = 'enforce_order_status_transition';
```

Look for `TG_OP = 'INSERT'` or `COALESCE(OLD.status, '')` near the top of the function body.
If the guard is missing, every new order INSERT will fire the transition check against `OLD=NULL` and error.
Add the fix in `00005_security_hardening.sql`.

### 0.5 Verify wallet RPCs use transaction-level advisory locks

```sql
SELECT prosrc FROM pg_proc
WHERE proname IN ('driver_wallet_hold', 'driver_wallet_release');
```

Look for `pg_try_advisory_xact_lock` (correct — survives pgBouncer transaction mode).
If you see `pg_try_advisory_lock` (session-level), add a fix in `00005_security_hardening.sql`.

---

## Phase 1 — Verify schema state

### 1.1 List applied migrations

```
list_migrations(project_id="bbpleeddaquwwvexzmdc")
```

Expect all 10:
```
00001_initial_schema
00002_add_user_categories
00003_chat
00004_postgis_compat
20260519_security_tables
20260522_driver_locations
20260522_marketplace_limits
20260522_transaction_commission
20260522_vehicle_type
20260522_wallet_functions
```

Missing any → apply from `supabase/migrations/<name>.sql`.

### 1.2 PostGIS triggers exist

```sql
SELECT tgname, tgrelid::regclass, tgenabled
FROM pg_trigger
WHERE tgname IN ('trg_sync_orders_geography','trg_sync_profiles_geography');
```

Expect 2 rows, `tgenabled='O'`. Missing → re-apply `00004_postgis_compat.sql`.

### 1.3 verify_driver_arrival RPC exists

```sql
SELECT proname, prosrc IS NOT NULL AS has_body
FROM pg_proc WHERE proname = 'verify_driver_arrival';
```

Expect 1 row, `has_body=true`.

### 1.4 Realtime publication membership

```sql
SELECT tablename FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;
```

Expect at minimum: `chat_messages`, `driver_locations`, `orders`.

### 1.5 Advisor checks

```
get_advisors(project_id="bbpleeddaquwwvexzmdc", type="security")
get_advisors(project_id="bbpleeddaquwwvexzmdc", type="performance")
```

Known-acceptable: `auto_confirm_user` warning (Phase 3 fixes it), FK index warnings (Phase 0 fixes them).
Any new critical warning → assess before continuing.

---

## Phase 2 — Authenticated smoke tests

Use synthetic UUIDs — no real Auth users needed for SQL-level testing.

```
SUPPLIER_ID = 00000000-0000-0000-0000-000000000001
DRIVER_ID   = 00000000-0000-0000-0000-000000000002
```

### 2.1 Insert test profiles

```sql
INSERT INTO public.profiles (auth_id, name, phone, role)
VALUES
  ('00000000-0000-0000-0000-000000000001','Test Supplier','+962799900001','supplier'),
  ('00000000-0000-0000-0000-000000000002','Test Driver',  '+962799900002','driver')
ON CONFLICT (auth_id) DO NOTHING
RETURNING auth_id, name, role;
```

### 2.2 PostGIS trigger test — critical

```sql
INSERT INTO public.orders (
  type, status, supplier_id, waste_types, pickup_target,
  pickup_lat, pickup_lng, is_marketplace_shared, requires_rider
) VALUES (
  'pickup','pending',
  '00000000-0000-0000-0000-000000000001',
  ARRAY['plastic'],'company',
  31.9539, 35.9106, false, false
)
RETURNING id, pickup_lat, pickup_lng,
  ST_AsText(pickup_location) AS pickup_geography;
```

**Pass:** `pickup_geography = 'POINT(35.9106 31.9539)'`
**Fail:** `pickup_geography = NULL` → stop, trigger is broken, re-check Phase 1.2.

> Save the returned `id` — use it as `$ORDER_ID` in the remaining steps.

### 2.3 Full order lifecycle

```sql
-- Accept
UPDATE public.orders
SET status='accepted',
    driver_id='00000000-0000-0000-0000-000000000002',
    accepted_at=now()
WHERE id='$ORDER_ID';

-- Arrive at pickup
UPDATE public.orders SET status='arrivedAtPickup' WHERE id='$ORDER_ID';
SELECT status, arrived_at_pickup_at FROM public.orders WHERE id='$ORDER_ID';
-- Pass: arrived_at_pickup_at IS NOT NULL

-- In transit
UPDATE public.orders SET status='inTransit', in_transit_at=now() WHERE id='$ORDER_ID';

-- Arrive at dropoff
UPDATE public.orders SET status='arrivedAtDropoff' WHERE id='$ORDER_ID';

-- Complete
UPDATE public.orders SET status='completed', completed_at=now() WHERE id='$ORDER_ID';

-- Invalid transition must be rejected
UPDATE public.orders SET status='pending' WHERE id='$ORDER_ID';
-- Pass: ERROR from enforce_order_status_transition
```

### 2.4 verify_driver_arrival RPC

```sql
INSERT INTO public.driver_locations (driver_id, order_id, lat, lng)
VALUES ('00000000-0000-0000-0000-000000000002','$ORDER_ID',31.9539,35.9106)
ON CONFLICT (driver_id, order_id) DO UPDATE SET lat=EXCLUDED.lat, lng=EXCLUDED.lng;

SELECT verify_driver_arrival('$ORDER_ID', 31.9539, 35.9106);  -- expect: true
SELECT verify_driver_arrival('$ORDER_ID', 32.0000, 36.0000);  -- expect: false
SELECT count(*) FROM public.fraud_audit WHERE order_id='$ORDER_ID';  -- expect: 1
```

### 2.5 Chat round-trip

```sql
INSERT INTO public.chat_messages (room_id, sender_id, sender_name, sender_role, content)
VALUES ('$ORDER_ID','00000000-0000-0000-0000-000000000001','Test Supplier','supplier','مرحبا');

SELECT id, content, is_read FROM public.chat_messages WHERE room_id='$ORDER_ID';
-- Expect: 1 row, is_read=false

UPDATE public.chat_messages SET is_read=true
WHERE room_id='$ORDER_ID'
  AND sender_id <> '00000000-0000-0000-0000-000000000002';
```

### 2.6 Cleanup

```sql
DELETE FROM public.chat_messages    WHERE room_id='$ORDER_ID';
DELETE FROM public.driver_locations WHERE order_id='$ORDER_ID';
DELETE FROM public.fraud_audit      WHERE order_id='$ORDER_ID';
DELETE FROM public.orders           WHERE id='$ORDER_ID';
DELETE FROM public.profiles
  WHERE auth_id IN (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002'
  );
```

---

## Phase 3 — Security hardening

Write and apply `supabase/migrations/00005_security_hardening.sql`.

### Fixes included

| # | Fix | Why |
|---|-----|-----|
| 3.1 | Delete `verify_arrival` Edge Function dir from repo | Dead code + IDOR (trusts client-supplied driverId, uses service-role key) |
| 3.2 | Redefine `nearby_drivers()` without `fcm_token` | Any authed user can harvest all driver push tokens + names + locations |
| 3.3 | Drop `auto_confirm_user` trigger | Force-confirms every email at creation — defeats email verification |
| 3.4 | Patch RLS policies to `(select auth.uid())` pattern | Raw `auth.uid()` called per row = 100x perf cost at scale |
| 3.5 | Add missing FK indexes | Prevent full table scans on every order query and realtime filter |

### 00005_security_hardening.sql

```sql
-- ──────────────────────────────────────────────────────────────────────────────
-- 00005_security_hardening.sql
-- Applied: 2026-06-21
-- ──────────────────────────────────────────────────────────────────────────────

-- 3.3: Drop auto-confirm (do first; RLS changes below don't depend on it)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS auto_confirm_user();

-- 3.2: Redefine nearby_drivers() — strip fcm_token
CREATE OR REPLACE FUNCTION public.nearby_drivers(
  lat       FLOAT,
  lng       FLOAT,
  radius_km FLOAT DEFAULT 10
) RETURNS TABLE (id UUID, name TEXT, distance_m FLOAT)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT
    p.auth_id AS id,
    p.name,
    ST_Distance(p.location, ST_MakePoint(lng, lat)::geography) AS distance_m
  FROM public.profiles p
  WHERE p.role = 'driver'
    AND p.is_available = true
    AND p.location IS NOT NULL
    AND ST_DWithin(p.location, ST_MakePoint(lng, lat)::geography, radius_km * 1000)
  ORDER BY distance_m ASC
  LIMIT 20;
$$;

-- 3.4: RLS policy pattern fix
-- (Fill in actual policy names after running Phase 0.3 query.
--  Template — repeat this block for each affected policy:)
-- DROP POLICY IF EXISTS <name> ON public.<table>;
-- CREATE POLICY <name> ON public.<table>
--   FOR <cmd> [TO authenticated] USING ((select auth.uid()) = <col>);

-- 3.5: FK indexes (idempotent)
CREATE INDEX IF NOT EXISTS orders_supplier_id_idx         ON public.orders (supplier_id);
CREATE INDEX IF NOT EXISTS orders_driver_id_idx           ON public.orders (driver_id);
CREATE INDEX IF NOT EXISTS orders_company_id_idx          ON public.orders (company_id);
CREATE INDEX IF NOT EXISTS driver_locations_order_id_idx  ON public.driver_locations (order_id);
CREATE INDEX IF NOT EXISTS driver_locations_driver_id_idx ON public.driver_locations (driver_id);
CREATE INDEX IF NOT EXISTS chat_messages_room_id_idx      ON public.chat_messages (room_id);
CREATE INDEX IF NOT EXISTS chat_messages_sender_id_idx    ON public.chat_messages (sender_id);
CREATE INDEX IF NOT EXISTS notifications_recipient_id_idx ON public.notifications (recipient_id);
```

**3.1 action (repo only, no SQL):**
```
Delete: supabase/functions/verify_arrival/ (if it exists)
Commit with message: "chore: remove dead verify_arrival edge function (IDOR risk)"
```

**3.3 rollback:** if signup breaks (OTP succeeds but session is null), re-apply the
`auto_confirm_user` function + trigger from `20260519_security_tables.sql`.

---

## Phase 4 — Fix drift

Only needed if Phase 1 or 2 found failures.

| Finding | Action |
|---------|--------|
| Missing migration | Apply from `supabase/migrations/<name>.sql` |
| Trigger missing | Re-apply its migration file |
| Transition trigger missing NULL guard | Patch in `00005_security_hardening.sql` |
| Wallet RPCs use session locks | Rewrite to `pg_try_advisory_xact_lock` in `00005_security_hardening.sql` |

Never edit applied migration files. All fixes go into `00005_` or a new `00005b_` file.

---

## Phase 5 — Final verification

```
get_advisors(project_id="bbpleeddaquwwvexzmdc", type="security")
get_advisors(project_id="bbpleeddaquwwvexzmdc", type="performance")
```

Re-run Phase 0.1 — expect zero rows on `orders`, `chat_messages`, `driver_locations`.
Re-run Phase 0.3 — expect zero rows.

**GO criteria (all must be true):**
- [ ] All 10 migrations applied
- [ ] Both PostGIS triggers exist and enabled
- [ ] PostGIS smoke test passes (geography column populated from numeric lat/lng)
- [ ] Invalid status transition is rejected
- [ ] `auto_confirm_user` dropped
- [ ] `nearby_drivers()` returns no `fcm_token` column
- [ ] FK indexes exist on `orders.supplier_id/driver_id/company_id`
- [ ] No RLS policy uses raw `auth.uid()`
- [ ] `verify_driver_arrival` returns true/false correctly
- [ ] Fraud audit row inserted on failed proximity check

---

## Reference: 10 migration files

```
supabase/migrations/
  00001_initial_schema.sql
  00002_add_user_categories.sql
  00003_chat.sql
  00004_postgis_compat.sql
  20260519_security_tables.sql
  20260522_driver_locations.sql
  20260522_marketplace_limits.sql
  20260522_transaction_commission.sql
  20260522_vehicle_type.sql
  20260522_wallet_functions.sql
```

## Reference: Dart ↔ SQL contracts

| Dart | SQL | Contract |
|------|-----|---------|
| `order_supabase_ext.dart:toSupabaseMap` | `orders` | Writes `type`, `pickup_lat/lng`, conditional columns |
| `supabase_auth_repository.dart` | `profiles` | Inserts `auth_id`, reads `.eq('auth_id', uid)` |
| `supabase_order_repository.dart:verifyArrival` | `verify_driver_arrival(text, float8, float8)→bool` | `rpc('verify_driver_arrival', {p_order_id, p_lat, p_lng})` |
| `supabase_wallet_repository.dart` | `driver_wallet_hold/release` RPCs | `rpc('driver_wallet_hold', {p_order_id, p_amount})` |
| `supabase_chat_repository.dart` | `chat_messages` | `.stream().eq('room_id', orderId)` |
| `location_publisher.dart:86` | `driver_locations` | Upserts `{driver_id, order_id, lat, lng, updated_at}` |
