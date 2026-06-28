-- ─────────────────────────────────────────────────────────────────────────────
-- 00008_fix_orders_rls.sql  |  Applied: 2026-06-21
-- Fix 1: orders_select_pending_for_drivers had no role check — any authenticated
--        user could read all pending orders via REST API.
-- Fix 2: orders_update_driver_accept used raw auth.uid() in WITH CHECK
--        (missed by 00005 patch) — performance fix, same 100x pattern.
-- ─────────────────────────────────────────────────────────────────────────────

-- Fix 1: scope pending-order visibility to drivers only
DROP POLICY IF EXISTS orders_select_pending_for_drivers ON public.orders;
CREATE POLICY orders_select_pending_for_drivers ON public.orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE auth_id = (select auth.uid()) AND role = 'driver'
    )
    AND (
      status = 'pending'
      OR (status = 'accepted' AND requires_rider = true AND driver_id IS NULL)
    )
  );

-- Fix 2: patch raw auth.uid() in with_check
DROP POLICY IF EXISTS orders_update_driver_accept ON public.orders;
CREATE POLICY orders_update_driver_accept ON public.orders
  FOR UPDATE
  USING (
    status = 'pending'
    OR (status = 'accepted' AND requires_rider = true AND driver_id IS NULL)
  )
  WITH CHECK (driver_id = (select auth.uid()));
