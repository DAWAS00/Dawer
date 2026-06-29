---
description: "Apply Phase 1 Supabase schema migrations for Dwaar: create hubs table, add partner fields to users, seed starter hubs. Includes pre-flight analysis, migration authoring, cloud apply, and pinpoint verification."
mode: agent
tools:
  - codebase
  - editFiles
  - runCommands
  - problems
  - search
---

# Phase 1 — Supabase Schema Migration (Dwaar)

You are a senior Supabase/PostgreSQL engineer with deep expertise in schema design, Row-Level Security policies, and PostGIS. You are working on the **Dwaar (دوّر)** recycling logistics project — a Flutter mobile app backed by a Supabase project at ref `bpzuwwbtqqrpohfqjcuo`. Your job is to author, apply, and verify the three Phase 1 migrations that bridge the Flutter app and the admin dashboard through a shared Supabase instance.

**You have full access to the workspace and terminal. You do not need to ask permission before reading files, running commands, or creating migration files — proceed directly.**

---

## Context You Must Read First

Before doing anything else, read these files to understand the current schema state:

1. `supabase/migrations/` — all existing migration files, in order
2. `docs/codebase-guide/08-supabase-backend.md` — full schema reference
3. `devPlans/2026-06-26-supabase-integration-plan.md` — the Phase 1 spec (Tasks 1–3)

Then inspect the live schema state:

```bash
supabase db pull --schema public 2>&1 | head -100
```

If that fails (not linked), run:

```bash
supabase link --project-ref bpzuwwbtqqrpohfqjcuo
```

---

## Pre-flight Analysis

Run all of these checks **before creating or applying any migration**. Report each result clearly.

### 1. Supabase CLI available?

```bash
supabase --version
```

Expected: `1.x.x` or higher. If not found: `npm install -g supabase` or `brew install supabase/tap/supabase`.

### 2. Project linked?

```bash
supabase status
```

Expected output includes `API URL: https://bpzuwwbtqqrpohfqjcuo.supabase.co`. If not linked, run `supabase link --project-ref bpzuwwbtqqrpohfqjcuo`.

### 3. Do the migrations already exist?

```bash
ls supabase/migrations/ | grep 20260626
```

Report which of these already exist:
- `20260626_hubs.sql`
- `20260626_partner_fields.sql`
- `20260626_seed_hubs.sql`

**Do not recreate a file that already exists.** Skip that migration step and note it as already present.

### 4. Is the `hubs` table already live?

```bash
supabase db execute --sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='hubs';"
```

If count = 1, the hubs table already exists — skip `20260626_hubs.sql` but still check whether the seed data is present.

### 5. Do partner fields already exist on `public.users`?

```bash
supabase db execute --sql "SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='contract_tier';"
```

If a row is returned, partner fields are already present — skip `20260626_partner_fields.sql`.

### 6. Is the `supabase/config.toml` pointing at the right project?

```bash
cat supabase/config.toml | grep project_id
```

Expected: `project_id = "bpzuwwbtqqrpohfqjcuo"`. If it shows a different ID, stop and report — do not apply migrations to the wrong project.

### Pre-flight report

After running all checks, output a summary table:

| Check | Status | Action |
|---|---|---|
| Supabase CLI version | ✅ / ❌ | ... |
| Project linked | ✅ / ❌ | ... |
| 20260626_hubs.sql exists | ✅ / ⬜ skipping | ... |
| 20260626_partner_fields.sql exists | ✅ / ⬜ skipping | ... |
| 20260626_seed_hubs.sql exists | ✅ / ⬜ skipping | ... |
| hubs table already live | ✅ / ⬜ not yet | ... |
| contract_tier column exists | ✅ / ⬜ not yet | ... |

**Only proceed to migration authoring if CLI is available and project is linked.**

---

## Migration Authoring

Create only the migration files that do **not** already exist (per pre-flight check 3).

### Migration 1: `supabase/migrations/20260626_hubs.sql`

```sql
-- ─── Phase 1: Hubs table ──────────────────────────────────────────────────────
-- Physical collection points where drivers drop off recyclable material.
-- The admin dashboard manages (INSERT/UPDATE/DELETE) these records via the
-- service-role key. The Flutter app reads them (SELECT) for driver dropoff
-- targeting. Anon/authenticated users cannot write.

CREATE TABLE IF NOT EXISTS public.hubs (
  id                 UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT         NOT NULL,
  address            TEXT         NOT NULL,
  lat                NUMERIC(9,6) NOT NULL,
  lng                NUMERIC(9,6) NOT NULL,
  active             BOOLEAN      NOT NULL DEFAULT true,
  capacity_kg        NUMERIC      NOT NULL DEFAULT 1000,
  current_load       JSONB        NOT NULL
                                  DEFAULT '{"cookingOil":0,"plastic":0,"paper":0,"electronics":0}'::jsonb,
  schedule           TEXT         NOT NULL DEFAULT 'weekly'
                                  CHECK (schedule IN ('weekly', 'monthly')),
  next_shipment_date DATE,
  last_shipment_date DATE,
  status             TEXT         NOT NULL DEFAULT 'collecting'
                                  CHECK (status IN ('collecting', 'ready', 'shipped')),
  created_at         TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.hubs ENABLE ROW LEVEL SECURITY;

-- Any authenticated user (driver, supplier, recyclingCo) can read active hubs.
-- INSERT / UPDATE / DELETE: no policy = only service_role (dashboard) can write.
CREATE POLICY IF NOT EXISTS "hubs_select_authenticated"
  ON public.hubs
  FOR SELECT
  TO authenticated
  USING (true);

-- Add to realtime so app can subscribe to hub status changes
ALTER PUBLICATION supabase_realtime ADD TABLE public.hubs;
```

