-- ============================================================
-- Dwaar (دوّر) — Full initial schema
-- Apply this in: Supabase Dashboard → SQL Editor → Run
--
-- Key-space note: the app uses `auth.users.id` (auth.uid()) as the single
-- canonical user id everywhere. The profile table is therefore keyed by
-- `auth_id` (PK = auth.users.id), and every user-referencing FK points at
-- `public.profiles(auth_id)`. There is NO surrogate user id.
-- ============================================================

-- ── Extensions ────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ── Enums ─────────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('driver', 'supplier', 'recyclingCo');
CREATE TYPE supplier_type AS ENUM ('individual', 'storeBusiness');

CREATE TYPE order_type AS ENUM ('pickup', 'collection', 'collectionSale');
CREATE TYPE order_status AS ENUM (
  'pending', 'accepted', 'arrivedAtPickup', 'inTransit',
  'arrivedAtDropoff', 'completed', 'cancelled'
);
CREATE TYPE waste_form AS ENUM ('solid', 'liquid', 'gas', 'mixed');
CREATE TYPE weight_category AS ENUM ('light', 'medium', 'heavy', 'veryHeavy');
CREATE TYPE pickup_target AS ENUM ('company', 'riderBuy');
CREATE TYPE cancel_actor AS ENUM ('supplier', 'driver', 'system');
CREATE TYPE payment_model AS ENUM ('perKg', 'flatFee');
CREATE TYPE collection_delivery_method AS ENUM ('selfDelivery', 'assignRider');
CREATE TYPE collection_transaction_type AS ENUM ('donate', 'sell');
CREATE TYPE transaction_status AS ENUM ('pending', 'paid', 'failed');

CREATE TYPE notification_type AS ENUM (
  'newOrderAvailable', 'orderAccepted', 'orderInTransit', 'orderCompleted',
  'orderCancelledBySupplier', 'orderCancelledByDriver',
  'collectionJobPosted', 'collectionJobAccepted',
  'collectionSaleInTransit', 'collectionSaleCompleted',
  'newIncomingShipment', 'pointsEarned'
);

