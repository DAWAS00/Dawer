-- ─────────────────────────────────────────────────────────────────────────────
-- 00009_pickup_proof_columns.sql  |  Applied: 2026-06-23
-- Adds pickup-proof flat columns to orders.
-- Pattern mirrors existing proof_* dropoff columns.
-- Also adds proof_weight_kg for dropoff proof symmetry.
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS pickup_proof_photo_url   text,
  ADD COLUMN IF NOT EXISTS pickup_proof_weight_kg   float8,
  ADD COLUMN IF NOT EXISTS pickup_proof_captured_at timestamptz,
  ADD COLUMN IF NOT EXISTS pickup_proof_lat          float8,
  ADD COLUMN IF NOT EXISTS pickup_proof_lng          float8,
  ADD COLUMN IF NOT EXISTS pickup_proof_checksum     text,
  ADD COLUMN IF NOT EXISTS proof_weight_kg           float8;
