-- ============================================================
-- 20260627_perf_and_rls_hardening.sql
--
-- Applies Supabase Postgres best-practice rules across the full schema:
--   1. RLS performance  — replace auth.uid() per-row calls with (SELECT auth.uid())
--   2. FK indexes       — Postgres does NOT auto-index FK columns
--   3. Partial indexes  — smaller, faster indexes for high-frequency filters
--   4. Composite indexes — cover the 3 most common multi-column query patterns
--   5. GIST indexes     — explicit spatial indexes for GEOGRAPHY columns
--   6. current_user_id() — add SET search_path = '' (security hardening)
--
-- Safe to apply on a live project: all changes are additive or DROP/RECREATE
-- of policies (DDL on policy definitions, zero data touched).
-- ============================================================

-- ── 1. Harden current_user_id() ──────────────────────────────
-- Add SET search_path = '' so the function is immune to search_path injection
-- (security-privileges rule). The body is unchanged.
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS UUID LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT auth.uid();
$$;

-- ── 2. FK indexes (schema-foreign-key-indexes rule) ──────────
-- Postgres never creates indexes on FK columns automatically.
-- Missing → full table scan on every JOIN and ON DELETE CASCADE.

-- orders: three participant FK columns, plus linked_job_id
CREATE INDEX IF NOT EXISTS orders_supplier_id_idx    ON public.orders (supplier_id);
CREATE INDEX IF NOT EXISTS orders_driver_id_idx      ON public.orders (driver_id);
CREATE INDEX IF NOT EXISTS orders_company_id_idx     ON public.orders (company_id);
CREATE INDEX IF NOT EXISTS orders_linked_job_id_idx  ON public.orders (linked_job_id);

-- notifications: recipient + two order references
CREATE INDEX IF NOT EXISTS notifications_recipient_id_idx ON public.notifications (recipient_id);
CREATE INDEX IF NOT EXISTS notifications_order_id_idx     ON public.notifications (order_id);
CREATE INDEX IF NOT EXISTS notifications_job_id_idx       ON public.notifications (job_id);

-- transactions: driver FK (order_id is UNIQUE, already indexed)
CREATE INDEX IF NOT EXISTS transactions_driver_id_idx ON public.transactions (driver_id);

-- chat_messages: sender FK (room_id already indexed by 00003_chat.sql)
CREATE INDEX IF NOT EXISTS chat_messages_sender_id_idx ON public.chat_messages (sender_id);

-- ── 3. Partial indexes (query-partial-indexes rule) ──────────
-- Pending orders are fetched constantly by drivers; status = 'pending' is
-- a tiny fraction of total rows once the app is live.
CREATE INDEX IF NOT EXISTS orders_pending_created_idx
  ON public.orders (created_at DESC)
  WHERE status = 'pending';

-- Active orders for live driver assignment/tracking (small hot set)
CREATE INDEX IF NOT EXISTS orders_active_driver_idx
  ON public.orders (driver_id, created_at DESC)
  WHERE status IN ('accepted', 'arrivedAtPickup', 'inTransit', 'arrivedAtDropoff');

-- Available drivers for nearby_drivers() (tiny subset of profiles at any time)
CREATE INDEX IF NOT EXISTS profiles_available_driver_location_idx
  ON public.profiles (auth_id)
  WHERE role = 'driver' AND is_available = true AND location IS NOT NULL;

-- Active hubs (nearly all hubs; still useful to avoid dead rows after soft-disable)
CREATE INDEX IF NOT EXISTS hubs_active_idx
  ON public.hubs (id)
  WHERE active = true;

-- Unread notifications (common bell-icon count query)
CREATE INDEX IF NOT EXISTS notifications_unread_idx
  ON public.notifications (recipient_id, created_at DESC)
  WHERE is_read = false;

-- ── 4. Composite indexes (query-composite-indexes rule) ──────
-- Cover the 3 role-scoped history queries that always filter by owner + time.
CREATE INDEX IF NOT EXISTS orders_supplier_created_idx
  ON public.orders (supplier_id, created_at DESC);

CREATE INDEX IF NOT EXISTS orders_driver_created_idx
  ON public.orders (driver_id, created_at DESC);

CREATE INDEX IF NOT EXISTS orders_company_created_idx
  ON public.orders (company_id, created_at DESC);

-- ── 5. GIST indexes for GEOGRAPHY columns ────────────────────
-- PostGIS ST_DWithin / ST_Distance require a GIST index to avoid seq-scan.
-- Supabase does NOT create these automatically on GEOGRAPHY columns.
CREATE INDEX IF NOT EXISTS profiles_location_gist_idx
  ON public.profiles USING GIST (location)
  WHERE location IS NOT NULL;

CREATE INDEX IF NOT EXISTS orders_pickup_location_gist_idx
  ON public.orders USING GIST (pickup_location);

CREATE INDEX IF NOT EXISTS orders_dropoff_location_gist_idx
  ON public.orders USING GIST (dropoff_location)
  WHERE dropoff_location IS NOT NULL;

-- ── 6. RLS policy rewrite (security-rls-performance rule) ────
-- Calling auth.uid() inside USING/WITH CHECK without a SELECT subquery means
-- the function is evaluated once per row, not once per query.
-- Pattern: replace `auth.uid()` with `(SELECT auth.uid())` everywhere.
--
-- Also rewrites profiles_select_participant from 3 UNION subqueries to a
-- single EXISTS with OR — functionally identical but ~3x cheaper.

