-- ── Driver locations (live GPS tracking) ─────────────────────────────────────
-- One row per active driver, keyed by driver_id (upserted on each GPS tick).
-- Deleted when the driver completes or cancels an order (LocationPublisher.stop).
CREATE TABLE IF NOT EXISTS driver_locations (
  driver_id   uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id    text NOT NULL,
  lat         double precision NOT NULL,
  lng         double precision NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS driver_locations_order_idx ON driver_locations (order_id);

-- ── RLS ───────────────────────────────────────────────────────────────────────
ALTER TABLE driver_locations ENABLE ROW LEVEL SECURITY;

-- Drivers may upsert/delete their own row only.
CREATE POLICY "driver_upsert_own_location" ON driver_locations
  FOR ALL USING (auth.uid() = driver_id)
  WITH CHECK (auth.uid() = driver_id);

-- An authenticated user may read a driver's live location ONLY if they are a
-- participant of the order the driver is on (supplier / company / that driver).
-- The previous policy (`auth.role() = 'authenticated'`) let ANY logged-in user
-- read every driver's GPS — a platform-wide location leak.
CREATE POLICY "authenticated_read_locations" ON driver_locations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id::text = driver_locations.order_id
        AND (
          o.driver_id   = auth.uid()
          OR o.supplier_id = auth.uid()
          OR o.company_id  = auth.uid()
        )
    )
  );

-- service_role (Edge Functions) bypasses RLS by default; no explicit policy.

-- ── verify_driver_arrival RPC ────────────────────────────────────────────────
-- Server-side proximity truth, called by SupabaseOrderRepository.verifyArrival.
-- Compares the driver's server-trusted GPS (latest driver_locations row) against
-- the target point (p_lat/p_lng). Within 200 m → arrival allowed; otherwise logs
-- a 'proximity_block' to fraud_audit. The client's own GPS is UX only.
-- Lives HERE (not in 20260519) because it depends on this table existing.
CREATE OR REPLACE FUNCTION public.verify_driver_arrival(
  p_order_id text,
  p_lat      double precision,
  p_lng      double precision
) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_threshold_m constant double precision := 200;
  v_driver_auth uuid := auth.uid();
  v_loc         geography;
  v_target      geography := ST_MakePoint(p_lng, p_lat)::geography;
  v_distance_m  double precision;
  v_allowed     boolean;
BEGIN
  IF v_driver_auth IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Server-trusted position: latest GPS the driver published for this order.
  SELECT ST_MakePoint(lng, lat)::geography INTO v_loc
  FROM public.driver_locations
  WHERE driver_id = v_driver_auth AND order_id = p_order_id
  ORDER BY updated_at DESC
  LIMIT 1;

  -- No published location → cannot verify arrival.
  IF v_loc IS NULL THEN
    RETURN false;
  END IF;

  v_distance_m := ST_Distance(v_loc, v_target);
  v_allowed := v_distance_m <= v_threshold_m;

  IF NOT v_allowed THEN
    INSERT INTO public.fraud_audit (
      driver_id, order_id, event_type, distance_m,
      driver_lat, driver_lng, target_lat, target_lng
    ) VALUES (
      v_driver_auth, p_order_id, 'proximity_block', v_distance_m,
      ST_Y(v_loc::geometry), ST_X(v_loc::geometry), p_lat, p_lng
    );
  END IF;

  RETURN v_allowed;
END;
$$;
GRANT EXECUTE ON FUNCTION public.verify_driver_arrival TO authenticated;

-- ── Realtime ──────────────────────────────────────────────────────────────────
-- Enable Postgres logical replication for this table so DriverLocationStream
-- (Supabase Realtime channel) receives INSERT/UPDATE events in real time.
ALTER PUBLICATION supabase_realtime ADD TABLE driver_locations;
