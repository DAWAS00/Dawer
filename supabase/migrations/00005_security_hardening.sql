-- ─────────────────────────────────────────────────────────────────────────────
-- 00005_security_hardening.sql  |  Applied: 2026-06-21
-- Fixes:
--   1. Drop auto_confirm_user trigger (email verification bypass)
--   2. Redefine nearby_drivers() without fcm_token (data leak)
--   3. Add missing FK indexes on orders, driver_locations, chat_messages, notifications
--   4. Patch 5 RLS policies from raw auth.uid() to (select auth.uid()) [100x perf]
--   5. REVOKE dangerous SECURITY DEFINER RPCs from anon/authenticated
--   6. SET search_path = '' on non-PostGIS app functions
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Drop auto_confirm_user ─────────────────────────────────────────────────
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.auto_confirm_user();

-- ── 2. Redefine nearby_drivers() — strip fcm_token ───────────────────────────
-- Must DROP first (return type changes — can't CREATE OR REPLACE)
-- Use ::public.geography for fully-qualified cast (SQL body validated at session search_path)
DROP FUNCTION IF EXISTS public.nearby_drivers(float, float, float);
CREATE FUNCTION public.nearby_drivers(
  lat       FLOAT,
  lng       FLOAT,
  radius_km FLOAT DEFAULT 10
) RETURNS TABLE (id UUID, name TEXT, distance_m FLOAT)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = 'public, pg_catalog'
AS $$
  SELECT
    u.auth_id AS id,
    u.name,
    public.ST_Distance(u.location, public.ST_MakePoint(lng, lat)::public.geography) AS distance_m
  FROM public.profiles u
  WHERE u.role = 'driver'
    AND u.is_available = true
    AND u.location IS NOT NULL
    AND public.ST_DWithin(u.location, public.ST_MakePoint(lng, lat)::public.geography, radius_km * 1000)
  ORDER BY distance_m ASC
  LIMIT 20;
$$;

-- ── 3. FK indexes ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS orders_supplier_id_idx         ON public.orders (supplier_id);
CREATE INDEX IF NOT EXISTS orders_driver_id_idx           ON public.orders (driver_id);
CREATE INDEX IF NOT EXISTS orders_company_id_idx          ON public.orders (company_id);
CREATE INDEX IF NOT EXISTS orders_linked_job_id_idx       ON public.orders (linked_job_id);
CREATE INDEX IF NOT EXISTS driver_locations_order_id_idx  ON public.driver_locations (order_id);
CREATE INDEX IF NOT EXISTS driver_locations_driver_id_idx ON public.driver_locations (driver_id);
CREATE INDEX IF NOT EXISTS chat_messages_room_id_idx      ON public.chat_messages (room_id);
CREATE INDEX IF NOT EXISTS chat_messages_sender_id_idx    ON public.chat_messages (sender_id);
CREATE INDEX IF NOT EXISTS notifications_job_id_idx       ON public.notifications (job_id);
CREATE INDEX IF NOT EXISTS notifications_order_id_idx     ON public.notifications (order_id);
CREATE INDEX IF NOT EXISTS notifications_recipient_id_idx ON public.notifications (recipient_id);

-- ── 4. RLS policy performance patch ──────────────────────────────────────────
DROP POLICY IF EXISTS profiles_select_own ON public.profiles;
CREATE POLICY profiles_select_own ON public.profiles
  FOR SELECT USING ((select auth.uid()) = auth_id);

DROP POLICY IF EXISTS profiles_update_own ON public.profiles;
CREATE POLICY profiles_update_own ON public.profiles
  FOR UPDATE
  USING ((select auth.uid()) = auth_id)
  WITH CHECK ((select auth.uid()) = auth_id);

DROP POLICY IF EXISTS driver_read_own_wallet ON public.driver_wallet;
CREATE POLICY driver_read_own_wallet ON public.driver_wallet
  FOR SELECT USING ((select auth.uid()) = driver_id);

DROP POLICY IF EXISTS driver_read_own_transactions ON public.wallet_transactions;
CREATE POLICY driver_read_own_transactions ON public.wallet_transactions
  FOR SELECT USING ((select auth.uid()) = driver_id);

DROP POLICY IF EXISTS driver_upsert_own_location ON public.driver_locations;
CREATE POLICY driver_upsert_own_location ON public.driver_locations
  FOR ALL
  USING ((select auth.uid()) = driver_id)
  WITH CHECK ((select auth.uid()) = driver_id);

DROP POLICY IF EXISTS user_docs_owner_read ON storage.objects;
CREATE POLICY user_docs_owner_read ON storage.objects
  FOR SELECT USING (
    bucket_id = 'user-documents'
    AND (select auth.uid())::text = (storage.foldername(name))[1]
  );

-- ── 5. REVOKE dangerous RPCs from anon ───────────────────────────────────────
REVOKE EXECUTE ON FUNCTION public.driver_wallet_hold(text, numeric)    FROM anon;
REVOKE EXECUTE ON FUNCTION public.driver_wallet_release(text, numeric) FROM anon;
REVOKE EXECUTE ON FUNCTION public.auto_credit_driver_compensation()    FROM anon;
REVOKE EXECUTE ON FUNCTION public.auto_credit_driver_compensation()    FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.current_user_is_order_participant(uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.is_order_participant(uuid, uuid)        FROM anon;
REVOKE EXECUTE ON FUNCTION public.is_available_driver()                FROM anon;
REVOKE EXECUTE ON FUNCTION public.nearby_orders(double precision, double precision, double precision) FROM anon;
REVOKE EXECUTE ON FUNCTION public.record_order_transaction(text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, boolean) FROM anon;
REVOKE EXECUTE ON FUNCTION public.verify_driver_arrival(text, double precision, double precision) FROM anon;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM anon;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.nearby_drivers(float, float, float)  FROM anon;

-- ── 6. SET search_path on non-PostGIS app functions ──────────────────────────
-- PostGIS trigger/spatial functions (sync_orders_geography, sync_profiles_geography,
-- nearby_orders, verify_driver_arrival) intentionally excluded — ::geography cast
-- fails with explicit search_path; reset in 00007 if accidentally set here.
ALTER FUNCTION public.current_user_id()                    SET search_path = '';
ALTER FUNCTION public.current_user_is_order_participant(uuid) SET search_path = '';
ALTER FUNCTION public.driver_wallet_hold(text, numeric)    SET search_path = '';
ALTER FUNCTION public.driver_wallet_release(text, numeric) SET search_path = '';
ALTER FUNCTION public.enforce_order_status_transition()    SET search_path = '';
ALTER FUNCTION public.get_email_by_phone(text)             SET search_path = '';
ALTER FUNCTION public.identifier_exists(text)              SET search_path = '';
ALTER FUNCTION public.is_available_driver()                SET search_path = '';
ALTER FUNCTION public.is_order_participant(uuid, uuid)     SET search_path = '';
ALTER FUNCTION public.record_order_transaction(text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, boolean) SET search_path = '';
ALTER FUNCTION public.update_supplier_points_on_complete() SET search_path = '';
ALTER FUNCTION public.auto_credit_driver_compensation()    SET search_path = '';
-- enforce_driver_single_active_order: PostGIS-adjacent trigger, set conservatively
ALTER FUNCTION public.enforce_driver_single_active_order() SET search_path = 'public, pg_catalog';
-- PostGIS spatial functions: SET search_path intentionally omitted (see note above)
ALTER FUNCTION public.sync_orders_geography()              SET search_path = 'public, pg_catalog';
ALTER FUNCTION public.sync_profiles_geography()            SET search_path = 'public, pg_catalog';
ALTER FUNCTION public.nearby_orders(double precision, double precision, double precision) SET search_path = 'public, pg_catalog';
ALTER FUNCTION public.verify_driver_arrival(text, double precision, double precision)    SET search_path = 'public, pg_catalog';
