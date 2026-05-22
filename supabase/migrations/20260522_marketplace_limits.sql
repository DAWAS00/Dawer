-- ── orders: listing TTL column ───────────────────────────────────────────────
-- Set at listing creation: 14 days for individuals, 30 days for businesses.
-- NULL = no expiry (regular pickup orders, collection jobs).
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS expires_at timestamptz;

CREATE INDEX IF NOT EXISTS orders_expires_at_idx
  ON public.orders (expires_at)
  WHERE expires_at IS NOT NULL AND status = 'pending';

-- ── transactions: SECURITY DEFINER write function ─────────────────────────────
-- The transactions table RLS only allows service_role writes.
-- This function runs as the owner (bypasses RLS) so drivers can record their
-- own payout rows without a direct service_role connection.
CREATE OR REPLACE FUNCTION record_order_transaction(
  p_order_id           text,
  p_base_fee           numeric,
  p_distance_fee       numeric,
  p_material_fee       numeric,
  p_urgency_bonus      numeric,
  p_weight_surcharge   numeric,
  p_gross_fee          numeric,
  p_platform_cut       numeric,
  p_driver_payout      numeric,
  p_vehicle_type       text    DEFAULT NULL,
  p_needs_manual_review boolean DEFAULT false
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_driver_id uuid := auth.uid();
BEGIN
  IF v_driver_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  INSERT INTO public.transactions (
    order_id,
    driver_id,
    base_fee_jd,
    distance_fee_jd,
    material_fee_jd,
    urgency_bonus_jd,
    weight_surcharge_jd,
    gross_fee_jd,
    platform_cut_jd,
    driver_payout_jd,
    vehicle_type,
    needs_manual_review,
    status
  ) VALUES (
    p_order_id::uuid,
    v_driver_id,
    p_base_fee,
    p_distance_fee,
    p_material_fee,
    p_urgency_bonus,
    p_weight_surcharge,
    p_gross_fee,
    p_platform_cut,
    p_driver_payout,
    p_vehicle_type,
    p_needs_manual_review,
    'pending'
  )
  ON CONFLICT (order_id) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION record_order_transaction TO authenticated;
