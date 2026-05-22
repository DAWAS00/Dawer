# Supabase Setup: Driver Live Location Tracking

## Overview
These steps activate the `driver_locations` table and real-time tracking pipeline.
All SQL is already in `supabase/migrations/20260522_driver_locations.sql` — you can run it as one block or step by step.

---

## Step 1 — Run the Migration SQL

Go to **Supabase Dashboard → SQL Editor** and run the following:

```sql
-- 1. Create the table
CREATE TABLE IF NOT EXISTS driver_locations (
  driver_id   uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id    text NOT NULL,
  lat         double precision NOT NULL,
  lng         double precision NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- 2. Index for fast order lookups
CREATE INDEX IF NOT EXISTS driver_locations_order_idx ON driver_locations (order_id);

-- 3. Enable RLS
ALTER TABLE driver_locations ENABLE ROW LEVEL SECURITY;

-- 4. Drivers can write/delete their own row only
CREATE POLICY "driver_upsert_own_location" ON driver_locations
  FOR ALL USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

-- 5. Suppliers and recycling cos can read (for live tracking map)
CREATE POLICY "authenticated_read_locations" ON driver_locations
  FOR SELECT USING (auth.role() = 'authenticated');

-- 6. Enable Realtime on this table
ALTER PUBLICATION supabase_realtime ADD TABLE driver_locations;
```

> **Note:** `service_role` (used by Edge Functions like `verify_arrival`) bypasses RLS automatically — no extra policy needed.

---

## Step 2 — Enable Realtime in the Dashboard

1. Go to **Database → Replication** (left sidebar).
2. Find `driver_locations` in the tables list.
3. Make sure the toggle under **supabase_realtime** is **ON**.

> The `ALTER PUBLICATION` SQL in Step 1 usually handles this automatically, but double-check here to be sure.

---

## Step 3 — Deploy the `verify_arrival` Edge Function

This function is the server-side geofence gate — it reads `driver_locations` and returns `{ allowed, distanceMeters }`.

In your terminal (from the project root):

```bash
supabase functions deploy verify_arrival
```

If you haven't linked the project yet:

```bash
supabase link --project-ref <your-project-ref>
supabase functions deploy verify_arrival
```

> Your `project-ref` is found in **Supabase Dashboard → Settings → General**.

---

## Step 4 — Set the Edge Function Secret

The `verify_arrival` function needs the Supabase service role key to read `driver_locations` without RLS restrictions.

1. Go to **Supabase Dashboard → Edge Functions → verify_arrival → Secrets**.
2. Add the following secret:

| Key | Value |
|-----|-------|
| `SUPABASE_SERVICE_ROLE_KEY` | Your service role key (from **Settings → API**) |

Alternatively, via CLI:

```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

---

## Step 5 — Verify the Table Exists

Run this quick check in the SQL Editor to confirm everything is in place:

```sql
-- Should return the table definition
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'driver_locations'
ORDER BY ordinal_position;

-- Should return 2 policies
SELECT policyname, cmd FROM pg_policies
WHERE tablename = 'driver_locations';
```

Expected columns: `driver_id`, `order_id`, `lat`, `lng`, `updated_at`  
Expected policies: `driver_upsert_own_location`, `authenticated_read_locations`

---

## Step 6 — Test End-to-End (Optional but Recommended)

1. Log in as a driver in the app and accept an order.
2. In the SQL Editor, run:
   ```sql
   SELECT * FROM driver_locations;
   ```
   You should see a row appear with the driver's GPS coordinates.

3. Log in as the supplier for that order — the order details screen should show the live tracking map with the driver's position updating as they move.

4. When the driver completes the order, the row should be deleted automatically.

---

## Summary Checklist

- [ ] Step 1: SQL migration run in SQL Editor
- [ ] Step 2: Realtime toggle confirmed ON for `driver_locations`
- [ ] Step 3: `verify_arrival` Edge Function deployed
- [ ] Step 4: `SUPABASE_SERVICE_ROLE_KEY` secret set on Edge Function
- [ ] Step 5: Verification query confirms table + policies exist
- [ ] Step 6: End-to-end test passed
