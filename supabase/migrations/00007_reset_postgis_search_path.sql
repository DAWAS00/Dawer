-- ─────────────────────────────────────────────────────────────────────────────
-- 00007_reset_postgis_search_path.sql  |  Applied: 2026-06-21
-- 00005 mistakenly set search_path = 'public, pg_catalog' on PostGIS trigger
-- functions. At runtime the ::geography cast still fails (body validated at
-- session search_path, not the function's SET). Reset these 4 functions so
-- they inherit the session default, which includes public where geography lives.
-- These functions are trigger-invoked or SECURITY DEFINER — not RPC-callable
-- via anon, so the mutable search_path advisory warning is acceptable.
-- ─────────────────────────────────────────────────────────────────────────────
ALTER FUNCTION public.sync_orders_geography()   RESET search_path;
ALTER FUNCTION public.sync_profiles_geography() RESET search_path;
ALTER FUNCTION public.nearby_orders(double precision, double precision, double precision) RESET search_path;
ALTER FUNCTION public.verify_driver_arrival(text, double precision, double precision)    RESET search_path;
