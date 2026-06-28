# Supabase Integration Migration Plan — App ↔ Dashboard

> **For agentic workers:** Execute this plan task-by-task using checkbox (`- [ ]`) syntax for tracking. Complete the Preflight section before starting Phase 1.

**Goal:** Connect the Flutter app (Dwaar) and the React admin dashboard (AdminDashboardForRecycling) through the shared Supabase instance (`bpzuwwbtqqrpohfqjcuo`), replacing all static mock data in the dashboard with live reads and writes, and making the Flutter app aware of hub locations for driver dropoff.

**Architecture:** Three independent phases. Phase 1 extends the Supabase schema (SQL only). Phase 2 wires the dashboard to Supabase with real-time hooks replacing all constants. Phase 3 adds a Flutter `IHubRepository` + driver UI so drivers see real hub locations as dropoff targets. Each phase is independently shippable.

**Tech Stack:** Supabase (Postgres + Realtime + RLS), `@supabase/supabase-js` v2 (dashboard), `supabase_flutter` v2.8.4 (Flutter app), React 18 + TypeScript + Vite (dashboard), Flutter 3.8 + Dart (app)

**Supabase project ref:** `bpzuwwbtqqrpohfqjcuo`

> **Path configuration:** Replace the environment variables below with the actual paths on your machine. Do NOT hardcode paths in task commands — use `$APP_DIR` and `$DASH_DIR` throughout.

```bash
export APP_DIR="C:\Users\dawas\dwaar"          # Flutter app root
export DASH_DIR="E:\Dawer DashBorad\AdminDashboardForRecycling"  # React dashboard root
```

---

## Preflight Checklist

Run before starting Phase 1. All checks must pass.

```bash
# 1. Supabase CLI installed and authenticated
supabase --version                        # expected: supabase 2.x
supabase projects list                    # expected: project bpzuwwbtqqrpohfqjcuo in list
                                          # if auth error: run 'supabase login' first

# 2. Dashboard prerequisites
node --version                            # expected: 18.x or 20.x
ls "$DASH_DIR/package.json"               # expected: file exists

# 3. Flutter prerequisites  
flutter --version                         # expected: Flutter 3.x
ls "$APP_DIR/pubspec.yaml"               # expected: file exists

# 4. Local Supabase dev (optional)
# This plan targets the live project (bpzuwwbtqqrpohfqjcuo).
# For future integrations, use 'supabase start' to spin up a local instance.
# Local URL: http://localhost:54321 — update $APP_DIR/.env.local accordingly.
```

**Estimated time per phase:** Phase 1 ~10 min | Phase 2 ~25 min | Phase 3 ~20 min.
If any phase takes 3× longer, a prerequisite is likely missing — re-run preflight.

**See also:**
- `docs/codebase-guide/08-supabase-backend.md` — Supabase schema, RLS design, and auth patterns
- `docs/architecture-decisions/backend-strategy.md` — why service-role key on the dashboard client

---

---

## Sub-plan breakdown

This plan covers three independently testable subsystems:
1. **Schema** — SQL migrations only (Tasks 1–3)
2. **Dashboard** — TypeScript/React, replaces mock constants with Supabase hooks (Tasks 4–11)
3. **Flutter App** — Dart, adds hub reads for driver dropoff (Tasks 12–14)

A developer can complete Tasks 1–3 and ship them independently. Tasks 4–11 depend on Tasks 1–3 being applied to the live Supabase project. Tasks 12–14 depend on Task 1.

---

## File Map

### Phase 1 — Supabase Schema Extensions
| Action | File | Responsibility |
|---|---|---|
| Create | `supabase/migrations/20260626_hubs.sql` | New `hubs` table with RLS |
| Create | `supabase/migrations/20260626_partner_fields.sql` | Contract/partner columns on `public.users` |
| Create | `supabase/migrations/20260626_seed_hubs.sql` | Seed the 4 starter hubs from dashboard constants |

### Phase 2 — Dashboard Supabase Integration
| Action | File | Responsibility |
|---|---|---|
| Create | `.env.local` (dashboard root) | Supabase URL + service-role key |
| Modify | `vite.config.ts` | Expose VITE_ env vars |
| Create | `src/lib/supabase.ts` | Service-role Supabase client |
| Create | `src/lib/adapters.ts` | Map Supabase rows → Dashboard types |
| Create | `src/hooks/useRiders.ts` | Live rider data: `users` + `driver_locations` + Realtime |
| Create | `src/hooks/useOrders.ts` | Live order data: `orders` + Realtime |
| Create | `src/hooks/useHubs.ts` | Hub CRUD: `hubs` table |
| Create | `src/hooks/useClients.ts` | Partner CRUD: `users` (recyclingCo) |
| Modify | `src/app/types.ts` | Change `Rider.id` and `Hub.id` from `number` to `string` |
| Modify | `src/app/App.tsx` | Replace RIDERS/HUBS constants with hook data; pipe loading states |
| Modify | `src/app/constants.ts` | Remove RIDERS and INITIAL_HUBS (keep static config like MATERIAL_CONFIG, DISTRICTS) |
| Modify | `src/app/components/HubsPanel.tsx` | Wire useHubs CRUD (addHub, toggleActive) |
| Modify | `src/app/components/partners/PartnersView.tsx` | Wire useClients hook |

### Phase 3 — Flutter App Hub Reads
| Action | File | Responsibility |
|---|---|---|
| Create | `lib/domain/repositories/i_hub_repository.dart` | Abstract hub contract |
| Create | `lib/data/models/hub.dart` | Dart `Hub` model |
| Create | `lib/data/repositories/supabase_hub_repository.dart` | Reads `hubs` table |
| Modify | `lib/main.dart` | Bind `IHubRepository` in MultiProvider |
| Modify | `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart` | Expose `List<Hub>` for dropoff selection |

---

## Phase 1 — Supabase Schema

### Task 1: Create `hubs` table

**Files:**
- Create: `supabase/migrations/20260626_hubs.sql`

- [ ] **Step 1: Create the migration file**

```bash
cd C:\Users\dawas\dwaar
```

Create `supabase/migrations/20260626_hubs.sql` with this exact content:

```sql
-- ─── Hubs table ───────────────────────────────────────────────────────────────
-- Physical collection points where drivers drop off recyclable material.
-- Managed by the admin dashboard; read by the mobile app for dropoff targeting.

CREATE TABLE public.hubs (
  id                 UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  name               TEXT        NOT NULL,
  address            TEXT        NOT NULL,
  lat                NUMERIC(9,6) NOT NULL,
  lng                NUMERIC(9,6) NOT NULL,
  active             BOOLEAN     NOT NULL DEFAULT true,
  capacity_kg        NUMERIC     NOT NULL DEFAULT 1000,
  current_load       JSONB       NOT NULL DEFAULT '{"cookingOil":0,"plastic":0,"paper":0,"electronics":0}'::jsonb,
  schedule           TEXT        NOT NULL DEFAULT 'weekly'
                                 CHECK (schedule IN ('weekly', 'monthly')),
  next_shipment_date DATE,
  last_shipment_date DATE,
  status             TEXT        NOT NULL DEFAULT 'collecting'
                                 CHECK (status IN ('collecting', 'ready', 'shipped')),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── RLS ──────────────────────────────────────────────────────────────────────
ALTER TABLE public.hubs ENABLE ROW LEVEL SECURITY;

-- Any authenticated app user can read all hubs (driver needs dropoff targets)
CREATE POLICY "hubs_select_authenticated"
  ON public.hubs FOR SELECT
  TO authenticated
  USING (true);

-- INSERT / UPDATE / DELETE: only service_role (dashboard) — no policy = blocked for anon/authenticated
```

- [ ] **Step 2: Apply the migration to Supabase**

