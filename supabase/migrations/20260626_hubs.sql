-- Phase 1: Hubs table
-- Physical collection points where drivers drop off recyclable material.
-- Admin dashboard manages via service_role. Flutter app reads for driver dropoff targeting.

CREATE TABLE IF NOT EXISTS public.hubs (
  id                 UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT         NOT NULL,
  address            TEXT         NOT NULL,
  lat                NUMERIC(9,6) NOT NULL,
  lng                NUMERIC(9,6) NOT NULL,
  active             BOOLEAN      NOT NULL DEFAULT true,
  capacity_kg        NUMERIC      NOT NULL DEFAULT 1000,
  current_load       JSONB        NOT NULL
                                  DEFAULT '{"cookingOil":0,"plastic":0,"paper":0,"electronics":0}'::jsonb,
  schedule           TEXT         NOT NULL DEFAULT 'weekly'
                                  CHECK (schedule IN ('weekly', 'monthly')),
  next_shipment_date DATE,
  last_shipment_date DATE,
  status             TEXT         NOT NULL DEFAULT 'collecting'
                                  CHECK (status IN ('collecting', 'ready', 'shipped')),
  created_at         TIMESTAMPTZ  NOT NULL DEFAULT now()
);

ALTER TABLE public.hubs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "hubs_select_authenticated"
  ON public.hubs
  FOR SELECT
  TO authenticated
  USING (true);

ALTER PUBLICATION supabase_realtime ADD TABLE public.hubs;
