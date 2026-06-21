-- ─────────────────────────────────────────────────────────────────────────────
-- 00006_revoke_public_execute.sql  |  Applied: 2026-06-21
-- 00005 only revoked from named roles. PostgreSQL PUBLIC grants are inherited
-- by all roles and override role-level revokes. Must REVOKE FROM PUBLIC,
-- then selectively GRANT TO authenticated where the RPC is legitimately needed.
-- ─────────────────────────────────────────────────────────────────────────────

-- Trigger-only functions — no RPC access at all
REVOKE EXECUTE ON FUNCTION public.auto_credit_driver_compensation()    FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable()                    FROM PUBLIC;

-- Authenticated-only RPCs
REVOKE EXECUTE ON FUNCTION public.current_user_is_order_participant(uuid) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.current_user_is_order_participant(uuid) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.driver_wallet_hold(text, numeric)    FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.driver_wallet_hold(text, numeric)    TO authenticated;

REVOKE EXECUTE ON FUNCTION public.driver_wallet_release(text, numeric) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.driver_wallet_release(text, numeric) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.is_available_driver()                FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.is_available_driver()                TO authenticated;

REVOKE EXECUTE ON FUNCTION public.is_order_participant(uuid, uuid)     FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.is_order_participant(uuid, uuid)     TO authenticated;

REVOKE EXECUTE ON FUNCTION public.nearby_drivers(float, float, float)  FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.nearby_drivers(float, float, float)  TO authenticated;

REVOKE EXECUTE ON FUNCTION public.nearby_orders(double precision, double precision, double precision) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.nearby_orders(double precision, double precision, double precision) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.record_order_transaction(text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, boolean) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.record_order_transaction(text, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric, text, boolean) TO authenticated;

REVOKE EXECUTE ON FUNCTION public.verify_driver_arrival(text, double precision, double precision) FROM PUBLIC;
GRANT  EXECUTE ON FUNCTION public.verify_driver_arrival(text, double precision, double precision) TO authenticated;

-- get_email_by_phone + identifier_exists: KEEP public access (signup flow requires anon)
-- st_estimatedextent: PostGIS built-in, not controllable