### Migration 2: `supabase/migrations/20260626_partner_fields.sql`

```sql
-- ─── Phase 1: B2B Partner contract fields on public.users ─────────────────────
-- Adds contract management columns used by recyclingCo users.
-- These are read and written by the admin dashboard's Partner management view.
-- IF NOT EXISTS guards make this migration re-runnable safely.

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS contract_tier       TEXT    NOT NULL DEFAULT 'free'
                                               CHECK (contract_tier IN ('free','basic','pro','enterprise')),
  ADD COLUMN IF NOT EXISTS renewal_date        DATE,
  ADD COLUMN IF NOT EXISTS billing_cycle       TEXT    DEFAULT 'monthly'
                                               CHECK (billing_cycle IN ('monthly','annual')),
  ADD COLUMN IF NOT EXISTS green_points        INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS custom_price_jd     NUMERIC,
  ADD COLUMN IF NOT EXISTS contract_notes      TEXT,
  ADD COLUMN IF NOT EXISTS last_certificate_download DATE,
  ADD COLUMN IF NOT EXISTS referred_by         TEXT;

-- Fast lookup for dashboard's partner list query
CREATE INDEX IF NOT EXISTS users_recycling_co_idx
  ON public.users (role, created_at DESC)
  WHERE role = 'recyclingCo';
```

### Migration 3: `supabase/migrations/20260626_seed_hubs.sql`

```sql
-- ─── Phase 1: Seed starter hubs ───────────────────────────────────────────────
-- Migrates the 4 hubs that were hardcoded in the dashboard's INITIAL_HUBS
-- constant into the live Supabase hubs table.
-- ON CONFLICT DO NOTHING makes this safe to re-run if partially applied.

-- Temporarily disable RLS to allow seed insert via migration runner
ALTER TABLE public.hubs DISABLE ROW LEVEL SECURITY;

INSERT INTO public.hubs
  (name, address, lat, lng, active, capacity_kg, current_load, schedule, next_shipment_date, last_shipment_date, status)
VALUES
  (
    'Hub Al-Sweifieh',
    'Sweifieh Commercial District, Amman',
    31.944000, 35.871000,
    true, 1200,
    '{"cookingOil":312,"plastic":156,"paper":94,"electronics":37}'::jsonb,
    'weekly', '2026-06-27', '2026-06-20', 'collecting'
  ),
  (
    'Hub Downtown',
    'Al-Balad, Downtown Amman',
    31.952000, 35.934000,
    true, 800,
    '{"cookingOil":520,"plastic":88,"paper":42,"electronics":18}'::jsonb,
    'weekly', '2026-06-27', '2026-06-20', 'ready'
  ),
  (
    'Hub Jubaiha',
    'Jubaiha University District',
    32.001000, 35.868000,
    true, 1500,
    '{"cookingOil":180,"plastic":410,"paper":220,"electronics":95}'::jsonb,
    'monthly', '2026-07-01', '2026-06-01', 'collecting'
  ),
  (
    'Hub Tabarbour',
    'Tabarbour Industrial Zone',
    32.015000, 35.922000,
    false, 2000,
    '{"cookingOil":0,"plastic":0,"paper":0,"electronics":0}'::jsonb,
    'monthly', NULL, NULL, 'collecting'
  )
ON CONFLICT DO NOTHING;

-- Re-enable RLS after seed
ALTER TABLE public.hubs ENABLE ROW LEVEL SECURITY;
```

---

## Apply to Cloud

Apply the migrations in order. **Stop immediately if any step errors — do not apply subsequent migrations.**

```bash
supabase db push
```

If `db push` is unavailable (older CLI), apply individually:

```bash
supabase db execute --file supabase/migrations/20260626_hubs.sql
supabase db execute --file supabase/migrations/20260626_partner_fields.sql
supabase db execute --file supabase/migrations/20260626_seed_hubs.sql
```

Expected output per file: no errors, `Done.` or `Success`.

---

## Pinpoint Verification

Run every one of these SQL checks against the live Supabase project. Each must pass before the Phase 1 migration is considered complete.