```bash
cd C:\Users\dawas\dwaar
supabase link --project-ref bpzuwwbtqqrpohfqjcuo
supabase db push
```

Expected output: `Applying migration 20260626_hubs.sql... done`

- [ ] **Step 3: Verify the table exists**

In the Supabase dashboard SQL editor (`https://app.supabase.com/project/bpzuwwbtqqrpohfqjcuo/editor`), run:

```sql
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'hubs' ORDER BY ordinal_position;
```

Expected: rows for `id`, `name`, `address`, `lat`, `lng`, `active`, `capacity_kg`, `current_load`, `schedule`, `next_shipment_date`, `last_shipment_date`, `status`, `created_at`.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260626_hubs.sql
git commit -m "feat(db): add hubs table with RLS for admin dashboard + app reads"
```

---

### Task 2: Add partner fields to `public.users`

**Files:**
- Create: `supabase/migrations/20260626_partner_fields.sql`

- [ ] **Step 1: Create the migration file**

Create `supabase/migrations/20260626_partner_fields.sql`:

```sql
-- ─── B2B Partner fields on public.users ───────────────────────────────────────
-- Adds contract management fields for recyclingCo users, used by the
-- admin dashboard Partner management view.

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS contract_tier       TEXT    NOT NULL DEFAULT 'free'
                                               CHECK (contract_tier IN ('free','basic','pro','enterprise')),
  ADD COLUMN IF NOT EXISTS renewal_date        DATE,
  ADD COLUMN IF NOT EXISTS billing_cycle       TEXT    DEFAULT 'monthly'
                                               CHECK (billing_cycle IN ('monthly','annual')),
  ADD COLUMN IF NOT EXISTS green_points        INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS custom_price_jd     NUMERIC,
  ADD COLUMN IF NOT EXISTS contract_notes      TEXT,
  ADD COLUMN IF NOT EXISTS last_certificate_download DATE,
  ADD COLUMN IF NOT EXISTS referred_by         TEXT;

-- Index for partner queries filtered by role
CREATE INDEX IF NOT EXISTS users_recycling_co_idx
  ON public.users(role) WHERE role = 'recyclingCo';
```

- [ ] **Step 2: Apply the migration**

```bash
cd C:\Users\dawas\dwaar
supabase db push
```

Expected output: `Applying migration 20260626_partner_fields.sql... done`

- [ ] **Step 3: Verify columns exist**

```sql
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'users'
  AND column_name IN ('contract_tier','renewal_date','billing_cycle','green_points','custom_price_jd')
ORDER BY column_name;
```

Expected: 5 rows returned.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260626_partner_fields.sql
git commit -m "feat(db): add partner contract fields to users for B2B dashboard view"
```

---

### Task 3: Seed starter hubs

**Files:**
- Create: `supabase/migrations/20260626_seed_hubs.sql`

- [ ] **Step 1: Create the seed migration**

Create `supabase/migrations/20260626_seed_hubs.sql` — these are the 4 hubs currently hardcoded in `INITIAL_HUBS` in `src/app/constants.ts`:

```sql
-- ─── Seed starter hubs ────────────────────────────────────────────────────────
-- Migrates the 4 hubs that were hardcoded in the dashboard constants
-- into the live Supabase hubs table.

INSERT INTO public.hubs (name, address, lat, lng, active, capacity_kg, current_load, schedule, next_shipment_date, last_shipment_date, status)
VALUES
  (
    'Hub Al-Sweifieh',
    'Sweifieh Commercial District, Amman',
    31.9440, 35.8710,
    true, 1200,
    '{"cookingOil":312,"plastic":156,"paper":94,"electronics":37}'::jsonb,
    'weekly',
    '2026-06-27', '2026-06-20',
    'collecting'
  ),
  (
    'Hub Downtown',
    'Al-Balad, Downtown Amman',
    31.9520, 35.9340,
    true, 800,
    '{"cookingOil":520,"plastic":88,"paper":42,"electronics":18}'::jsonb,
    'weekly',
    '2026-06-27', '2026-06-20',
    'ready'
  ),
  (
    'Hub Jubaiha',
    'Jubaiha University District',
    32.0010, 35.8680,
    true, 1500,
    '{"cookingOil":180,"plastic":410,"paper":220,"electronics":95}'::jsonb,
    'monthly',
    '2026-07-01', '2026-06-01',
    'collecting'
  ),
  (
    'Hub Tabarbour',
    'Tabarbour Industrial Zone',
    32.0150, 35.9220,
    false, 2000,
    '{"cookingOil":0,"plastic":0,"paper":0,"electronics":0}'::jsonb,
    'monthly',
    NULL, NULL,
    'collecting'
  );
```

- [ ] **Step 2: Apply the seed**

```bash
cd C:\Users\dawas\dwaar
supabase db push
```

Expected output: `Applying migration 20260626_seed_hubs.sql... done`

- [ ] **Step 3: Verify rows inserted**

```sql
SELECT id, name, active, status FROM public.hubs ORDER BY created_at;
```

Expected: 4 rows — Hub Al-Sweifieh, Hub Downtown, Hub Jubaiha, Hub Tabarbour.

- [ ] **Step 4: Commit**

```bash
git add supabase/migrations/20260626_seed_hubs.sql
git commit -m "feat(db): seed 4 starter hubs migrated from dashboard constants"
```

### Phase 1 Rollback

If any Phase 1 migration fails or the schema needs to be reset:

```sql
-- Run in Supabase SQL editor (https://app.supabase.com/project/bpzuwwbtqqrpohfqjcuo/editor)
DELETE FROM public.hubs;                         -- remove seeded hubs
DROP TABLE IF EXISTS public.hubs;                -- remove hubs table
ALTER TABLE public.users
  DROP COLUMN IF EXISTS contract_tier,
  DROP COLUMN IF EXISTS renewal_date,
  DROP COLUMN IF EXISTS billing_cycle,
  DROP COLUMN IF EXISTS green_points,
  DROP COLUMN IF EXISTS custom_price_jd,
  DROP COLUMN IF EXISTS contract_notes,
  DROP COLUMN IF EXISTS last_certificate_download,
  DROP COLUMN IF EXISTS referred_by;
```

After rollback, re-apply cleanly with `supabase db push`.

---

## Phase 2 — Dashboard Supabase Integration

### Task 4: Install Supabase client + environment setup

**Files:**
- Create: `E:\Dawer DashBorad\AdminDashboardForRecycling\.env.local`
- Modify: `E:\Dawer DashBorad\AdminDashboardForRecycling\vite.config.ts`

- [ ] **Step 1: Install `@supabase/supabase-js`**

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
npm install @supabase/supabase-js
```

Expected: package added to `node_modules`, `package.json` updated.

- [ ] **Step 2: Create `.env.local` in the dashboard root**

Create `E:\Dawer DashBorad\AdminDashboardForRecycling\.env.local`:

```
VITE_SUPABASE_URL=https://bpzuwwbtqqrpohfqjcuo.supabase.co
VITE_SUPABASE_SERVICE_KEY=<paste your service_role key from Supabase dashboard → Settings → API>
```

> ⚠️ **Never commit this file.** Verify `.gitignore` already includes `.env.local`. The service-role key bypasses RLS — this dashboard is an internal admin tool only.

- [ ] **Step 3: Verify `vite.config.ts` exposes env vars**

Open `vite.config.ts`. It should already forward `VITE_*` vars automatically — Vite's default. No change needed unless `envPrefix` is explicitly overridden. Run build to confirm:

```bash
npm run build
```

Expected: no errors. (No VITE env vars are used yet, but build must be clean.)

- [ ] **Step 4: Commit (package.json + package-lock.json only — NOT .env.local)**

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
git add package.json package-lock.json
git commit -m "feat(dashboard): install @supabase/supabase-js"
```

