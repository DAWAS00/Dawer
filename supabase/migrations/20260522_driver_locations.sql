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

-- Authenticated users (suppliers, recycling cos) can read all rows so the
-- live-tracking map works for the order's other party.
CREATE POLICY "authenticated_read_locations" ON driver_locations
  FOR SELECT USING (auth.role() = 'authenticated');

-- service_role (Edge Functions: verify_arrival) has unrestricted access.
-- No explicit policy needed — service_role bypasses RLS by default.

-- ── Realtime ──────────────────────────────────────────────────────────────────
-- Enable Postgres logical replication for this table so DriverLocationStream
-- (Supabase Realtime channel) receives INSERT/UPDATE events in real time.
ALTER PUBLICATION supabase_realtime ADD TABLE driver_locations;
