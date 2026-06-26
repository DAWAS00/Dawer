-- Phase 1: Seed starter hubs
-- Migrates the 4 hubs hardcoded in the dashboard's INITIAL_HUBS constant.
-- ON CONFLICT DO NOTHING makes this safe to re-run.

ALTER TABLE public.hubs DISABLE ROW LEVEL SECURITY;

INSERT INTO public.hubs
  (name, address, lat, lng, active, capacity_kg, current_load, schedule, next_shipment_date, last_shipment_date, status)
VALUES
  (
    'Hub Al-Sweifieh',
    'Sweifieh Commercial District, Amman',
    31.944000, 35.871000,
    true, 1200,
    '{"cookingOil":312,"plastic":156,"paper":94,"electronics":37}'::jsonb,
    'weekly', '2026-06-27', '2026-06-20', 'collecting'
  ),
  (
    'Hub Downtown',
    'Al-Balad, Downtown Amman',
    31.952000, 35.934000,
    true, 800,
    '{"cookingOil":520,"plastic":88,"paper":42,"electronics":18}'::jsonb,
    'weekly', '2026-06-27', '2026-06-20', 'ready'
  ),
  (
    'Hub Jubaiha',
    'Jubaiha University District',
    32.001000, 35.868000,
    true, 1500,
    '{"cookingOil":180,"plastic":410,"paper":220,"electronics":95}'::jsonb,
    'monthly', '2026-07-01', '2026-06-01', 'collecting'
  ),
  (
    'Hub Tabarbour',
    'Tabarbour Industrial Zone',
    32.015000, 35.922000,
    false, 2000,
    '{"cookingOil":0,"plastic":0,"paper":0,"electronics":0}'::jsonb,
    'monthly', NULL, NULL, 'collecting'
  )
ON CONFLICT DO NOTHING;

ALTER TABLE public.hubs ENABLE ROW LEVEL SECURITY;