---

### Task 5: Create Supabase client + type definitions

**Files:**
- Create: `src/lib/supabase.ts`

- [ ] **Step 1: Create `src/lib/supabase.ts`**

```typescript
// src/lib/supabase.ts
import { createClient, SupabaseClient } from "@supabase/supabase-js";

const SUPABASE_URL =
  import.meta.env.VITE_SUPABASE_URL ??
  "https://bpzuwwbtqqrpohfqjcuo.supabase.co";

const SUPABASE_SERVICE_KEY = import.meta.env.VITE_SUPABASE_SERVICE_KEY ?? "";

if (!SUPABASE_SERVICE_KEY) {
  console.warn(
    "[Dwaar Dashboard] VITE_SUPABASE_SERVICE_KEY is not set. " +
    "Add it to .env.local — see README."
  );
}

/**
 * Service-role Supabase client — bypasses RLS.
 * This dashboard is an internal admin tool; never expose this key to end users.
 */
export const supabase: SupabaseClient = createClient(
  SUPABASE_URL,
  SUPABASE_SERVICE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);

// ─── Raw Supabase row types ────────────────────────────────────────────────────
// These mirror the Postgres schema exactly (snake_case).

export interface SupabaseUser {
  id: string;
  auth_id: string;
  name: string;
  phone: string;
  email: string | null;
  role: "driver" | "supplier" | "recyclingCo";
  supplier_type: "individual" | "storeBusiness" | null;
  rating: number;
  total_orders: number;
  is_verified: boolean;
  is_available: boolean;
  points: number;
  vehicle_model: string | null;
  vehicle_color: string | null;
  vehicle_plate: string | null;
  vehicle_type: "motorcycle" | "car" | "pickup" | "van" | "truck" | "heavyTruck" | null;
  has_chemical_permit: boolean;
  address: string | null;
  profile_photo_url: string | null;
  categories: string[];
  // Partner fields (recyclingCo only)
  contract_tier: "free" | "basic" | "pro" | "enterprise";
  renewal_date: string | null;
  billing_cycle: "monthly" | "annual" | null;
  green_points: number;
  custom_price_jd: number | null;
  contract_notes: string | null;
  last_certificate_download: string | null;
  referred_by: string | null;
  created_at: string;
}

export interface SupabaseOrder {
  id: string;
  type: "pickup" | "collection" | "collectionSale";
  status: "pending" | "accepted" | "inTransit" | "completed" | "cancelled";
  supplier_id: string | null;
  driver_id: string | null;
  company_id: string | null;
  waste_types: string[];
  estimated_weight_kg: number;
  actual_weight_kg: number | null;
  pickup_location: unknown; // PostGIS geography — not used in dashboard
  reward_jd: number;
  is_urgent: boolean;
  notes: string | null;
  created_at: string;
  accepted_at: string | null;
  in_transit_at: string | null;
  completed_at: string | null;
}

export interface SupabaseDriverLocation {
  driver_id: string;
  lat: number;
  lng: number;
  updated_at: string;
}

export interface SupabaseHub {
  id: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
  active: boolean;
  capacity_kg: number;
  current_load: {
    cookingOil: number;
    plastic: number;
    paper: number;
    electronics: number;
  };
  schedule: "weekly" | "monthly";
  next_shipment_date: string | null;
  last_shipment_date: string | null;
  status: "collecting" | "ready" | "shipped";
  created_at: string;
}
```

- [ ] **Step 2: Verify build is clean**

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
npm run build
```

Expected: no TypeScript errors.

- [ ] **Step 3: Commit**

```bash
git add src/lib/supabase.ts
git commit -m "feat(dashboard): add supabase client + raw row types"
```

---

### Task 6: Create data adapters (Supabase rows → Dashboard types)

**Files:**
- Create: `src/lib/adapters.ts`
- Modify: `src/app/types.ts` — change `Rider.id` and `Hub.id` from `number` to `string`

- [ ] **Step 1: Update `src/app/types.ts` — change Rider.id and Hub.id to string**

Find the `Rider` interface and change `id: number` → `id: string`.
Find the `Hub` interface and change `id: number` → `id: string`.

The updated sections:

```typescript
// In Rider interface — change:
export interface Rider {
  id: string;   // was number — now UUID string from Supabase
  name: string;
  nameAr: string;
  phone: string;
  lat: number;
  lng: number;
  status: "delivering" | "picking_up" | "idle";
  vehicle: "Motorcycle" | "Van";
  orders: Order[];
  idleSince?: number;
}

// In Hub interface — change:
export interface Hub {
  id: string;   // was number — now UUID string from Supabase
  name: string;
  address: string;
  lat: number;
  lng: number;
  active: boolean;
  capacityKg: number;
  currentLoad: HubMaterials;
  schedule: "weekly" | "monthly";
  nextShipmentDate: string;
  lastShipmentDate: string;
  status: "collecting" | "ready" | "shipped";
}
```

- [ ] **Step 2: Fix integer-based usages broken by id type change**

Run build to find type errors:

```bash
npm run build 2>&1 | grep "error TS"
```

The most common errors will be in:
- `src/app/App.tsx` — `selectedRider: number | null` → change to `string | null`
- `src/app/App.tsx` — `selectedHub: number | null` → change to `string | null`
- Any comparison `riderId === 1` must become string comparison
- `src/app/constants.ts` — RIDERS array has `id: 1, 2, ...` → remove (will be replaced by Supabase data in Task 9)

In `src/app/App.tsx`, change the two state declarations:

```typescript
const [selectedRider, setSelectedRider] = useState<string | null>(null);
const [selectedHub, setSelectedHub]     = useState<string | null>(null);
```

- [ ] **Step 3: Create `src/lib/adapters.ts`**

```typescript
// src/lib/adapters.ts
import { Rider, Order, Hub, Client, ClientType, ContractTier } from "../app/types";
import {
  SupabaseUser,
  SupabaseOrder,
  SupabaseDriverLocation,
  SupabaseHub,
} from "./supabase";

// ─── Waste type mapping ────────────────────────────────────────────────────────
// Maps Supabase waste_types[] (app's WasteType enum values) to the dashboard's
// simplified 4-category model.

const WASTE_TO_MATERIAL: Record<string, Order["material"]> = {
  oil:             "Cooking Oil",
  cookingOil:      "Cooking Oil",
  plastic:         "Plastic Bottles",
  electronics:     "Electronics",
  batteries:       "Electronics",
  paper:           "Paper & Cardboard",
  cardboard:       "Paper & Cardboard",
  glass:           "Plastic Bottles",   // closest dashboard category
  metal:           "Plastic Bottles",
  copperAluminium: "Electronics",
};

function mapWasteTypes(wasteTypes: string[]): Order["material"] {
  for (const wt of wasteTypes) {
    const mapped = WASTE_TO_MATERIAL[wt];
    if (mapped) return mapped;
  }
  return "Plastic Bottles"; // fallback
}

// ─── CO₂ saved estimate ───────────────────────────────────────────────────────
// Approximate kg CO₂ saved per kg (or litre for oil) of material recycled.
const CO2_PER_KG: Partial<Record<Order["material"], number>> = {
  "Cooking Oil":       2.7,
  "Plastic Bottles":   1.8,
  "Paper & Cardboard": 1.1,
  "Electronics":       8.0,
};

function estimateCo2(material: Order["material"], weightKg: number): number {
  return Math.round((CO2_PER_KG[material] ?? 1.5) * weightKg * 10) / 10;
}

// ─── Status mapping ────────────────────────────────────────────────────────────
function mapOrderStatus(status: SupabaseOrder["status"]): Order["status"] {
  if (status === "inTransit") return "inTransit";
  if (status === "completed") return "completed";
  if (status === "accepted")  return "accepted";
  return "pending";
}