-- ── Helper: auto-confirm email on signup (dev convenience) ────
CREATE OR REPLACE FUNCTION auto_confirm_user()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.email_confirmed_at = now();
  NEW.confirmed_at = now();
  NEW.raw_app_meta_data = jsonb_set(
    COALESCE(NEW.raw_app_meta_data, '{}'::jsonb),
    '{email_verified}',
    'true'::jsonb
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  BEFORE INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION auto_confirm_user();

-- ── Tables ────────────────────────────────────────────────────

-- profiles: PK is the auth.users id. Matches the app's `.from('profiles')`
-- calls, which insert/select on `auth_id` and treat it as the user id.
CREATE TABLE public.profiles (
  auth_id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name                TEXT NOT NULL,
  phone               TEXT UNIQUE NOT NULL,
  email               TEXT,
  role                user_role NOT NULL,
  supplier_type       supplier_type,
  rating              NUMERIC(3,2) NOT NULL DEFAULT 5.00,
  total_orders        INTEGER NOT NULL DEFAULT 0,
  is_verified         BOOLEAN NOT NULL DEFAULT false,
  is_available        BOOLEAN NOT NULL DEFAULT true,
  points              INTEGER NOT NULL DEFAULT 0,
  location            GEOGRAPHY(POINT, 4326),
  vehicle_model       TEXT,
  vehicle_color       TEXT,
  vehicle_plate       TEXT,
  vehicle_photo_url   TEXT,
  address             TEXT,
  fcm_token           TEXT,
  profile_photo_url   TEXT,
  identity_doc_path   TEXT,
  categories          TEXT[] NOT NULL DEFAULT '{}',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.orders (
  id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type                        order_type NOT NULL,
  status                      order_status NOT NULL DEFAULT 'pending',
  supplier_id                 UUID REFERENCES public.profiles(auth_id),
  driver_id                   UUID REFERENCES public.profiles(auth_id),
  company_id                  UUID REFERENCES public.profiles(auth_id),
  waste_types                 TEXT[] NOT NULL DEFAULT '{}'
    CONSTRAINT orders_waste_types_check CHECK (waste_types <@ ARRAY[
      'paper','plastic','metal','glass','electronics',
      'organic','textile','wood','rubber','oil',
      'chemicals','batteries','furniture','tires','construction',
      'copperAluminium'
    ]::TEXT[]),
  waste_form                  waste_form,
  weight_category             weight_category,
  pickup_target               pickup_target NOT NULL DEFAULT 'company',
  pickup_location             GEOGRAPHY(POINT, 4326) NOT NULL DEFAULT ST_MakePoint(35.9106, 31.9539)::GEOGRAPHY,
  dropoff_location            GEOGRAPHY(POINT, 4326),
  estimated_weight_kg         NUMERIC NOT NULL DEFAULT 0,
  actual_weight_kg            NUMERIC,
  distance_km                 NUMERIC NOT NULL DEFAULT 0,
  reward_jd                   NUMERIC NOT NULL DEFAULT 0,
  is_urgent                   BOOLEAN NOT NULL DEFAULT false,
  proof_photo_url             TEXT,
  linked_job_id               UUID REFERENCES public.orders(id),
  cancelled_by                cancel_actor,
  notes                       TEXT,
  is_marketplace_shared       BOOLEAN DEFAULT false,
  requires_rider              BOOLEAN DEFAULT false,
  -- collection-job fields
  job_description             TEXT,
  payment_model               payment_model,
  price_per_kg                NUMERIC,
  item_price                  NUMERIC,
  min_quantity_kg             NUMERIC,
  collection_delivery_method  collection_delivery_method,
  collection_transaction_type collection_transaction_type,
  -- timestamps
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at                 TIMESTAMPTZ,
  arrived_at_pickup_at        TIMESTAMPTZ,  -- referenced by enforce_order_status_transition below
  arrived_at_dropoff_at       TIMESTAMPTZ,  --   (also re-added idempotently in 20260519)
  in_transit_at               TIMESTAMPTZ,
  completed_at                TIMESTAMPTZ
);

CREATE TABLE public.notifications (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id  UUID NOT NULL REFERENCES public.profiles(auth_id) ON DELETE CASCADE,
  type          notification_type NOT NULL,
  title         TEXT NOT NULL,
  body          TEXT NOT NULL,
  order_id      UUID REFERENCES public.orders(id),
  job_id        UUID REFERENCES public.orders(id),
  is_read       BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id        UUID UNIQUE NOT NULL REFERENCES public.orders(id),
  driver_id       UUID NOT NULL REFERENCES public.profiles(auth_id),
  base_fee_jd     NUMERIC NOT NULL DEFAULT 1.500,
  distance_fee_jd NUMERIC NOT NULL DEFAULT 0,
  material_fee_jd NUMERIC NOT NULL DEFAULT 0,
  urgency_bonus_jd NUMERIC NOT NULL DEFAULT 0,
  total_jd        NUMERIC GENERATED ALWAYS AS (base_fee_jd + distance_fee_jd + material_fee_jd + urgency_bonus_jd) STORED,
  status          transaction_status NOT NULL DEFAULT 'pending',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Functions ─────────────────────────────────────────────────

-- The canonical user id IS the auth id. Kept as a function so existing
-- RLS policies (`supplier_id = current_user_id()`, etc.) need no rewrite.
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID LANGUAGE sql STABLE AS $$
  SELECT auth.uid();
$$;

-- Lookup email by phone (used for phone-based sign-in)
CREATE OR REPLACE FUNCTION get_email_by_phone(phone_number TEXT)
RETURNS TEXT LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT email FROM public.profiles WHERE phone = phone_number LIMIT 1;
$$;

-- Check whether a phone or email is already registered
CREATE OR REPLACE FUNCTION identifier_exists(identifier TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles u
    WHERE u.phone = identifier
       OR (u.email IS NOT NULL AND lower(u.email) = lower(identifier))
  );
$$;

-- True when the caller is a driver marked available
CREATE OR REPLACE FUNCTION is_available_driver()
RETURNS BOOLEAN LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE auth_id = auth.uid()
      AND role = 'driver'
      AND is_available = true
  );
$$;

-- Find drivers within radius_km of a point
CREATE OR REPLACE FUNCTION nearby_drivers(lat FLOAT, lng FLOAT, radius_km FLOAT DEFAULT 10)
RETURNS TABLE (id UUID, name TEXT, fcm_token TEXT, distance_m FLOAT)
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT u.auth_id AS id, u.name, u.fcm_token,
    ST_Distance(u.location, ST_MakePoint(lng, lat)::GEOGRAPHY) AS distance_m
  FROM public.profiles u
  WHERE u.role = 'driver' AND u.is_available = true AND u.location IS NOT NULL
    AND ST_DWithin(u.location, ST_MakePoint(lng, lat)::GEOGRAPHY, radius_km * 1000)
  ORDER BY distance_m;
$$;

-- Find pending orders near a point
CREATE OR REPLACE FUNCTION nearby_orders(lat FLOAT, lng FLOAT, radius_km FLOAT DEFAULT 10)
RETURNS SETOF public.orders LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT * FROM public.orders
  WHERE status = 'pending'
    AND ST_DWithin(pickup_location, ST_MakePoint(lng, lat)::GEOGRAPHY, radius_km * 1000)
  ORDER BY pickup_location <-> ST_MakePoint(lng, lat)::GEOGRAPHY;
$$;

-- ── Trigger functions ─────────────────────────────────────────

-- Enforce valid order status transitions and auto-fill timestamps
CREATE OR REPLACE FUNCTION enforce_order_status_transition()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status IN ('completed', 'cancelled') THEN
    RAISE EXCEPTION 'Order % is terminal (%). No transitions allowed.', OLD.id, OLD.status;
  END IF;
  -- Cancellation is allowed from any non-terminal state.
  IF NEW.status <> 'cancelled' AND NOT (
    (OLD.status = 'pending'          AND NEW.status = 'accepted') OR
    (OLD.status = 'accepted'         AND NEW.status IN ('arrivedAtPickup', 'inTransit')) OR
    (OLD.status = 'arrivedAtPickup'  AND NEW.status = 'inTransit') OR
    (OLD.status = 'inTransit'        AND NEW.status IN ('arrivedAtDropoff', 'completed')) OR
    (OLD.status = 'arrivedAtDropoff' AND NEW.status = 'completed')
  ) THEN
    RAISE EXCEPTION 'Invalid status transition: % -> %', OLD.status, NEW.status;
  END IF;
  IF NEW.status = 'accepted'         AND NEW.accepted_at          IS NULL THEN NEW.accepted_at          := now(); END IF;
  IF NEW.status = 'arrivedAtPickup'  AND NEW.arrived_at_pickup_at IS NULL THEN NEW.arrived_at_pickup_at := now(); END IF;
  IF NEW.status = 'inTransit'        AND NEW.in_transit_at        IS NULL THEN NEW.in_transit_at        := now(); END IF;
  IF NEW.status = 'completed'        AND NEW.completed_at         IS NULL THEN NEW.completed_at         := now(); END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_order_status_transition
  BEFORE UPDATE ON public.orders
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION enforce_order_status_transition();

-- Prevent a driver from holding more than one active order
CREATE OR REPLACE FUNCTION enforce_driver_single_active_order()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE active_count INTEGER;
BEGIN
  IF NEW.driver_id IS NOT NULL AND NEW.status = 'accepted' THEN
    SELECT COUNT(*) INTO active_count FROM public.orders
      WHERE driver_id = NEW.driver_id
        AND status IN ('accepted', 'arrivedAtPickup', 'inTransit', 'arrivedAtDropoff')
        AND id <> NEW.id;
    IF active_count > 0 THEN
      RAISE EXCEPTION 'Driver % already has an active order.', NEW.driver_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_driver_single_active
  BEFORE INSERT OR UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION enforce_driver_single_active_order();

-- Award points to supplier when an order is completed
CREATE OR REPLACE FUNCTION update_supplier_points_on_complete()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  material TEXT;
  multiplier NUMERIC;
  earned_points INTEGER;
BEGIN
  IF NEW.status = 'completed' AND OLD.status <> 'completed' AND NEW.supplier_id IS NOT NULL THEN
    material := NEW.waste_types[1];
    multiplier := CASE material
      WHEN 'paper'       THEN 1.0
      WHEN 'plastic'     THEN 2.0
      WHEN 'metal'       THEN 3.0
      WHEN 'electronics' THEN 5.0
      WHEN 'glass'       THEN 1.0
      WHEN 'organic'     THEN 0.5
      ELSE 1.0
    END;
    earned_points := FLOOR(COALESCE(NEW.estimated_weight_kg, 1) * multiplier);
    UPDATE public.profiles
      SET points = points + earned_points, total_orders = total_orders + 1
      WHERE auth_id = NEW.supplier_id;
    INSERT INTO public.notifications (recipient_id, type, title, body, order_id)
    VALUES (
      NEW.supplier_id, 'pointsEarned', 'نقاط مكتسبة!',
      'حصلت على ' || earned_points || ' نقطة من طلبك', NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_supplier_points
  AFTER UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION update_supplier_points_on_complete();

-- ── Row-Level Security ─────────────────────────────────────────

ALTER TABLE public.profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions  ENABLE ROW LEVEL SECURITY;

-- profiles
CREATE POLICY profiles_select_own ON public.profiles FOR SELECT USING (auth.uid() = auth_id);
CREATE POLICY profiles_insert_own ON public.profiles FOR INSERT WITH CHECK (auth.uid() = auth_id);
CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE USING (auth.uid() = auth_id) WITH CHECK (auth.uid() = auth_id);
CREATE POLICY profiles_select_participant ON public.profiles FOR SELECT USING (
  auth_id IN (
    SELECT supplier_id FROM public.orders WHERE driver_id = current_user_id()
    UNION
    SELECT driver_id   FROM public.orders WHERE supplier_id = current_user_id()
    UNION
    SELECT company_id  FROM public.orders WHERE driver_id = current_user_id()
  )
);

-- orders — insert
CREATE POLICY orders_insert_supplier ON public.orders FOR INSERT WITH CHECK (
  (supplier_id = current_user_id()) OR (company_id = current_user_id())
);

-- orders — select
CREATE POLICY orders_select_own_supplier ON public.orders FOR SELECT USING (supplier_id = current_user_id());
CREATE POLICY orders_select_own_driver   ON public.orders FOR SELECT USING (driver_id   = current_user_id());
CREATE POLICY orders_select_own_company  ON public.orders FOR SELECT USING (company_id  = current_user_id());
CREATE POLICY orders_select_pending_for_drivers ON public.orders FOR SELECT USING (
  (status = 'pending') OR
  (status = 'accepted' AND requires_rider = true AND driver_id IS NULL)
);

-- orders — update
CREATE POLICY orders_update_driver        ON public.orders FOR UPDATE USING (driver_id = current_user_id());
CREATE POLICY orders_update_driver_accept ON public.orders FOR UPDATE
  USING  ((status = 'pending') OR (status = 'accepted' AND requires_rider = true AND driver_id IS NULL))
  WITH CHECK (driver_id = auth.uid());
CREATE POLICY orders_update_supplier_cancel ON public.orders FOR UPDATE
  USING (supplier_id = current_user_id() AND status = ANY(ARRAY['pending'::order_status, 'accepted'::order_status]));

-- notifications
CREATE POLICY notifications_select_own      ON public.notifications FOR SELECT USING (recipient_id = current_user_id());
CREATE POLICY notifications_update_read_own ON public.notifications FOR UPDATE
  USING (recipient_id = current_user_id()) WITH CHECK (recipient_id = current_user_id());

-- transactions
CREATE POLICY transactions_select_driver  ON public.transactions FOR SELECT USING (driver_id = current_user_id());
CREATE POLICY transactions_select_company ON public.transactions FOR SELECT USING (
  order_id IN (SELECT id FROM public.orders WHERE company_id = current_user_id())
);

-- ── Realtime ───────────────────────────────────────────────────
-- SupabaseOrderRepository.watchOrders() uses .stream(); orders must be in the
-- realtime publication for live INSERT/UPDATE events to reach clients.
ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;

-- ── Storage buckets ────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('profile-photos', 'profile-photos', true,  5242880,  ARRAY['image/jpeg','image/png','image/webp']),
  ('user-documents', 'user-documents', false, 10485760, ARRAY['image/jpeg','image/png','image/webp','application/pdf']),
  ('proof-photos',   'proof-photos',   false, null,     null)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS policies
CREATE POLICY "profile_photos_public_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-photos');

CREATE POLICY "profile_photos_owner_write"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'profile-photos' AND auth.uid()::TEXT = (storage.foldername(name))[1]);

CREATE POLICY "user_docs_owner_read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'user-documents' AND auth.uid()::TEXT = (storage.foldername(name))[1]);

CREATE POLICY "user_docs_owner_write"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'user-documents' AND auth.uid()::TEXT = (storage.foldername(name))[1]);

CREATE POLICY "proof_photos_driver_write"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'proof-photos' AND auth.uid()::TEXT = (storage.foldername(name))[1]);

CREATE POLICY "proof_photos_participant_read"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'proof-photos' AND
    EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.proof_photo_url LIKE '%' || name || '%'
        AND (o.supplier_id = current_user_id() OR o.driver_id = current_user_id() OR o.company_id = current_user_id())
    )
  );
