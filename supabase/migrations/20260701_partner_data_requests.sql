-- ── Partner data-access requests ────────────────────────────────────────────
-- Companies (municipalities, sustainability firms, research partners) that
-- want to purchase/access Dwaar's aggregated recycling data submit a lead
-- from the "About Dwaar" sheet on the login screen — before they have an
-- account. The admin dashboard reads and follows up by email.
-- RLS: anyone (anon or authenticated) can INSERT. Nobody can SELECT from the
-- client — only the admin dashboard via service_role, which bypasses RLS.

CREATE TABLE IF NOT EXISTS public.partner_data_requests (
  id             UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_name   TEXT         NOT NULL,
  contact_name   TEXT         NOT NULL,
  email          TEXT         NOT NULL,
  phone          TEXT,
  message        TEXT         NOT NULL,
  status         TEXT         NOT NULL DEFAULT 'pending'
                              CHECK (status IN ('pending', 'contacted', 'closed')),
  requested_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Index for admin dashboard query (newest first)
CREATE INDEX IF NOT EXISTS partner_data_requests_requested_at_idx
  ON public.partner_data_requests (requested_at DESC);

-- RLS
ALTER TABLE public.partner_data_requests ENABLE ROW LEVEL SECURITY;

-- Anonymous AND authenticated visitors can submit a lead. There is no
-- corresponding SELECT policy, so a submitted row is write-only from the
-- client — it cannot be read back or listed by other visitors.
CREATE POLICY "partner_data_requests_public_insert"
  ON public.partner_data_requests FOR INSERT TO anon, authenticated
  WITH CHECK (true);

-- Service role (admin dashboard) reads/updates any row — bypasses RLS,
-- no explicit SELECT/UPDATE policy needed.