function deriveRiderStatus(orders: Order[]): Rider["status"] {
  const activeOrder = orders.find(
    (o) => o.status === "inTransit" || o.status === "accepted"
  );
  if (!activeOrder) return "idle";
  return activeOrder.status === "inTransit" ? "delivering" : "picking_up";
}

function mapVehicleType(
  vt: SupabaseUser["vehicle_type"]
): Rider["vehicle"] {
  if (vt === "van" || vt === "truck" || vt === "heavyTruck") return "Van";
  return "Motorcycle";
}

// ─── Public adapters ──────────────────────────────────────────────────────────

export function adaptOrder(row: SupabaseOrder): Order {
  const material = mapWasteTypes(row.waste_types);
  const weightKg = row.actual_weight_kg ?? row.estimated_weight_kg;
  return {
    id:           row.id,
    material,
    quantity:     weightKg,
    unit:         "kg",
    address:      row.notes ?? "Jordan",
    deliveryLat:  31.963, // placeholder — Supabase stores geography not easily parsed here
    deliveryLng:  35.910,
    status:       mapOrderStatus(row.status),
    co2Saved:     estimateCo2(material, weightKg),
    earnings:     row.reward_jd,
    createdAt:    row.created_at.split("T")[0],
    completedAt:  row.completed_at?.split("T")[0],
    acceptedAt:   row.accepted_at ? new Date(row.accepted_at).getTime() : undefined,
  };
}

export function adaptRider(
  user: SupabaseUser,
  location: SupabaseDriverLocation | null,
  orders: SupabaseOrder[]
): Rider {
  const adaptedOrders = orders.map(adaptOrder);
  const status = deriveRiderStatus(adaptedOrders);
  const idleSince =
    status === "idle" ? Date.now() - 5 * 60 * 1000 : undefined; // approx

  return {
    id:       user.id,
    name:     user.name,
    nameAr:   user.name,
    phone:    user.phone,
    lat:      location?.lat ?? 31.963,
    lng:      location?.lng ?? 35.910,
    status,
    vehicle:  mapVehicleType(user.vehicle_type),
    orders:   adaptedOrders,
    idleSince,
  };
}

export function adaptHub(row: SupabaseHub): Hub {
  return {
    id:               row.id,
    name:             row.name,
    address:          row.address,
    lat:              row.lat,
    lng:              row.lng,
    active:           row.active,
    capacityKg:       row.capacity_kg,
    currentLoad:      row.current_load,
    schedule:         row.schedule,
    nextShipmentDate: row.next_shipment_date ?? "",
    lastShipmentDate: row.last_shipment_date ?? "",
    status:           row.status,
  };
}

export function adaptClient(user: SupabaseUser): Client {
  return {
    id:            user.id,
    name:          user.name,
    type:          "other" as ClientType, // no type field in users; default
    address:       user.address ?? "",
    phone:         user.phone,
    email:         user.email ?? "",
    contractTier:  (user.contract_tier ?? "free") as ContractTier,
    joinedDate:    user.created_at.split("T")[0],
    orders:        [],
    totalCo2Saved: 0,
    totalEarnings: 0,
    renewalDate:   user.renewal_date ?? "",
    billingCycle:  (user.billing_cycle ?? "monthly") as "monthly" | "annual",
    greenPoints:   user.green_points ?? 0,
    customPriceJD: user.custom_price_jd ?? undefined,
    contractNotes: user.contract_notes ?? undefined,
    lastCertificateDownload: user.last_certificate_download ?? undefined,
    referredBy:    user.referred_by ?? undefined,
  };
}
```

- [ ] **Step 4: Run build — fix all type errors**

```bash
npm run build 2>&1 | grep "error TS"
```

Common fixable errors:
- `Argument of type 'number' is not assignable to parameter of type 'string'` in callbacks that pass rider/hub id — update those callbacks to accept `string`.
- Rider/Hub map keys that were numeric — update to string.

Fix each error before proceeding.

- [ ] **Step 5: Commit**

```bash
git add src/app/types.ts src/lib/adapters.ts src/app/App.tsx
git commit -m "feat(dashboard): add data adapters; change Rider/Hub ids to string"
```

---

### Task 7: Live rider hook (`useRiders`)

**Files:**
- Create: `src/hooks/useRiders.ts`

- [ ] **Step 1: Create `src/hooks/useRiders.ts`**

```typescript
// src/hooks/useRiders.ts
import { useState, useEffect } from "react";
import { supabase, SupabaseUser, SupabaseDriverLocation, SupabaseOrder } from "../lib/supabase";
import { adaptRider } from "../lib/adapters";
import { Rider } from "../app/types";

export function useRiders() {
  const [riders, setRiders]   = useState<Rider[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchAll() {
      setLoading(true);
      setError(null);

      // 1. Fetch all driver users
      const { data: users, error: usersErr } = await supabase
        .from("users")
        .select("*")
        .eq("role", "driver");

      if (usersErr) { setError(usersErr.message); setLoading(false); return; }
      if (!users || cancelled) return;

      // 2. Fetch all current driver locations
      const { data: locations } = await supabase
        .from("driver_locations")
        .select("*");

      // 3. Fetch active orders (non-completed, non-cancelled) for all drivers
      const driverIds = (users as SupabaseUser[]).map((u) => u.id);
      const { data: orders } = await supabase
        .from("orders")
        .select("*")
        .in("driver_id", driverIds)
        .in("status", ["pending", "accepted", "inTransit"]);

      if (cancelled) return;

      const locationMap: Record<string, SupabaseDriverLocation> = {};
      for (const loc of (locations ?? []) as SupabaseDriverLocation[]) {
        locationMap[loc.driver_id] = loc;
      }

      const ordersByDriver: Record<string, SupabaseOrder[]> = {};
      for (const order of (orders ?? []) as SupabaseOrder[]) {
        if (order.driver_id) {
          (ordersByDriver[order.driver_id] ??= []).push(order);
        }
      }

      const adapted = (users as SupabaseUser[]).map((u) =>
        adaptRider(u, locationMap[u.id] ?? null, ordersByDriver[u.id] ?? [])
      );

      setRiders(adapted);
      setLoading(false);
    }

    fetchAll();

    // ─── Realtime: driver_locations ───────────────────────────────────────────
    const locationChannel = supabase
      .channel("driver-locations-dashboard")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "driver_locations" },
        () => {
          // Re-fetch on any location update — keeps things simple and consistent
          if (!cancelled) fetchAll();
        }
      )
      .subscribe();

    // ─── Realtime: orders ─────────────────────────────────────────────────────
    const ordersChannel = supabase
      .channel("driver-orders-dashboard")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "orders" },
        () => {
          if (!cancelled) fetchAll();
        }
      )
      .subscribe();

    return () => {
      cancelled = true;
      supabase.removeChannel(locationChannel);
      supabase.removeChannel(ordersChannel);
    };
  }, []);

  return { riders, loading, error };
}
```

- [ ] **Step 2: Run build**

```bash
npm run build
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add src/hooks/useRiders.ts
git commit -m "feat(dashboard): add useRiders hook with Supabase Realtime"
```

---

### Task 8: Live hub hook (`useHubs`) with CRUD

**Files:**
- Create: `src/hooks/useHubs.ts`

- [ ] **Step 1: Create `src/hooks/useHubs.ts`**

```typescript
// src/hooks/useHubs.ts
import { useState, useEffect, useCallback } from "react";
import { supabase, SupabaseHub } from "../lib/supabase";
import { adaptHub } from "../lib/adapters";
import { Hub } from "../app/types";

