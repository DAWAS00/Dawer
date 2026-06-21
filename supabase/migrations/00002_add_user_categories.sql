-- categories now lives inline on public.profiles (see 00001_initial_schema.sql).
-- Kept as an idempotent safety net so re-applying the migration set never fails.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS categories TEXT[] NOT NULL DEFAULT '{}';