-- ── profiles ─────────────────────────────────────────────────
DROP POLICY IF EXISTS profiles_select_own        ON public.profiles;
DROP POLICY IF EXISTS profiles_insert_own        ON public.profiles;
DROP POLICY IF EXISTS profiles_update_own        ON public.profiles;
DROP POLICY IF EXISTS profiles_select_participant ON public.profiles;

CREATE POLICY profiles_select_own ON public.profiles
  FOR SELECT USING ((SELECT auth.uid()) = auth_id);

CREATE POLICY profiles_insert_own ON public.profiles
  FOR INSERT WITH CHECK ((SELECT auth.uid()) = auth_id);

CREATE POLICY profiles_update_own ON public.profiles
  FOR UPDATE
  USING      ((SELECT auth.uid()) = auth_id)
  WITH CHECK ((SELECT auth.uid()) = auth_id);

-- Rewritten: single EXISTS instead of 3-way UNION (same semantics, less work)
CREATE POLICY profiles_select_participant ON public.profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE
        (o.driver_id   = (SELECT auth.uid()) AND o.supplier_id = auth_id) OR
        (o.driver_id   = (SELECT auth.uid()) AND o.company_id  = auth_id) OR
        (o.supplier_id = (SELECT auth.uid()) AND o.driver_id   = auth_id)
    )
  );

-- ── orders ───────────────────────────────────────────────────
DROP POLICY IF EXISTS orders_insert_supplier         ON public.orders;
DROP POLICY IF EXISTS orders_select_own_supplier     ON public.orders;
DROP POLICY IF EXISTS orders_select_own_driver       ON public.orders;
DROP POLICY IF EXISTS orders_select_own_company      ON public.orders;
DROP POLICY IF EXISTS orders_select_pending_for_drivers ON public.orders;
DROP POLICY IF EXISTS orders_update_driver           ON public.orders;
DROP POLICY IF EXISTS orders_update_driver_accept    ON public.orders;
DROP POLICY IF EXISTS orders_update_supplier_cancel  ON public.orders;

CREATE POLICY orders_insert_supplier ON public.orders
  FOR INSERT WITH CHECK (
    (supplier_id = (SELECT auth.uid())) OR (company_id = (SELECT auth.uid()))
  );

CREATE POLICY orders_select_own_supplier ON public.orders
  FOR SELECT USING (supplier_id = (SELECT auth.uid()));

CREATE POLICY orders_select_own_driver ON public.orders
  FOR SELECT USING (driver_id = (SELECT auth.uid()));

CREATE POLICY orders_select_own_company ON public.orders
  FOR SELECT USING (company_id = (SELECT auth.uid()));

CREATE POLICY orders_select_pending_for_drivers ON public.orders
  FOR SELECT USING (
    (status = 'pending') OR
    (status = 'accepted' AND requires_rider = true AND driver_id IS NULL)
  );

CREATE POLICY orders_update_driver ON public.orders
  FOR UPDATE USING (driver_id = (SELECT auth.uid()));

CREATE POLICY orders_update_driver_accept ON public.orders
  FOR UPDATE
  USING (
    (status = 'pending') OR
    (status = 'accepted' AND requires_rider = true AND driver_id IS NULL)
  )
  WITH CHECK (driver_id = (SELECT auth.uid()));

CREATE POLICY orders_update_supplier_cancel ON public.orders
  FOR UPDATE
  USING (
    supplier_id = (SELECT auth.uid())
    AND status = ANY(ARRAY['pending'::order_status, 'accepted'::order_status])
  );

-- ── notifications ─────────────────────────────────────────────
DROP POLICY IF EXISTS notifications_select_own      ON public.notifications;
DROP POLICY IF EXISTS notifications_update_read_own ON public.notifications;

CREATE POLICY notifications_select_own ON public.notifications
  FOR SELECT USING (recipient_id = (SELECT auth.uid()));

CREATE POLICY notifications_update_read_own ON public.notifications
  FOR UPDATE
  USING      (recipient_id = (SELECT auth.uid()))
  WITH CHECK (recipient_id = (SELECT auth.uid()));

-- ── transactions ──────────────────────────────────────────────
DROP POLICY IF EXISTS transactions_select_driver  ON public.transactions;
DROP POLICY IF EXISTS transactions_select_company ON public.transactions;

CREATE POLICY transactions_select_driver ON public.transactions
  FOR SELECT USING (driver_id = (SELECT auth.uid()));

CREATE POLICY transactions_select_company ON public.transactions
  FOR SELECT USING (
    order_id IN (
      SELECT id FROM public.orders WHERE company_id = (SELECT auth.uid())
    )
  );

-- ── driver_locations ──────────────────────────────────────────
DROP POLICY IF EXISTS "driver_upsert_own_location"     ON public.driver_locations;
DROP POLICY IF EXISTS "authenticated_read_locations"   ON public.driver_locations;

CREATE POLICY "driver_upsert_own_location" ON public.driver_locations
  FOR ALL
  USING      ((SELECT auth.uid()) = driver_id)
  WITH CHECK ((SELECT auth.uid()) = driver_id);

CREATE POLICY "authenticated_read_locations" ON public.driver_locations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id::text = driver_locations.order_id
        AND (
          o.driver_id   = (SELECT auth.uid()) OR
          o.supplier_id = (SELECT auth.uid()) OR
          o.company_id  = (SELECT auth.uid())
        )
    )
  );
