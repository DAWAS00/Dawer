-- ── Reservation / booking escrow system (MVP) ──────────────────────────────────
-- Facility/restaurant (seller) creates a timed reservation for a buyer. Buyer
-- must approve then complete the purchase before the deadline. Breaching the
-- deal costs the breaching party 10% of the invoice, paid to the other side:
--   - buyer never completes before deadline  -> buyer pays seller
--   - seller cancels claiming they sold elsewhere (fraud) -> seller pays buyer
-- Money movement is a standalone in-app ledger (escrow_wallets), independent
-- from driver_wallet, since either party can be any user role.

CREATE TABLE IF NOT EXISTS public.reservations (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  seller_id        uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  buyer_id         uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_title       text NOT NULL,
  invoice_total    numeric(10,2) NOT NULL CHECK (invoice_total > 0),
  duration_minutes integer NOT NULL CHECK (duration_minutes > 0),
  status           text NOT NULL DEFAULT 'pending_approval'
    CHECK (status IN (
      'pending_approval', 'reserved', 'completed',
      'cancelled', 'expired_buyer_penalized', 'cancelled_seller_penalized'
    )),
  penalty_amount   numeric(10,2),
  penalty_party    text CHECK (penalty_party IN ('buyer', 'seller')),
  cancel_reason    text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  approved_at      timestamptz,
  deadline         timestamptz,
  resolved_at      timestamptz,
  CHECK (buyer_id <> seller_id)
);

CREATE INDEX IF NOT EXISTS reservations_seller_idx ON public.reservations (seller_id, created_at DESC);
CREATE INDEX IF NOT EXISTS reservations_buyer_idx  ON public.reservations (buyer_id, created_at DESC);
CREATE INDEX IF NOT EXISTS reservations_sweep_idx  ON public.reservations (status, deadline) WHERE status = 'reserved';

