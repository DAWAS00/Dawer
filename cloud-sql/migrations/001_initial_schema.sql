-- ============================================================
-- Dawer — Cloud SQL Schema (Firebase Auth + Cloud Run)
-- Adapted from Supabase migrations for GCP backend
--
-- Key differences from Supabase schema:
--   - auth_id (UUID → auth.users) replaced by firebase_uid (TEXT)
--   - auth.uid() removed — authorization enforced in Cloud Run
--   - RLS removed — Cloud Run service accounts enforce access control
--   - storage.* removed — Cloud Storage (GCS) used instead
--   - pg_cron replaced by Cloud Scheduler (external)
-- ============================================================

-- ── Extensions ─────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ── Enums ──────────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('driver', 'supplier', 'recyclingCo');
CREATE TYPE supplier_type AS ENUM ('individual', 'storeBusiness');

CREATE TYPE order_type AS ENUM ('pickup', 'collection', 'collectionSale');
CREATE TYPE order_status AS ENUM ('pending', 'accepted', 'inTransit', 'completed', 'cancelled');
CREATE TYPE waste_form AS ENUM ('solid', 'liquid', 'mixed');
CREATE TYPE weight_category AS ENUM ('light', 'medium', 'heavy', 'veryHeavy');
CREATE TYPE pickup_target AS ENUM ('company', 'riderBuy');
CREATE TYPE cancel_actor AS ENUM ('supplier', 'driver', 'system');
CREATE TYPE payment_model AS ENUM ('perKg', 'flatFee');
CREATE TYPE collection_delivery_method AS ENUM ('selfDelivery', 'riderPickup');
CREATE TYPE collection_transaction_type AS ENUM ('buy', 'sell');
CREATE TYPE transaction_status AS ENUM ('pending', 'paid', 'failed');

CREATE TYPE notification_type AS ENUM (
  'newOrderAvailable', 'orderAccepted', 'orderInTransit', 'orderCompleted',
  'orderCancelledBySupplier', 'orderCancelledByDriver',
  'collectionJobPosted', 'collectionJobAccepted',
  'collectionSaleInTransit', 'collectionSaleCompleted',
  'newIncomingShipment', 'pointsEarned'
);

-- ── Tables ─────────────────────────────────────────────────────

