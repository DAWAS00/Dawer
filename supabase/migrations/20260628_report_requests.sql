-- ── Phase 3: Report requests table ────────────────────────────────────────────
-- B2B clients (Supplier, RecyclingCo) submit report requests from the Flutter app.
-- The admin dashboard reads and fulfills them.
-- RLS: authenticated users can INSERT and SELECT their own rows.
--       Service role (dashboard) can UPDATE status and set download_url.

CREATE TABLE IF NOT EXISTS public.report_requests (
  id             UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id        TEXT         NOT NULL,
  template       TEXT         NOT NULL
                              CHECK (template IN (
                                'weeklySummary', 'monthlyInvoice',
                                'co2Certificate', 'esgReport'
                              )),
  status         TEXT         NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending', 'processing', 'ready')),
  period_start   DATE         NOT NULL,
  period_end     DATE         NOT NULL,
  download_url   TEXT,
  requested_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
  fulfilled_at   TIMESTAMPTZ
);

-- Index for admin dashboard query (newest first)
CREATE INDEX IF NOT EXISTS report_requests_requested_at_idx
  ON public.report_requests (requested_at DESC);

-- Index for user's own requests
CREATE INDEX IF NOT EXISTS report_requests_user_id_idx
  ON public.report_requests (user_id, requested_at DESC);

-- RLS
ALTER TABLE public.report_requests ENABLE ROW LEVEL SECURITY;

-- Authenticated users can insert and read ONLY their own requests
CREATE POLICY "report_requests_user_insert"
  ON public.report_requests FOR INSERT TO authenticated
  WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "report_requests_user_select"
  ON public.report_requests FOR SELECT TO authenticated
  USING (auth.uid()::text = user_id);

-- Service role (admin dashboard) can UPDATE any row (to set status + download_url)
-- No explicit UPDATE policy needed — service_role bypasses RLS

-- Add to Realtime so the Flutter app receives status updates in real time
ALTER PUBLICATION supabase_realtime ADD TABLE public.report_requests;
