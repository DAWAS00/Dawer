-- Phase 1: B2B Partner contract fields on public.profiles
-- Adds contract management columns used by recyclingCo users.
-- Read and written by the admin dashboard's Partner management view.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS contract_tier       TEXT    NOT NULL DEFAULT 'free'
                                               CHECK (contract_tier IN ('free','basic','pro','enterprise')),
  ADD COLUMN IF NOT EXISTS renewal_date        DATE,
  ADD COLUMN IF NOT EXISTS billing_cycle       TEXT    DEFAULT 'monthly'
                                               CHECK (billing_cycle IN ('monthly','annual')),
  ADD COLUMN IF NOT EXISTS green_points        INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS custom_price_jd     NUMERIC,
  ADD COLUMN IF NOT EXISTS contract_notes      TEXT,
  ADD COLUMN IF NOT EXISTS last_certificate_download DATE,
  ADD COLUMN IF NOT EXISTS referred_by         TEXT;

CREATE INDEX IF NOT EXISTS profiles_recycling_co_idx
  ON public.profiles (role, created_at DESC)
  WHERE role = 'recyclingCo';