### V1 — Hubs table structure

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'hubs'
ORDER BY ordinal_position;
```

**Expected:** 13 columns — `id`, `name`, `address`, `lat`, `lng`, `active`, `capacity_kg`, `current_load`, `schedule`, `next_shipment_date`, `last_shipment_date`, `status`, `created_at`.

### V2 — Hubs RLS enabled

```sql
SELECT relrowsecurity
FROM pg_class
WHERE relname = 'hubs' AND relnamespace = 'public'::regnamespace;
```

**Expected:** `t` (true).

### V3 — Hubs RLS select policy exists

```sql
SELECT policyname, cmd, roles
FROM pg_policies
WHERE tablename = 'hubs';
```

**Expected:** at least one row with `cmd = 'SELECT'` and `roles = '{authenticated}'`.

### V4 — Partner columns on users

```sql
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'users'
  AND column_name IN (
    'contract_tier','renewal_date','billing_cycle',
    'green_points','custom_price_jd','contract_notes',
    'last_certificate_download','referred_by'
  )
ORDER BY column_name;
```

**Expected:** exactly 8 rows returned.

### V5 — RecyclingCo index created

```sql
SELECT indexname
FROM pg_indexes
WHERE tablename = 'users' AND indexname = 'users_recycling_co_idx';
```

**Expected:** 1 row.

### V6 — Seed data present

```sql
SELECT name, active, status FROM public.hubs ORDER BY created_at;
```

**Expected:** 4 rows — Hub Al-Sweifieh (active, collecting), Hub Downtown (active, ready), Hub Jubaiha (active, collecting), Hub Tabarbour (inactive, collecting).

### V7 — RLS blocks unauthenticated writes (security test)

```sql
-- Simulate anon insert attempt — must fail
SET ROLE anon;
INSERT INTO public.hubs (name, address, lat, lng) VALUES ('Bad Hub', 'Test', 0, 0);
RESET ROLE;
```

**Expected:** `ERROR: new row violates row-level security policy for table "hubs"` — confirming only service_role can write.

### V8 — Hubs readable by authenticated user (RLS positive test)

```sql
-- Simulate a driver user reading hubs — must succeed
SET LOCAL ROLE authenticated;
SELECT id, name, active FROM public.hubs LIMIT 1;
RESET ROLE;
```

**Expected:** 1 row returned (the first hub).

---

## Verification Report

After running all 8 checks, output this table:

| Check | Query | Result | Pass? |
|---|---|---|---|
| V1 — hubs columns | 13 columns | [actual count] | ✅/❌ |
| V2 — RLS enabled | relrowsecurity = t | [actual] | ✅/❌ |
| V3 — SELECT policy | cmd=SELECT, role=authenticated | [actual] | ✅/❌ |
| V4 — partner columns | 8 columns | [actual count] | ✅/❌ |
| V5 — recyclingCo index | users_recycling_co_idx | [found/not found] | ✅/❌ |
| V6 — seed rows | 4 hubs | [actual count] | ✅/❌ |
| V7 — anon write blocked | RLS error | [error/no error] | ✅/❌ |
| V8 — auth read succeeds | 1 row | [row/no row] | ✅/❌ |

**All 8 must pass before Phase 1 is declared complete.**

If any check fails, diagnose the failure before committing. Common root causes:
- `V2/V3 fail` — `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` did not run; re-run `20260626_hubs.sql`.
- `V4 fail` — `IF NOT EXISTS` guard may have prevented column add if column existed with a different type; inspect with `\d public.users`.
- `V6 fail` — Seed file `ON CONFLICT DO NOTHING` may have silently skipped rows if a unique constraint is missing; check for duplicate name constraint.
- `V7 fail` (no error) — RLS is not enabled; re-check V2.

---

## Git Commit

Once all 8 verification checks pass:

```bash
cd C:\Users\dawas\dwaar
git add supabase/migrations/20260626_hubs.sql \
        supabase/migrations/20260626_partner_fields.sql \
        supabase/migrations/20260626_seed_hubs.sql
git commit -m "feat(db): Phase 1 schema — hubs table, partner fields, hub seed data

- Adds public.hubs table with RLS (auth read-only, service_role write)
- Adds 8 B2B partner contract columns to public.users
- Seeds 4 starter hubs from former dashboard constants
- All 8 pinpoint verification checks passed

Part of the App ↔ Supabase ↔ Dashboard integration.
See devPlans/2026-06-26-supabase-integration-plan.md Tasks 1-3."
```

---

## What Phase 1 Does NOT Touch

Confirm these are unchanged after the migration:

- ❌ No changes to the Flutter app Dart code
- ❌ No changes to the dashboard TypeScript/React code  
- ❌ No changes to existing migration files (`00001_initial_schema.sql` etc.)
- ❌ No changes to Edge Functions
- ❌ No changes to existing RLS policies on `orders`, `users`, or `notifications`

The only changes are additive: a new table, new columns, new index, new seed rows.
