-- ── Push notifications + driver matching support (Cloud SQL / Cloud Run version)
-- Adapted from 20260612_push_and_matching.sql
--
-- Supabase-specific parts removed:
--   - pg_net extension (not available on Cloud SQL)
--   - vault.decrypted_secrets (not available on Cloud SQL)
--   - notify_order_status_change trigger (Cloud Run order-svc publishes to Pub/Sub instead)
--
-- What remains: the pickup coordinates helper used by geo-svc.
-- Notification dispatch is handled by notif-svc via Cloud Pub/Sub.

-- ── Pickup coordinates helper (used by geo-svc Cloud Run service) ─────────────
CREATE OR REPLACE FUNCTION order_pickup_coords(p_order_id UUID)
RETURNS TABLE (lat FLOAT, lng FLOAT)
LANGUAGE sql STABLE AS $$
  SELECT ST_Y(pickup_location::geometry) AS lat,
         ST_X(pickup_location::geometry) AS lng
  FROM public.orders
  WHERE id = p_order_id;
$$;
