-- ── transactions: add full pricing breakdown columns ─────────────────────────
-- The original table only had base_fee, distance_fee, material_fee, urgency_bonus
-- and a generated total_jd that didn't account for weight surcharge or platform cut.
-- These columns complete the audit trail for every driver payout.

ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS weight_surcharge_jd NUMERIC NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS gross_fee_jd        NUMERIC NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS platform_cut_jd     NUMERIC NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS driver_payout_jd    NUMERIC NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS vehicle_type        TEXT,
  ADD COLUMN IF NOT EXISTS needs_manual_review BOOLEAN NOT NULL DEFAULT false;

-- Index for finance reports: sum driver_payout_jd per driver per period
CREATE INDEX IF NOT EXISTS transactions_driver_created_idx
  ON public.transactions (driver_id, created_at DESC);
