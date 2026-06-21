-- ── Vehicle type enum ─────────────────────────────────────────────────────────
CREATE TYPE vehicle_type AS ENUM (
  'motorcycle', 'car', 'pickup', 'van', 'truck', 'heavyTruck'
);

-- ── profiles: add vehicle type + chemical permit ──────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS vehicle_type        vehicle_type,
  ADD COLUMN IF NOT EXISTS has_chemical_permit BOOLEAN NOT NULL DEFAULT false;

-- ── orders: add vehicle requirement columns ───────────────────────────────────
ALTER TABLE public.orders
  ADD COLUMN IF NOT EXISTS required_vehicle_type    vehicle_type,
  ADD COLUMN IF NOT EXISTS requires_chemical_permit BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS admin_approval_status    TEXT
    CHECK (admin_approval_status IN ('notRequired','pendingApproval','approved','rejected'));

-- ── orders: extend waste_types check to include copperAluminium ───────────────
-- Drop the old constraint and replace it with one that includes the new value.
ALTER TABLE public.orders
  DROP CONSTRAINT IF EXISTS orders_waste_types_check;

ALTER TABLE public.orders
  ADD CONSTRAINT orders_waste_types_check
    CHECK (waste_types <@ ARRAY[
      'paper','plastic','metal','glass','electronics',
      'organic','textile','wood','rubber','oil',
      'chemicals','batteries','furniture','tires','construction',
      'copperAluminium'
    ]::TEXT[]);

-- ── Index: quickly find orders a given vehicle type can take ──────────────────
CREATE INDEX IF NOT EXISTS orders_required_vehicle_type_idx
  ON public.orders (required_vehicle_type)
  WHERE status = 'pending';
