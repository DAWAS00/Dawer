-- ── Orders table: new security columns ───────────────────────────────────────
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS arrived_at_pickup_at      timestamptz,
  ADD COLUMN IF NOT EXISTS arrived_at_dropoff_at     timestamptz,
  ADD COLUMN IF NOT EXISTS arrival_confirmation_status text
    CHECK (arrival_confirmation_status IN ('awaiting','confirmed','unavailable','timedOut')),
  ADD COLUMN IF NOT EXISTS supplier_hold_amount      numeric(10,2),
  ADD COLUMN IF NOT EXISTS driver_compensation_amount numeric(10,2),
  ADD COLUMN IF NOT EXISTS fraud_attempt_count       int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS weight_variance_flag      boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS proof_image_path          text,
  ADD COLUMN IF NOT EXISTS proof_captured_at         timestamptz,
  ADD COLUMN IF NOT EXISTS proof_lat                 double precision,
  ADD COLUMN IF NOT EXISTS proof_lng                 double precision,
  ADD COLUMN IF NOT EXISTS proof_checksum            text;

-- ── Fraud audit log ───────────────────────────────────────────────────────────
-- Every proximity check failure and suspicious event lands here.
CREATE TABLE IF NOT EXISTS fraud_audit (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id     uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  order_id      text,
  event_type    text NOT NULL,
  -- 'proximity_block'  – driver tried to mark arrived while >200m away
  -- 'no_show'          – ghost timer fired, driver never reached geofence
  -- 'fast_completion'  – order completed faster than minimum travel time
  -- 'weight_variance'  – actual weight deviated >50% from estimate
  distance_m    double precision,
  driver_lat    double precision,
  driver_lng    double precision,
  target_lat    double precision,
  target_lng    double precision,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS fraud_audit_driver_idx ON fraud_audit (driver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS fraud_audit_order_idx  ON fraud_audit (order_id);

-- ── Driver wallet ─────────────────────────────────────────────────────────────
-- One row per driver. balance = spendable; held_amount = escrowed for active orders.
CREATE TABLE IF NOT EXISTS driver_wallet (
  driver_id    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  balance      numeric(10,2) NOT NULL DEFAULT 0.00,
  held_amount  numeric(10,2) NOT NULL DEFAULT 0.00,
  updated_at   timestamptz NOT NULL DEFAULT now()
);

-- ── Wallet transactions ───────────────────────────────────────────────────────
-- Immutable ledger: every hold, release, and refund is appended here.
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id   uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  order_id    text,
  type        text NOT NULL
    CHECK (type IN ('hold','release','partial_release','refund','penalty')),
  amount      numeric(10,2) NOT NULL,
  note        text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS wallet_tx_driver_idx ON wallet_transactions (driver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS wallet_tx_order_idx  ON wallet_transactions (order_id);

-- NOTE: verify_driver_arrival() lives in 20260522_driver_locations.sql because
-- it queries that table. Defining it there keeps each migration internally
-- consistent (no forward references to tables created later).

-- ── RLS policies ─────────────────────────────────────────────────────────────
ALTER TABLE fraud_audit         ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_wallet       ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;

-- Drivers can read their own wallet and transactions.
CREATE POLICY "driver_read_own_wallet" ON driver_wallet
  FOR SELECT USING (auth.uid() = driver_id);

CREATE POLICY "driver_read_own_transactions" ON wallet_transactions
  FOR SELECT USING (auth.uid() = driver_id);

-- Only service role (Edge Functions) can write to these tables.
CREATE POLICY "service_write_fraud_audit" ON fraud_audit
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "service_write_wallet" ON driver_wallet
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "service_write_wallet_tx" ON wallet_transactions
  FOR INSERT WITH CHECK (auth.role() = 'service_role');