CREATE TABLE public.users (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid        TEXT UNIQUE NOT NULL,  -- Firebase Auth UID (replaces auth.users ref)
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
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.orders (
  id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type                        order_type NOT NULL,
  status                      order_status NOT NULL DEFAULT 'pending',
  supplier_id                 UUID REFERENCES public.users(id),
  driver_id                   UUID REFERENCES public.users(id),
  company_id                  UUID REFERENCES public.users(id),
  waste_types                 TEXT[] NOT NULL DEFAULT '{}'
    CHECK (waste_types <@ ARRAY[
      'paper','plastic','metal','glass','electronics',
      'organic','textile','wood','rubber','oil',
      'chemicals','batteries','furniture','tires','construction'
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
  proof_photo_url             TEXT,  -- GCS signed URL path (Cloud Storage)
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
  in_transit_at               TIMESTAMPTZ,
  completed_at                TIMESTAMPTZ,
  updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.notifications (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipient_id  UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type          notification_type NOT NULL,
  title         TEXT NOT NULL,
  body          TEXT NOT NULL,
  order_id      UUID REFERENCES public.orders(id),
  job_id        UUID REFERENCES public.orders(id),
  is_read       BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.transactions (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id         UUID UNIQUE NOT NULL REFERENCES public.orders(id),
  driver_id        UUID NOT NULL REFERENCES public.users(id),
  base_fee_jd      NUMERIC NOT NULL DEFAULT 1.500,
  distance_fee_jd  NUMERIC NOT NULL DEFAULT 0,
  material_fee_jd  NUMERIC NOT NULL DEFAULT 0,
  urgency_bonus_jd NUMERIC NOT NULL DEFAULT 0,
  vat_jd           NUMERIC NOT NULL DEFAULT 0,
  total_jd         NUMERIC GENERATED ALWAYS AS (base_fee_jd + distance_fee_jd + material_fee_jd + urgency_bonus_jd + vat_jd) STORED,
  status           transaction_status NOT NULL DEFAULT 'pending',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Indexes ────────────────────────────────────────────────────
CREATE INDEX idx_users_firebase_uid    ON public.users(firebase_uid);
CREATE INDEX idx_users_phone           ON public.users(phone);
CREATE INDEX idx_users_role            ON public.users(role);
CREATE INDEX idx_users_location        ON public.users USING GIST(location);

CREATE INDEX idx_orders_status         ON public.orders(status);
CREATE INDEX idx_orders_supplier_id    ON public.orders(supplier_id);
CREATE INDEX idx_orders_driver_id      ON public.orders(driver_id);
CREATE INDEX idx_orders_company_id     ON public.orders(company_id);
CREATE INDEX idx_orders_pickup_loc     ON public.orders USING GIST(pickup_location);
CREATE INDEX idx_orders_created_at     ON public.orders(created_at DESC);

CREATE INDEX idx_notifications_recipient ON public.notifications(recipient_id);
CREATE INDEX idx_notifications_unread    ON public.notifications(recipient_id) WHERE is_read = false;

CREATE INDEX idx_transactions_driver     ON public.transactions(driver_id);

-- ── Functions ──────────────────────────────────────────────────

-- Lookup user by Firebase UID (used internally by Cloud Run services)
CREATE OR REPLACE FUNCTION get_user_by_firebase_uid(uid TEXT)
RETURNS public.users LANGUAGE sql STABLE AS $$
  SELECT * FROM public.users WHERE firebase_uid = uid LIMIT 1;
$$;

-- Find drivers within radius_km of a point (used by geo-svc)
CREATE OR REPLACE FUNCTION nearby_drivers(lat FLOAT, lng FLOAT, radius_km FLOAT DEFAULT 15)
RETURNS TABLE (id UUID, name TEXT, fcm_token TEXT, distance_m FLOAT)
LANGUAGE sql STABLE AS $$
  SELECT u.id, u.name, u.fcm_token,
    ST_Distance(u.location, ST_MakePoint(lng, lat)::GEOGRAPHY) AS distance_m
  FROM public.users u
  WHERE u.role = 'driver'
    AND u.is_available = true
    AND u.location IS NOT NULL
    AND ST_DWithin(u.location, ST_MakePoint(lng, lat)::GEOGRAPHY, radius_km * 1000)
  ORDER BY distance_m;
$$;

-- Find pending orders near a point (used by driver home screen)
CREATE OR REPLACE FUNCTION nearby_orders(lat FLOAT, lng FLOAT, radius_km FLOAT DEFAULT 15)
RETURNS SETOF public.orders LANGUAGE sql STABLE AS $$
  SELECT * FROM public.orders
  WHERE status = 'pending'
    AND ST_DWithin(pickup_location, ST_MakePoint(lng, lat)::GEOGRAPHY, radius_km * 1000)
  ORDER BY pickup_location <-> ST_MakePoint(lng, lat)::GEOGRAPHY;
$$;

-- Check whether a phone is already registered
CREATE OR REPLACE FUNCTION phone_exists(phone_number TEXT)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM public.users WHERE phone = phone_number);
$$;

-- ── Trigger Functions ──────────────────────────────────────────

-- Auto-update updated_at on any row change
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Enforce valid order status transitions and auto-fill timestamps
CREATE OR REPLACE FUNCTION enforce_order_status_transition()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status IN ('completed', 'cancelled') THEN
    RAISE EXCEPTION 'Order % is terminal (%). No transitions allowed.', OLD.id, OLD.status;
  END IF;
  IF NOT (
    (OLD.status = 'pending'   AND NEW.status IN ('accepted', 'cancelled')) OR
    (OLD.status = 'accepted'  AND NEW.status IN ('inTransit', 'cancelled')) OR
    (OLD.status = 'inTransit' AND NEW.status IN ('completed', 'cancelled'))
  ) THEN
    RAISE EXCEPTION 'Invalid status transition: % -> %', OLD.status, NEW.status;
  END IF;
  IF NEW.status = 'accepted'  AND NEW.accepted_at   IS NULL THEN NEW.accepted_at   := now(); END IF;
  IF NEW.status = 'inTransit' AND NEW.in_transit_at IS NULL THEN NEW.in_transit_at := now(); END IF;
  IF NEW.status = 'completed' AND NEW.completed_at  IS NULL THEN NEW.completed_at  := now(); END IF;
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
        AND status IN ('accepted', 'inTransit')
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
    UPDATE public.users
      SET points = points + earned_points,
          total_orders = total_orders + 1
      WHERE id = NEW.supplier_id;
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

-- Increment driver total_orders on completion
CREATE OR REPLACE FUNCTION update_driver_total_orders()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status <> 'completed' AND NEW.driver_id IS NOT NULL THEN
    UPDATE public.users SET total_orders = total_orders + 1 WHERE id = NEW.driver_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_driver_total_orders
  AFTER UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION update_driver_total_orders();