-- ── Escrow ledger ────────────────────────────────────────────────────────────
-- One balance row per user. Negative balances are allowed for MVP: a penalty
-- debit is recorded even if the payer has no funds on hand (represents a debt
-- rather than blocking the transfer).
CREATE TABLE IF NOT EXISTS public.escrow_wallets (
  user_id    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  balance    numeric(10,2) NOT NULL DEFAULT 0.00,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.escrow_transactions (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  reservation_id uuid REFERENCES public.reservations(id) ON DELETE SET NULL,
  type           text NOT NULL CHECK (type IN ('penalty_debit', 'penalty_credit')),
  amount         numeric(10,2) NOT NULL,
  note           text,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS escrow_tx_user_idx ON public.escrow_transactions (user_id, created_at DESC);

-- ── RLS ──────────────────────────────────────────────────────────────────────
ALTER TABLE public.reservations       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.escrow_wallets     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.escrow_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY reservations_select_participant ON public.reservations
  FOR SELECT USING (auth.uid() = seller_id OR auth.uid() = buyer_id);

CREATE POLICY escrow_wallets_select_own ON public.escrow_wallets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY escrow_tx_select_own ON public.escrow_transactions
  FOR SELECT USING (auth.uid() = user_id);

-- No direct INSERT/UPDATE policies: all writes go through the SECURITY DEFINER
-- RPCs below, which run as the function owner and bypass RLS (same pattern as
-- driver_wallet_hold/driver_wallet_release in 20260522_wallet_functions.sql).

-- ── Lookup: resolve a buyer by phone without exposing the profiles table ──────
CREATE OR REPLACE FUNCTION find_user_by_phone(p_phone text)
RETURNS TABLE(id uuid, name text)
LANGUAGE sql SECURITY DEFINER AS $$
  SELECT auth_id, profiles.name FROM public.profiles WHERE phone = p_phone;
$$;
GRANT EXECUTE ON FUNCTION find_user_by_phone TO authenticated;

-- ── Create reservation (seller) ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION create_reservation(
  p_buyer_phone     text,
  p_item_title      text,
  p_invoice_total   numeric,
  p_duration_minutes integer
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_seller_id uuid := auth.uid();
  v_buyer_id  uuid;
  v_id        uuid;
BEGIN
  IF v_seller_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT auth_id INTO v_buyer_id FROM public.profiles WHERE phone = p_buyer_phone;
  IF v_buyer_id IS NULL THEN
    RAISE EXCEPTION 'رقم الهاتف غير مسجل';
  END IF;
  IF v_buyer_id = v_seller_id THEN
    RAISE EXCEPTION 'لا يمكن إنشاء حجز لنفسك';
  END IF;

  INSERT INTO public.reservations (seller_id, buyer_id, item_title, invoice_total, duration_minutes)
  VALUES (v_seller_id, v_buyer_id, p_item_title, p_invoice_total, p_duration_minutes)
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;
GRANT EXECUTE ON FUNCTION create_reservation TO authenticated;

-- ── Approve reservation (buyer locks it in, starts the deadline clock) ────────
CREATE OR REPLACE FUNCTION approve_reservation(p_reservation_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_buyer_id uuid := auth.uid();
  v_row      record;
BEGIN
  SELECT * INTO v_row FROM public.reservations WHERE id = p_reservation_id;
  IF v_row IS NULL THEN
    RAISE EXCEPTION 'الحجز غير موجود';
  END IF;
  IF v_row.buyer_id <> v_buyer_id THEN
    RAISE EXCEPTION 'غير مخول';
  END IF;
  IF v_row.status <> 'pending_approval' THEN
    RAISE EXCEPTION 'لا يمكن قبول هذا الحجز في وضعه الحالي';
  END IF;

  UPDATE public.reservations
  SET status = 'reserved',
      approved_at = now(),
      deadline = now() + (v_row.duration_minutes || ' minutes')::interval
  WHERE id = p_reservation_id;
END;
$$;
GRANT EXECUTE ON FUNCTION approve_reservation TO authenticated;

-- ── Complete reservation (either party, before deadline) ───────────────────────
CREATE OR REPLACE FUNCTION complete_reservation(p_reservation_id uuid)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_row record;
BEGIN
  SELECT * INTO v_row FROM public.reservations WHERE id = p_reservation_id;
  IF v_row IS NULL THEN
    RAISE EXCEPTION 'الحجز غير موجود';
  END IF;
  IF v_uid NOT IN (v_row.seller_id, v_row.buyer_id) THEN
    RAISE EXCEPTION 'غير مخول';
  END IF;
  IF v_row.status <> 'reserved' THEN
    RAISE EXCEPTION 'لا يمكن إتمام هذا الحجز في وضعه الحالي';
  END IF;
  IF v_row.deadline IS NOT NULL AND now() > v_row.deadline THEN
    RAISE EXCEPTION 'انتهى الوقت المحدد للحجز';
  END IF;

  UPDATE public.reservations
  SET status = 'completed', resolved_at = now()
  WHERE id = p_reservation_id;
END;
$$;
GRANT EXECUTE ON FUNCTION complete_reservation TO authenticated;

-- ── Internal: move 10% between two escrow wallets + ledger entries ────────────
CREATE OR REPLACE FUNCTION apply_escrow_penalty(
  p_reservation_id uuid,
  p_payer_id       uuid,
  p_payee_id       uuid,
  p_amount         numeric,
  p_note_payer     text,
  p_note_payee     text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.escrow_wallets (user_id) VALUES (p_payer_id) ON CONFLICT DO NOTHING;
  INSERT INTO public.escrow_wallets (user_id) VALUES (p_payee_id) ON CONFLICT DO NOTHING;

  UPDATE public.escrow_wallets SET balance = balance - p_amount, updated_at = now() WHERE user_id = p_payer_id;
  UPDATE public.escrow_wallets SET balance = balance + p_amount, updated_at = now() WHERE user_id = p_payee_id;

  INSERT INTO public.escrow_transactions (user_id, reservation_id, type, amount, note)
  VALUES (p_payer_id, p_reservation_id, 'penalty_debit', p_amount, p_note_payer);
  INSERT INTO public.escrow_transactions (user_id, reservation_id, type, amount, note)
  VALUES (p_payee_id, p_reservation_id, 'penalty_credit', p_amount, p_note_payee);
END;
$$;

-- ── Cancel reservation (seller). 'sold_elsewhere' during an active reservation
-- is treated as fraud and immediately penalizes the seller. Any other reason,
-- or cancelling before the buyer approved, is a plain no-penalty cancel. ───────
CREATE OR REPLACE FUNCTION cancel_reservation(p_reservation_id uuid, p_reason text)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_seller_id uuid := auth.uid();
  v_row       record;
  v_penalty   numeric(10,2);
BEGIN
  SELECT * INTO v_row FROM public.reservations WHERE id = p_reservation_id;
  IF v_row IS NULL THEN
    RAISE EXCEPTION 'الحجز غير موجود';
  END IF;
  IF v_row.seller_id <> v_seller_id THEN
    RAISE EXCEPTION 'غير مخول';
  END IF;
  IF v_row.status NOT IN ('pending_approval', 'reserved') THEN
    RAISE EXCEPTION 'لا يمكن إلغاء هذا الحجز في وضعه الحالي';
  END IF;

  IF v_row.status = 'reserved' AND p_reason = 'sold_elsewhere' THEN
    v_penalty := round(v_row.invoice_total * 0.10, 2);
    PERFORM apply_escrow_penalty(
      p_reservation_id, v_seller_id, v_row.buyer_id, v_penalty,
      'غرامة بيع البضاعة لطرف آخر خلال فترة الحجز',
      'تعويض عن إلغاء الحجز من طرف البائع'
    );
    UPDATE public.reservations
    SET status = 'cancelled_seller_penalized',
        penalty_amount = v_penalty,
        penalty_party = 'seller',
        cancel_reason = p_reason,
        resolved_at = now()
    WHERE id = p_reservation_id;
  ELSE
    UPDATE public.reservations
    SET status = 'cancelled', cancel_reason = p_reason, resolved_at = now()
    WHERE id = p_reservation_id;
  END IF;
END;
$$;
GRANT EXECUTE ON FUNCTION cancel_reservation TO authenticated;

-- ── Scheduled sweep: buyer didn't complete before deadline → buyer pays seller ─
CREATE OR REPLACE FUNCTION sweep_expired_reservations()
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  r record;
  v_penalty numeric(10,2);
BEGIN
  FOR r IN
    SELECT * FROM public.reservations
    WHERE status = 'reserved' AND deadline IS NOT NULL AND deadline < now()
  LOOP
    v_penalty := round(r.invoice_total * 0.10, 2);
    PERFORM apply_escrow_penalty(
      r.id, r.buyer_id, r.seller_id, v_penalty,
      'غرامة عدم إتمام الشراء ضمن الوقت المحدد',
      'تعويض عن انتهاء وقت الحجز دون شراء'
    );
    UPDATE public.reservations
    SET status = 'expired_buyer_penalized',
        penalty_amount = v_penalty,
        penalty_party = 'buyer',
        resolved_at = now()
    WHERE id = r.id;
  END LOOP;
END;
$$;

-- pg_cron may require the extension to be enabled from the Supabase dashboard
-- (Database → Extensions) on some projects before this CREATE EXTENSION call
-- is permitted. If this statement fails, enable it there and re-run just the
-- block below.
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'sweep-expired-reservations',
  '* * * * *',
  $$SELECT sweep_expired_reservations();$$
);

ALTER PUBLICATION supabase_realtime ADD TABLE public.reservations;
