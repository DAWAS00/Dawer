-- ── Wallet RPC: hold expected payout when driver accepts an order ─────────────
-- Called with the driver's JWT. SECURITY DEFINER bypasses the service_role-only
-- write RLS on driver_wallet and wallet_transactions.
CREATE OR REPLACE FUNCTION driver_wallet_hold(
  p_order_id text,
  p_amount   numeric
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_driver_id uuid := auth.uid();
BEGIN
  IF v_driver_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  INSERT INTO driver_wallet (driver_id)
  VALUES (v_driver_id)
  ON CONFLICT (driver_id) DO NOTHING;

  UPDATE driver_wallet
  SET held_amount = held_amount + p_amount,
      updated_at  = now()
  WHERE driver_id = v_driver_id;

  INSERT INTO wallet_transactions (driver_id, order_id, type, amount, note)
  VALUES (v_driver_id, p_order_id, 'hold', p_amount, 'قبول الطلب');
END;
$$;
GRANT EXECUTE ON FUNCTION driver_wallet_hold TO authenticated;

-- ── Wallet RPC: release held amount → balance when order completes ────────────
CREATE OR REPLACE FUNCTION driver_wallet_release(
  p_order_id text,
  p_amount   numeric
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_driver_id uuid := auth.uid();
BEGIN
  IF v_driver_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE driver_wallet
  SET held_amount = GREATEST(0, held_amount - p_amount),
      balance     = balance + p_amount,
      updated_at  = now()
  WHERE driver_id = v_driver_id;

  INSERT INTO wallet_transactions (driver_id, order_id, type, amount, note)
  VALUES (v_driver_id, p_order_id, 'release', p_amount, 'إتمام الطلب');
END;
$$;
GRANT EXECUTE ON FUNCTION driver_wallet_release TO authenticated;

-- ── Trigger: auto-credit driver compensation on cancellation ──────────────────
-- Fires after an order row transitions to 'cancelled' with a non-null
-- driver_compensation_amount. Runs as the function owner (SECURITY DEFINER)
-- so it can write to driver_wallet regardless of the caller's role.
--
-- orders.driver_id IS the auth.users.id (= profiles.auth_id), the same key space
-- as driver_wallet.driver_id, so no cross-table mapping is needed.
CREATE OR REPLACE FUNCTION auto_credit_driver_compensation()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_auth_id uuid;
  v_amount  numeric;
BEGIN
  -- Only fire when order is freshly cancelled with a compensation amount set
  IF NEW.status <> 'cancelled'
    OR NEW.driver_compensation_amount IS NULL
    OR NEW.driver_id IS NULL
    -- Skip if compensation was already the same value (avoid double-crediting on
    -- unrelated updates to the same cancelled row)
    OR (OLD.status = 'cancelled'
        AND OLD.driver_compensation_amount IS NOT DISTINCT FROM NEW.driver_compensation_amount)
  THEN
    RETURN NEW;
  END IF;

  -- driver_id is already the auth id.
  v_auth_id := NEW.driver_id;
  v_amount := NEW.driver_compensation_amount;

  -- Ensure wallet row exists for this driver
  INSERT INTO driver_wallet (driver_id)
  VALUES (v_auth_id)
  ON CONFLICT (driver_id) DO NOTHING;

  -- Release whatever was held for this order, then credit the compensation.
  -- We subtract the hold first to avoid double-counting if hold was already set.
  UPDATE driver_wallet
  SET held_amount = GREATEST(0, held_amount - COALESCE(
        (SELECT amount FROM wallet_transactions
         WHERE driver_id = v_auth_id
           AND order_id  = NEW.id::text
           AND type      = 'hold'
         ORDER BY created_at DESC
         LIMIT 1), 0)),
      balance     = balance + v_amount,
      updated_at  = now()
  WHERE driver_id = v_auth_id;

  INSERT INTO wallet_transactions (driver_id, order_id, type, amount, note)
  VALUES (
    v_auth_id,
    NEW.id::text,
    'penalty',
    v_amount,
    CASE NEW.arrival_confirmation_status
      WHEN 'unavailable' THEN 'عدم توفر البضاعة — تعويض السائق'
      WHEN 'timedOut'    THEN 'انتهاء وقت الانتظار — تعويض السائق'
      ELSE                    'إلغاء الطلب — تعويض السائق'
    END
  );

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auto_credit_driver_compensation
  AFTER UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION auto_credit_driver_compensation();