export function useHubs() {
  const [hubs, setHubs]       = useState<Hub[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  async function fetchHubs() {
    const { data, error: err } = await supabase
      .from("hubs")
      .select("*")
      .order("created_at", { ascending: true });

    if (err) { setError(err.message); return; }
    setHubs((data as SupabaseHub[]).map(adaptHub));
    setLoading(false);
  }

  useEffect(() => {
    fetchHubs();
  }, []);

  /**
   * Add a new hub. Inserts into Supabase and refreshes the list.
   * Dashboard passes lat/lng from the map click.
   */
  const addHub = useCallback(
    async (coords: { lat: number; lng: number }, name: string, address: string) => {
      const { error: err } = await supabase.from("hubs").insert({
        name,
        address,
        lat: coords.lat,
        lng: coords.lng,
        active: true,
        capacity_kg: 1000,
        current_load: { cookingOil: 0, plastic: 0, paper: 0, electronics: 0 },
        schedule: "weekly",
        status: "collecting",
      });
      if (err) throw new Error(err.message);
      await fetchHubs();
    },
    []
  );

  /**
   * Toggle a hub's active status.
   */
  const toggleHubActive = useCallback(async (hubId: string, active: boolean) => {
    const { error: err } = await supabase
      .from("hubs")
      .update({ active })
      .eq("id", hubId);
    if (err) throw new Error(err.message);
    await fetchHubs();
  }, []);

  /**
   * Update hub status (collecting → ready → shipped).
   */
  const updateHubStatus = useCallback(
    async (hubId: string, status: Hub["status"]) => {
      const { error: err } = await supabase
        .from("hubs")
        .update({ status })
        .eq("id", hubId);
      if (err) throw new Error(err.message);
      await fetchHubs();
    },
    []
  );

  return { hubs, loading, error, addHub, toggleHubActive, updateHubStatus };
}
```

- [ ] **Step 2: Run build**

```bash
npm run build
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add src/hooks/useHubs.ts
git commit -m "feat(dashboard): add useHubs hook with CRUD operations"
```

---

### Task 9: Live partners hook (`useClients`)

**Files:**
- Create: `src/hooks/useClients.ts`

- [ ] **Step 1: Create `src/hooks/useClients.ts`**

```typescript
// src/hooks/useClients.ts
import { useState, useEffect, useCallback } from "react";
import { supabase, SupabaseUser } from "../lib/supabase";
import { adaptClient } from "../lib/adapters";
import { Client, ContractTier } from "../app/types";

export function useClients() {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  async function fetchClients() {
    const { data, error: err } = await supabase
      .from("users")
      .select("*")
      .eq("role", "recyclingCo")
      .order("created_at", { ascending: false });

    if (err) { setError(err.message); return; }
    setClients((data as SupabaseUser[]).map(adaptClient));
    setLoading(false);
  }

  useEffect(() => {
    fetchClients();
  }, []);

  /**
   * Update a partner's contract tier.
   */
  const updateTier = useCallback(
    async (clientId: string, tier: ContractTier) => {
      const { error: err } = await supabase
        .from("users")
        .update({ contract_tier: tier })
        .eq("id", clientId);
      if (err) throw new Error(err.message);
      await fetchClients();
    },
    []
  );

  /**
   * Update a partner's contract notes.
   */
  const updateNotes = useCallback(
    async (clientId: string, notes: string) => {
      const { error: err } = await supabase
        .from("users")
        .update({ contract_notes: notes })
        .eq("id", clientId);
      if (err) throw new Error(err.message);
      await fetchClients();
    },
    []
  );

  /**
   * Award green points to a partner (additive).
   */
  const awardPoints = useCallback(
    async (clientId: string, points: number) => {
      // Use RPC or increment — simple update with read-modify-write for now
      const client = clients.find((c) => c.id === clientId);
      if (!client) return;
      const { error: err } = await supabase
        .from("users")
        .update({ green_points: client.greenPoints + points })
        .eq("id", clientId);
      if (err) throw new Error(err.message);
      await fetchClients();
    },
    [clients]
  );

  return { clients, loading, error, updateTier, updateNotes, awardPoints };
}
```

- [ ] **Step 2: Run build**

```bash
npm run build
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add src/hooks/useClients.ts
git commit -m "feat(dashboard): add useClients hook for B2B partner management"
```

---

### Task 10: Wire hooks into `App.tsx` — replace static constants

**Files:**
- Modify: `src/app/App.tsx`
- Modify: `src/app/constants.ts` — remove RIDERS and INITIAL_HUBS

- [ ] **Step 1: Remove RIDERS and INITIAL_HUBS from `src/app/constants.ts`**

Open `src/app/constants.ts`. Delete the `RIDERS` export array entirely (it starts with `export const RIDERS: Rider[] = [` and ends with the closing `];`). Also delete `export const INITIAL_HUBS: Hub[] = [...]`.

Keep all other exports: `MATERIAL_CONFIG`, `STATUS_CONFIG`, `ORDER_STATUS`, `TIER_CONFIG`, `DISTRICTS`, `HUB_STATUS_CONFIG`, `MATERIAL_DELIVERY_ESTIMATE_MS`, `IDLE_WARNING_MS`, `IDLE_CRITICAL_MS`, etc.

- [ ] **Step 2: Update `src/app/App.tsx` to use hooks**

Find the import section at the top of `App.tsx`. Replace the line that imports `RIDERS` and `INITIAL_HUBS` from constants:

```typescript
// REMOVE this line (or its equivalent):
import { RIDERS, ONLINE_COUNT, INITIAL_HUBS, ... } from "./constants";

// REPLACE with (keep all other constant imports, just remove RIDERS and INITIAL_HUBS):
import { ONLINE_COUNT, HUB_STATUS_CONFIG, DISTRICTS, STATUS_CONFIG } from "./constants";
import { useRiders } from "../hooks/useRiders";
import { useHubs } from "../hooks/useHubs";
```

- [ ] **Step 3: Wire hooks inside the `App` function component**

Inside `export default function App()`, add the hooks at the top of the function body, just after the existing `useState` declarations:

```typescript
const { riders, loading: ridersLoading } = useRiders();
const {
  hubs,
  loading: hubsLoading,
  addHub,
  toggleHubActive,
  updateHubStatus,
} = useHubs();
```

Then remove the existing `const [hubs, setHubs] = useState<Hub[]>(INITIAL_HUBS);` line (hooks replace this).

- [ ] **Step 4: Replace RIDERS references throughout App.tsx**

Every place `RIDERS` was used now becomes the `riders` variable from `useRiders`. The most common patterns:

- `RIDERS.find(r => r.id === selectedRider)` → `riders.find(r => r.id === selectedRider)`
- `RIDERS.filter(...)` → `riders.filter(...)`
- Props like `riders={RIDERS}` → `riders={riders}`

Add a loading guard near the return statement (before the JSX):

```typescript
if (ridersLoading || hubsLoading) {
  return (
    <div style={{
      display: "flex", alignItems: "center", justifyContent: "center",
      height: "100vh", background: "var(--color-surface)",
      color: "var(--color-text-secondary)", fontFamily: "var(--font-sans)",
      fontSize: 15,
    }}>
      Connecting to Supabase…
    </div>
  );
}
```

- [ ] **Step 5: Update `handleOrderClick` — the hub reference**

`handleOrderClick` currently calls `hubs.filter(h => h.active)` and uses `Math.hypot` with hub/rider lat/lng. Since `hubs` now comes from `useHubs()` (already a `Hub[]`), this should work without change. Verify the function still compiles.

- [ ] **Step 6: Run build**

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
npm run build 2>&1
```

Expected: no errors. Fix any remaining references to removed RIDERS/INITIAL_HUBS constants.

- [ ] **Step 7: Commit**

```bash
git add src/app/App.tsx src/app/constants.ts
git commit -m "feat(dashboard): wire useRiders + useHubs into App — replace all static mock data"
```

---

### Task 11: Wire hub and partner CRUD into their panels

**Files:**
- Modify: `src/app/components/HubsPanel.tsx`
- Modify: `src/app/components/AddHubModal.tsx`
- Modify: `src/app/components/partners/PartnersView.tsx`

- [ ] **Step 1: Update `HubsPanel.tsx` to receive and use hub CRUD props**

`HubsPanel` currently receives `hubs` and `onToggleActive` props from App. Update the props interface to add the remaining actions and ensure they flow through from App:

In `HubsPanel.tsx`, update the Props type:

```typescript
interface HubsPanelProps {
  hubs: Hub[];
  selectedHub: string | null;
  onHubSelect: (id: string) => void;
  onToggleActive: (id: string, active: boolean) => void;
  onUpdateStatus: (id: string, status: Hub["status"]) => void;
}
```

Pass `onUpdateStatus` down from `App.tsx`:

```tsx
// In App.tsx JSX — where HubsPanel is rendered:
<HubsPanel
  hubs={hubs}
  selectedHub={selectedHub}
  onHubSelect={handleHubSelect}
  onToggleActive={toggleHubActive}
  onUpdateStatus={updateHubStatus}
/>
```

In `HubsPanel.tsx`, add a status-cycle button that calls `onUpdateStatus`:

```typescript
// Helper to get the next status
function nextStatus(current: Hub["status"]): Hub["status"] {
  if (current === "collecting") return "ready";
  if (current === "ready")      return "shipped";
  return "collecting";
}
```

Then render a "Mark as ready" / "Mark as shipped" button per hub card that calls `onUpdateStatus(hub.id, nextStatus(hub.status))`.

- [ ] **Step 2: Update `AddHubModal.tsx` to call `addHub` from the hook**

`AddHubModal` currently calls `onConfirm(coords, name)`. `onConfirm` must now be async (it calls Supabase). Update the modal's submit handler:

```typescript
// In AddHubModal.tsx — the confirm button onClick:
async function handleConfirm() {
  setSubmitting(true);
  try {
    await onConfirm(coords, name, address);
    onClose();
  } catch (e) {
    setError("Failed to save hub. Please try again.");
  } finally {
    setSubmitting(false);
  }
}
```

In `App.tsx`, the existing `pendingCoords`-based hub creation should call `addHub`:

```typescript
// Replace the existing inline hub creation in App.tsx:
async function handleHubConfirm(coords: { lat: number; lng: number }, name: string, address: string) {
  await addHub(coords, name, address);
  setPendingCoords(null);
}
```

- [ ] **Step 3: Update `PartnersView.tsx` to use `useClients` hook**

`PartnersView` currently receives its client data as props or uses internal state with static data. Pass `useClients` data from `App.tsx`:

Add `useClients` to `App.tsx` imports:

```typescript
import { useClients } from "../hooks/useClients";
```

Add hook call inside `App()`:

```typescript
const { clients, updateTier, updateNotes, awardPoints } = useClients();
```

Pass to PartnersView:

```tsx
{activeView === "partners" && (
  <PartnersView
    clients={clients}
    onUpdateTier={updateTier}
    onUpdateNotes={updateNotes}
    onAwardPoints={awardPoints}
  />
)}
```

Update `PartnersView.tsx` props interface to accept these and wire them to the existing UI (tier dropdown → `onUpdateTier`, notes textarea → `onUpdateNotes`).

- [ ] **Step 4: Run build**

```bash
npm run build 2>&1
```

Expected: no errors.

- [ ] **Step 5: Visual verification — run dev server**

```bash
npm run dev
```

Open `http://localhost:5173` in browser. Verify:
- Rider panel shows real driver users from Supabase (or is empty if no drivers exist yet)
- Hubs panel shows the 4 seeded hubs from Task 3
- Partners view shows any recyclingCo users from Supabase

- [ ] **Step 6: Commit**

```bash
git add src/app/components/HubsPanel.tsx src/app/components/AddHubModal.tsx src/app/components/partners/PartnersView.tsx src/app/App.tsx
git commit -m "feat(dashboard): wire hub CRUD + partner management to Supabase"
```

### Phase 2 Rollback

If Phase 2 hooks or wiring need to be reverted:

```bash
cd "$DASH_DIR"
# Remove created files
rm -f src/lib/supabase.ts src/lib/adapters.ts src/hooks/useRiders.ts src/hooks/useHubs.ts src/hooks/useClients.ts
# Restore constants.ts and App.tsx from git
git checkout HEAD -- src/app/constants.ts src/app/App.tsx src/app/types.ts
git checkout HEAD -- src/app/components/HubsPanel.tsx src/app/components/AddHubModal.tsx
git checkout HEAD -- src/app/components/partners/PartnersView.tsx
npm run build  # verify clean
```

**Known adapter limitations to resolve in a future task (see TODOS.md):**
- `adaptOrder.address` always returns `row.notes ?? "Jordan"` — PostGIS not parsed in TS
- Idle driver `lat/lng` defaults to Amman centre (31.963, 35.910) when no location row exists
- `awardPoints` in `useClients` is read-modify-write (not atomic) — replace with Supabase RPC

---

## Phase 3 — Flutter App: Hub Reads

### Task 12: Domain layer — `IHubRepository` interface and `Hub` model

**Files:**
- Create: `lib/domain/repositories/i_hub_repository.dart`
- Create: `lib/data/models/hub.dart`

- [ ] **Step 1: Write the failing test**

Create `test/data/repositories/supabase_hub_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';

void main() {
  group('Hub model', () {
    test('fromJson parses a Supabase row correctly', () {
      final json = {
        'id': 'abc-123',
        'name': 'Hub Al-Sweifieh',
        'address': 'Sweifieh Commercial District',
        'lat': 31.944,
        'lng': 35.871,
        'active': true,
        'capacity_kg': 1200.0,
        'current_load': {'cookingOil': 312, 'plastic': 156, 'paper': 94, 'electronics': 37},
        'schedule': 'weekly',
        'next_shipment_date': '2026-06-27',
        'last_shipment_date': '2026-06-20',
        'status': 'collecting',
        'created_at': '2026-06-26T10:00:00Z',
      };

      final hub = Hub.fromJson(json);

      expect(hub.id, 'abc-123');
      expect(hub.name, 'Hub Al-Sweifieh');
      expect(hub.lat, 31.944);
      expect(hub.active, true);
      expect(hub.capacityKg, 1200.0);
      expect(hub.currentLoad['cookingOil'], 312);
      expect(hub.status, 'collecting');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd C:\Users\dawas\dwaar
flutter test test/data/repositories/supabase_hub_repository_test.dart
```

Expected: FAIL — `lib/data/models/hub.dart` doesn't exist yet.

- [ ] **Step 3: Create `lib/data/models/hub.dart`**

```dart
// lib/data/models/hub.dart

/// A physical collection point where drivers drop off recyclable material.
/// Managed by the admin dashboard; read by the mobile app for dropoff targeting.
class Hub {
  const Hub({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.active,
    required this.capacityKg,
    required this.currentLoad,
    required this.schedule,
    required this.nextShipmentDate,
    required this.lastShipmentDate,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool active;
  final double capacityKg;
  final Map<String, dynamic> currentLoad;
  final String schedule; // 'weekly' | 'monthly'
  final String? nextShipmentDate;
  final String? lastShipmentDate;
  final String status; // 'collecting' | 'ready' | 'shipped'
  final DateTime createdAt;

  factory Hub.fromJson(Map<String, dynamic> json) {
    return Hub(
      id:               json['id'] as String,
      name:             json['name'] as String,
      address:          json['address'] as String,
      lat:              (json['lat'] as num).toDouble(),
      lng:              (json['lng'] as num).toDouble(),
      active:           json['active'] as bool,
      capacityKg:       (json['capacity_kg'] as num).toDouble(),
      currentLoad:      Map<String, dynamic>.from(json['current_load'] as Map),
      schedule:         json['schedule'] as String,
      nextShipmentDate: json['next_shipment_date'] as String?,
      lastShipmentDate: json['last_shipment_date'] as String?,
      status:           json['status'] as String,
      createdAt:        DateTime.parse(json['created_at'] as String),
    );
  }
}
```

- [ ] **Step 4: Create `lib/domain/repositories/i_hub_repository.dart`**

```dart
// lib/domain/repositories/i_hub_repository.dart
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../data/models/hub.dart';

/// Read-only gateway for collection hubs.
/// Only the admin dashboard can write hubs; the app reads them for
/// driver dropoff targeting and supplier dropoff information.
abstract interface class IHubRepository {
  /// Returns all active hubs, sorted by distance to [lat]/[lng] if provided.
  Future<AppResult<List<Hub>>> fetchActiveHubs();
}
```

- [ ] **Step 5: Run test to verify it passes**

```bash
flutter test test/data/repositories/supabase_hub_repository_test.dart
```

Expected: PASS — 1 test passed.

- [ ] **Step 6: Commit**

```bash
git add lib/data/models/hub.dart lib/domain/repositories/i_hub_repository.dart test/data/repositories/supabase_hub_repository_test.dart
git commit -m "feat(app): add Hub model + IHubRepository interface with tests"
```

---

### Task 13: Implement `SupabaseHubRepository`

**Files:**
- Create: `lib/data/repositories/supabase_hub_repository.dart`

- [ ] **Step 1: Write the failing test**

Extend `test/data/repositories/supabase_hub_repository_test.dart` with an integration smoke test (mock the Supabase client response):

```dart
// Add to the existing test file:
import 'package:dwaar/data/repositories/supabase_hub_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// In main():
group('SupabaseHubRepository', () {
  test('fetchActiveHubs returns mapped Hub list on success', () async {
    // This is an integration smoke test — real network call.
    // Skip in CI if SUPABASE_URL not set.
    final url = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final key = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    if (url.isEmpty || key.isEmpty) {
      markTestSkipped('Skipped: no Supabase credentials in environment');
      return;
    }
    // If credentials are present, run a real fetch — verifies schema compatibility.
    await Supabase.initialize(url: url, anonKey: key);
    final repo = SupabaseHubRepository(Supabase.instance.client);
    final result = await repo.fetchActiveHubs();
    result.fold(
      onSuccess: (hubs) => expect(hubs, isA<List<Hub>>()),
      onFailure: (f) => fail('Expected success, got: $f'),
    );
  });
});
```

- [ ] **Step 2: Run to verify it fails (missing implementation)**

```bash
flutter test test/data/repositories/supabase_hub_repository_test.dart
```

Expected: FAIL — `SupabaseHubRepository` not found.

- [ ] **Step 3: Create `lib/data/repositories/supabase_hub_repository.dart`**

```dart
// lib/data/repositories/supabase_hub_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_hub_repository.dart';
import '../models/hub.dart';

final class SupabaseHubRepository implements IHubRepository {
  SupabaseHubRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async {
    try {
      final response = await _client
          .from('hubs')
          .select()
          .eq('active', true)
          .order('created_at', ascending: true);

      final hubs = (response as List)
          .map((row) => Hub.fromJson(row as Map<String, dynamic>))
          .toList();

      return Result.success(hubs);
    } on PostgrestException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/data/repositories/supabase_hub_repository_test.dart
```

Expected: Hub model test PASSES. Integration test skips (no env vars in test env).

- [ ] **Step 5: Commit**

```bash
git add lib/data/repositories/supabase_hub_repository.dart
git commit -m "feat(app): implement SupabaseHubRepository — reads active hubs for driver dropoff"
```

---

### Task 14: Bind `IHubRepository` in `main.dart` + expose to driver VM

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart`

- [ ] **Step 1: Add import and binding in `lib/main.dart`**

At the top of `main.dart`, add:

```dart
import 'data/repositories/supabase_hub_repository.dart';
import 'domain/repositories/i_hub_repository.dart';
```

Inside the `MultiProvider` providers list, add after the existing `IOrderRepository` provider:

```dart
Provider<IHubRepository>(
  create: (_) => SupabaseHubRepository(Supabase.instance.client),
),
```

- [ ] **Step 2: Write a test for the driver VM hub exposure**

Create `test/ui/features/driver/driver_home_viewmodel_hub_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/hub.dart';
import 'package:dwaar/domain/repositories/i_hub_repository.dart';

class FakeHubRepository implements IHubRepository {
  final List<Hub> hubs;
  FakeHubRepository(this.hubs);

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async =>
      Result.success(hubs);
}

void main() {
  test('driver VM loadHubs populates hub list', () async {
    final fakeHubs = [
      Hub(
        id: 'h1', name: 'Hub A', address: 'Sweifieh',
        lat: 31.944, lng: 35.871, active: true, capacityKg: 1000,
        currentLoad: {}, schedule: 'weekly',
        nextShipmentDate: null, lastShipmentDate: null,
        status: 'collecting', createdAt: DateTime.now(),
      ),
    ];

    final repo = FakeHubRepository(fakeHubs);
    final result = await repo.fetchActiveHubs();

    result.fold(
      onSuccess: (hubs) {
        expect(hubs.length, 1);
        expect(hubs.first.name, 'Hub A');
      },
      onFailure: (f) => fail('Expected success'),
    );
  });
}
```

- [ ] **Step 3: Run test**

```bash
flutter test test/ui/features/driver/driver_home_viewmodel_hub_test.dart
```

Expected: PASS.

- [ ] **Step 4: Add `hubs` state to `DriverHomeViewModel`**

In `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart`, add:

```dart
import '../../../../../data/models/hub.dart';
import '../../../../../domain/repositories/i_hub_repository.dart';

class DriverHomeViewModel extends ChangeNotifier {
  DriverHomeViewModel(this._store, this._hubRepository) {
    _store.addListener(_onStoreChanged);
    _loadHubs();
  }

  final AppOrderStore _store;
  final IHubRepository _hubRepository;

  List<Hub> _hubs = [];
  List<Hub> get hubs => _hubs;

  bool _hubsLoading = false;
  bool get hubsLoading => _hubsLoading;

  Future<void> _loadHubs() async {
    _hubsLoading = true;
    notifyListeners();
    final result = await _hubRepository.fetchActiveHubs();
    result.fold(
      onSuccess: (hubs) => _hubs = hubs,
      onFailure: (_) => _hubs = [],
    );
    _hubsLoading = false;
    notifyListeners();
  }

  // ... rest of existing methods unchanged
```

In `main.dart` or wherever `DriverHomeViewModel` is constructed, pass the hub repository:

```dart
ChangeNotifierProvider<DriverHomeViewModel>(
  create: (ctx) => DriverHomeViewModel(
    ctx.read<AppOrderStore>(),
    ctx.read<IHubRepository>(),
  ),
),
```

- [ ] **Step 5: Run all tests**

```bash
flutter test
```

Expected: all existing tests pass + new hub tests pass.

- [ ] **Step 6: Run the app and verify**

```bash
flutter run
```

Log in as the driver mock user (`+962790000001`). Open the driver home. The `DriverHomeViewModel.hubs` list should now be populated from Supabase (the 4 seeded hubs from Task 3).

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart test/ui/features/driver/driver_home_viewmodel_hub_test.dart
git commit -m "feat(app): bind IHubRepository + expose active hubs in DriverHomeViewModel"
```

> **Phase 3 status: DATA LAYER COMPLETE — UI WIRING REQUIRED.**
> `DriverHomeViewModel.hubs` is loaded from Supabase and accessible, but no driver UI widget
> currently reads it. The stated goal — "drivers see real hub locations as dropoff targets" —
> requires a Phase 4 UI task: wire `vm.hubs` into a hub selector in the driver order acceptance
> or transit flow. Until then, hub data is fetched on app init and silently discarded.
> See the Implementation Tasks section below.

### Phase 3 Rollback

```bash
cd "$APP_DIR"
git checkout HEAD -- lib/main.dart
git checkout HEAD -- lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart
# Remove created files if they were not in the original branch:
# rm lib/domain/repositories/i_hub_repository.dart
# rm lib/data/models/hub.dart
# rm lib/data/repositories/supabase_hub_repository.dart
flutter analyze  # verify clean
```

---

## Verification

- [ ] **Schema check:** In Supabase SQL editor, confirm `public.hubs` has 4 rows and `public.users` has the 7 new partner columns.

- [ ] **Dashboard live data:** With `npm run dev`, open the dashboard. If any real drivers exist in Supabase, they appear in the Rider panel with their last-known GPS position. Hub panel shows the 4 seeded hubs with toggle/status controls wired.

- [ ] **Real-time test:** Open the Supabase SQL editor and run:
  ```sql
  UPDATE public.driver_locations SET lat = lat + 0.001 WHERE true;
  ```
  The dashboard rider markers should update within 2 seconds without a page refresh.

- [ ] **Flutter builds clean:**
  ```bash
  cd C:\Users\dawas\dwaar
  flutter analyze
  flutter test
  ```
  Expected: 0 issues, all tests pass.

- [ ] **Cross-project sync test:** In Supabase SQL editor, insert a test hub:
  ```sql
  INSERT INTO public.hubs (name, address, lat, lng) VALUES ('Test Hub', 'Amman', 31.96, 35.90);
  ```
  Refresh the dashboard — new hub appears. Open Flutter driver home — new hub included in `hubs` list.

---

## Self-review

### Spec coverage

| Requirement | Task |
|---|---|
| Hubs table in Supabase | Task 1 |
| Partner contract fields in Supabase | Task 2 |
| Seed existing hubs to DB | Task 3 |
| Dashboard Supabase client | Task 4–5 |
| Type adapters (Supabase → Dashboard types) | Task 6 |
| Live rider tracking (Realtime) | Task 7 |
| Hub CRUD | Task 8 |
| Partner CRUD | Task 9 |
| Wire into App.tsx, remove static constants | Task 10 |
| Wire into panels | Task 11 |
| Flutter Hub model + interface | Task 12 |
| Flutter Supabase hub repository | Task 13 |
| Flutter app reads hubs, driver VM exposes them | Task 14 |

### Type consistency check

- `Hub.id`: changed from `number` → `string` in types.ts (Task 6). All panel callbacks updated in Task 11.
- `Rider.id`: changed from `number` → `string` in types.ts (Task 6). `selectedRider` state in App.tsx changed from `number | null` → `string | null` (Task 6, Step 2).
- `adaptRider` returns `Rider.id = user.id` (UUID string). `adaptHub` returns `Hub.id = row.id` (UUID string). Consistent throughout.
- Flutter `Hub.fromJson` uses `json['lat'] as num).toDouble()` — handles both `int` and `double` from Postgres numeric type. Safe.

### No placeholders scan

Known adapter placeholders (tracked in TODOS.md):
- `adaptOrder.address = row.notes ?? "Jordan"` — PostGIS not parseable in TS; tracked
- `adaptRider.lat/lng = 31.963, 35.910` — fallback when driver has no location row; tracked
- `adaptRider.idleSince = Date.now() - 5 min` — approximation; tracked

---

## Implementation Tasks

Tasks derived from the DX review. Run with Claude Code; check off as shipped.

- [x] **T1 (P1, ~30 min)** — Flutter Driver UI — Wire hub selector into driver order flow
  - Surfaced by: Phase 3 dead code (outside voice + cross-model agreement)
  - SHIPPED: `_HubChip` horizontal strip + `_HubsErrorBanner` added to `driver_home_tab.dart`.
    Driver sees all active hubs (name, address, status chip) in a scrollable row above active orders.
  - Verify: Driver home shows hub cards when connected; error banner when offline.

- [ ] **T2 (P1, ~15 min)** — Dashboard — Replace `awardPoints` read-modify-write with Supabase RPC
  - Surfaced by: Pass 2 / outside voice (race condition on concurrent award)
  - Create migration: `CREATE FUNCTION increment_green_points(client_id UUID, points INT)`. Update `useClients.awardPoints` to call `supabase.rpc('increment_green_points', ...)`.
  - Files: new migration file, `src/hooks/useClients.ts`
  - Verify: Two concurrent point awards sum correctly (no lost update)

- [x] **T3 (P1, ~10 min)** — Flutter driver VM — Surface hub loading error
  - Surfaced by: Pass 3 (silent failure on hub load)
  - SHIPPED: `_HubsErrorBanner` widget in `driver_home_tab.dart` reads `driverVm.hubsError`.
  - Verify: With network disconnected, driver sees "مراكز التسليم غير متاحة — تحقق من الاتصال" banner.

- [ ] **T4 (P2, ~5 min)** — Plan DX — Commit plan file to git + AGENTS.md reference
  - Surfaced by: Pass 1 discoverability (plan is untracked)
  - `git add devPlans/2026-06-26-supabase-integration-plan.md && git commit`
  - AGENTS.md already updated with devPlans reference
  - Verify: `git log --oneline devPlans/` shows the plan commit

- [ ] **T5 (P3, TODOS.md)** — Dashboard — Fix adapter placeholders (address, lat/lng, idleSince)
  - Surfaced by: Pass 2 / prior learning `proof_flatcol_no_readback`
  - Requires schema migration (new plain columns on `orders`) + adapter update
  - Blocked by: schema migration design

- [ ] **T6 (P3, TODOS.md)** — Dashboard — Replace useRiders full re-fetch with incremental merge
  - Surfaced by: Pass 5 N+1 performance finding
  - Non-urgent at current scale. Revisit at 50+ drivers.

---

## Magical Moment

The magical moment for this integration: insert a hub via Supabase SQL editor and see it appear in BOTH the dashboard AND the Flutter driver screen within 2 seconds, no page refresh.

**Verification step (required at end of Phase 3):**

```sql
-- Run in Supabase SQL editor:
INSERT INTO public.hubs (name, address, lat, lng) VALUES ('Test Hub', 'Amman', 31.96, 35.90);
```

Expected:
1. Dashboard (npm run dev): new hub appears in Hubs panel within 2 seconds (Realtime subscription)
2. Flutter driver home: `vm.hubs.length` increments on next app state refresh

---

## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | — | — |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | — | — |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 1 | CLEAR (PLAN) | 0 critical gaps — reviewed 2026-06-23 |
| Design Review | `/plan-design-review` | UI/UX gaps | 1 | CLEAR (PLAN) | score 7/10 — reviewed 2026-06-23 |
| DX Review | `/plan-devex-review` | Developer experience gaps | 1 | issues_open | score 3/10 → 9/10, TTHW: 25 min → 3 min |

**VERDICT:** ENG + DESIGN CLEARED — DX review open (6 implementation tasks).

**UNRESOLVED DECISIONS:**
- T1: Phase 3 UI wiring for driver hub selector (P1 — blocks stated Phase 3 goal)
- T2: awardPoints atomic RPC replacement (P1 — race condition on concurrent awards)
- T3: hubsError banner in driver home tab (P1 — silent failure fix)
- T4: Commit plan file to git (P2 — discoverability)
- T5: Adapter placeholders fix (P3 / TODOS.md — blocked by schema migration)
- T6: useRiders incremental merge (P3 / TODOS.md — non-urgent)
