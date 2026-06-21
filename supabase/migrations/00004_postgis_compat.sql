-- ─────────────────────────────────────────────────────────────────────────────
-- 00004_postgis_compat.sql — numeric lat/lng columns + geography auto-population
--
-- WHY: PostgREST does not auto-cast text ('POINT(lng lat)' / 'SRID=4326;...')
-- to geography. The Flutter client cannot reliably write geography values via
-- `.insert()` / `.update()`. The previous toSupabaseMap shipped WKT/EWKT
-- strings, which PostgREST rejects (42804 / 22P02) → every order insert failed.
--
-- FIX: add plain double-precision lat/lng columns the client CAN write, and
-- populate the existing geography columns from them via triggers. The
-- `nearby_drivers` / `nearby_orders` functions keep using the geography
-- columns unchanged. This is the standard Supabase+Flutter geo pattern.
--
-- Backfill: existing geography values (if any) are mirrored into the numeric
-- columns so no data is lost.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── orders: numeric pickup / dropoff coordinates ──────────────────────────────
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS pickup_lat  double precision,
  ADD COLUMN IF NOT EXISTS pickup_lng  double precision,
  ADD COLUMN IF NOT EXISTS dropoff_lat double precision,
  ADD COLUMN IF NOT EXISTS dropoff_lng double precision;

-- Backfill numeric columns from existing geography (one-time, safe if null).
UPDATE public.orders
  SET pickup_lat  = ST_Y(pickup_location::geometry),
      pickup_lng  = ST_X(pickup_location::geometry)
  WHERE pickup_location IS NOT NULL AND pickup_lat IS NULL;

UPDATE public.orders
  SET dropoff_lat = ST_Y(dropoff_location::geometry),
      dropoff_lng = ST_X(dropoff_location::geometry)
  WHERE dropoff_location IS NOT NULL AND dropoff_lat IS NULL;

-- Trigger: keep pickup_location / dropoff_location in sync with the numeric
-- columns whenever a row is written. If lat/lng are null, leave the geography
-- column to its default (the table default handles it).
CREATE OR REPLACE FUNCTION public.sync_orders_geography()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.pickup_lat IS NOT NULL AND NEW.pickup_lng IS NOT NULL THEN
    NEW.pickup_location := ST_MakePoint(NEW.pickup_lng, NEW.pickup_lat)::geography;
  END IF;
  IF NEW.dropoff_lat IS NOT NULL AND NEW.dropoff_lng IS NOT NULL THEN
    NEW.dropoff_location := ST_MakePoint(NEW.dropoff_lng, NEW.dropoff_lat)::geography;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_orders_geography ON public.orders;
CREATE TRIGGER trg_sync_orders_geography
  BEFORE INSERT OR UPDATE OF pickup_lat, pickup_lng, dropoff_lat, dropoff_lng
  ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.sync_orders_geography();

-- ── profiles: numeric location coordinates ────────────────────────────────────
-- `profiles.location` is geography(POINT,4326). Mirror the orders pattern.
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS location_lat double precision,
  ADD COLUMN IF NOT EXISTS location_lng double precision;

UPDATE public.profiles
  SET location_lat = ST_Y(location::geometry),
      location_lng = ST_X(location::geometry)
  WHERE location IS NOT NULL AND location_lat IS NULL;

CREATE OR REPLACE FUNCTION public.sync_profiles_geography()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.location_lat IS NOT NULL AND NEW.location_lng IS NOT NULL THEN
    NEW.location := ST_MakePoint(NEW.location_lng, NEW.location_lat)::geography;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_profiles_geography ON public.profiles;
CREATE TRIGGER trg_sync_profiles_geography
  BEFORE INSERT OR UPDATE OF location_lat, location_lng
  ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.sync_profiles_geography();
