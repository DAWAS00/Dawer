---
description: "Wire the Dwaar admin dashboard (React + TypeScript + Vite) to the shared Supabase instance — replace all static mock constants (RIDERS, INITIAL_HUBS, CLIENTS) with live Supabase hooks and Realtime subscriptions. Phase 2 of the App ↔ Supabase ↔ Dashboard integration."
mode: agent
tools:
  - codebase
  - editFiles
  - runCommands
  - problems
  - search
---

# Phase 2 — Dashboard Supabase Integration (Dwaar)

You are a senior React / TypeScript / Supabase engineer. You are working on the **Dwaar admin dashboard** (`E:\Dawer DashBorad\AdminDashboardForRecycling`) — a React 18 + TypeScript + Vite app that monitors drivers, collection hubs, and recycling partners. Your job is to replace every static mock constant with live Supabase data, add Realtime subscriptions for driver locations and order updates, and wire all CRUD operations through to the database.

**You have full workspace access. Proceed directly — no permission needed before reading files or running commands.**

---

## Critical Facts (do not skip)

- **Supabase project ref:** `bbpleeddaquwwvexzmdc`
- **Supabase URL:** `https://bbpleeddaquwwvexzmdc.supabase.co`
- **User profiles table:** `public.profiles` (NOT `public.users` — the Flutter app uses `profiles`)
- **Primary key on profiles:** `auth_id` (UUID) — there is no `id` column
- **Hubs table:** `public.hubs` — created in Phase 1 with 4 seed rows
- **Driver locations table:** `public.driver_locations` — columns: `driver_id` (UUID FK to profiles.auth_id), `lat` (float8), `lng` (float8), `updated_at` (timestamptz)
- **Orders table:** `public.orders` — columns include: `id`, `status`, `driver_id`, `supplier_id`, `company_id`, `waste_types` (text[]), `estimated_weight_kg`, `actual_weight_kg`, `reward_jd`, `created_at`, `accepted_at`, `completed_at`
- **Dashboard folder:** `E:\Dawer DashBorad\AdminDashboardForRecycling`
- **The service-role key bypasses RLS** — correct for this internal admin tool. Never commit it.

---

## Context You Must Read First

Before writing a single line of code, read these files:

1. `src/app/types.ts` — all TypeScript interfaces (`Rider`, `Hub`, `Client`, `Order`, `ActiveRoute`)
2. `src/app/constants.ts` — `RIDERS`, `INITIAL_HUBS`, `CLIENTS` static arrays you will replace
3. `src/app/App.tsx` — full component: state, handlers, JSX wiring
4. `src/app/components/HubsPanel.tsx` — current hub CRUD using local `setHubs` state
5. `src/app/components/AddHubModal.tsx` — current add-hub flow
6. `src/app/components/partners/PartnersView.tsx` — currently reads from `CLIENTS` constant

---

## Pre-flight Checks

Run all of these before creating any files.

### 1. Is `@supabase/supabase-js` installed?

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
npm list @supabase/supabase-js 2>&1
```

If not installed: `npm install @supabase/supabase-js`

### 2. Does `.env.local` exist with the service key?

```bash
Test-Path "E:\Dawer DashBorad\AdminDashboardForRecycling\.env.local"
```

If missing, create it (see Task 1 below). Never commit it.

### 3. Does `src/lib/supabase.ts` already exist?

```bash
Test-Path "E:\Dawer DashBorad\AdminDashboardForRecycling\src\lib\supabase.ts"
```

### 4. Does `src/hooks/` directory exist?

```bash
Test-Path "E:\Dawer DashBorad\AdminDashboardForRecycling\src\hooks"
```

### 5. Hubs in Supabase?

Verify Phase 1 is applied — run this via the Supabase MCP or SQL editor:

```sql
SELECT COUNT(*) FROM public.hubs;
```

Expected: `4`. If `0` or table missing, Phase 1 is not applied — stop.

### 6. Is the build clean before you start?

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
npm run build 2>&1
```

Expected: no TypeScript errors. Fix any pre-existing errors before proceeding.

### Pre-flight report

| Check | Status | Action |
|---|---|---|
| @supabase/supabase-js installed | ✅/❌ | install if missing |
| .env.local exists | ✅/⬜ | create if missing |
| src/lib/supabase.ts exists | ✅/⬜ | create if missing |
| src/hooks/ exists | ✅/⬜ | create if missing |
| public.hubs has 4 rows | ✅/❌ | stop if ❌ |
| npm run build clean | ✅/❌ | fix before proceeding |

---

## Task 1 — Install Supabase + Environment Setup

### Step 1: Install the package (if not already installed)

```bash
cd "E:\Dawer DashBorad\AdminDashboardForRecycling"
npm install @supabase/supabase-js
```

### Step 2: Create `.env.local`

Create `E:\Dawer DashBorad\AdminDashboardForRecycling\.env.local`:

```
VITE_SUPABASE_URL=https://bbpleeddaquwwvexzmdc.supabase.co
VITE_SUPABASE_SERVICE_KEY=<paste your service_role key from Supabase dashboard → Settings → API>
```

> ⚠️ **NEVER commit this file.** Verify `.gitignore` includes `.env.local`.
> The service_role key bypasses RLS — this dashboard is an internal admin tool.

### Step 3: Verify build still clean

```bash
npm run build 2>&1
```

Expected: no errors.

### Step 4: Commit (only package.json and package-lock.json — NOT .env.local)

```bash
git add package.json package-lock.json
git commit -m "feat(dashboard): install @supabase/supabase-js"
```

---

## Task 2 — Supabase Client + Raw Row Types

### Step 1: Create `src/lib/` directory if it doesn't exist, then create `src/lib/supabase.ts`

```typescript
// src/lib/supabase.ts
import { createClient, SupabaseClient } from "@supabase/supabase-js";

const SUPABASE_URL =
  import.meta.env.VITE_SUPABASE_URL ??
  "https://bbpleeddaquwwvexzmdc.supabase.co";

const SUPABASE_SERVICE_KEY = import.meta.env.VITE_SUPABASE_SERVICE_KEY ?? "";

if (!SUPABASE_SERVICE_KEY) {
  console.warn(
    "[Dwaar Dashboard] VITE_SUPABASE_SERVICE_KEY is not set. " +
    "Add it to .env.local — see the integration plan."
  );
}

/**
 * Service-role Supabase client — bypasses RLS.
 * Internal admin tool only — never expose to end users.
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

// ─── Raw Supabase row types (snake_case, mirrors the DB schema exactly) ────────

export interface SupabaseProfile {
  auth_id: string;          // PK — UUID, FK to auth.users
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
  // Partner fields (added in Phase 1)
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

### Step 2: Verify build

```bash
npm run build 2>&1
```

Expected: no TypeScript errors.

### Step 3: Commit

```bash
git add src/lib/supabase.ts
git commit -m "feat(dashboard): add supabase client + raw row types"
```

---

## Task 3 — Update `types.ts`: Change `Rider.id` and `Hub.id` to `string`

**This is the most disruptive change. Do it before hooks so TypeScript catches every callsite.**

### Step 1: Edit `src/app/types.ts`

Change `Rider.id` from `number` to `string`:

```typescript
export interface Rider {
  id: string;   // was number — now UUID string from Supabase (auth_id)
  // ... all other fields unchanged
}
```

Change `Hub.id` from `number` to `string`:

```typescript
export interface Hub {
  id: string;   // was number — now UUID string from Supabase
  // ... all other fields unchanged
}
```

Change `ActiveRoute.riderId` from `number` to `string`:

```typescript
export interface ActiveRoute {
  orderId: string;
  riderId: string;  // was number
  // ... rest unchanged
}
```

Change `CompletedTrip.riderId` from `number` to `string`:

```typescript
export interface CompletedTrip {
  orderId: string;
  riderId: string;  // was number
  // ... rest unchanged
}
```

### Step 2: Run build to find all type errors

```bash
npm run build 2>&1
```

Fix every error before proceeding. Common cascading errors:

- **`App.tsx`**: `selectedRider: number | null` → `string | null`. `selectedHub: number | null` → `string | null`.
- **`App.tsx` handlers**: `handleRiderSelect: (id: number)` → `string`. `handleHubSelect: (id: number)` → `string`. `handleOrderClick: (riderId: number, ...)` → `string`.
- **`HubsPanel.tsx`**: `selectedId: number | null` → `string | null`. `onSelect: (id: number)` → `string`. All `id: number` variables inside the component → `string`.
- **`constants.ts`**: `RIDERS` array has `id: 1, 2, ...` integer IDs — these will be removed in Task 6, but for now change them to string literals (`id: "rider-1"`) to satisfy TypeScript temporarily. Same for `INITIAL_HUBS` (`id: "hub-1"` etc).
- **`constants.ts`**: `CLIENTS` array likely has `id: string` already (check) — probably fine.
- **Any component** passing riderId/hubId as `number` — update to `string`.

Keep running `npm run build 2>&1` until zero errors.

### Step 3: Commit the type change only

```bash
git add src/app/types.ts src/app/constants.ts src/app/App.tsx src/app/components/HubsPanel.tsx
git commit -m "refactor(dashboard): change Rider.id, Hub.id, ActiveRoute.riderId to string (pre-Supabase)"
```

---

## Task 4 — Data Adapters (`src/lib/adapters.ts`)

Create `src/lib/adapters.ts`. These functions map raw Supabase rows to the dashboard's existing TypeScript types.

```typescript
// src/lib/adapters.ts
import { Rider, Order, Hub, Client, ClientType, ContractTier, HubMaterials } from "../app/types";
import {
  SupabaseProfile,
  SupabaseOrder,
  SupabaseDriverLocation,
  SupabaseHub,
} from "./supabase";

// ─── Waste type mapping ────────────────────────────────────────────────────────
// Maps Flutter app's WasteType enum values → dashboard's 4-category model.
const WASTE_TO_MATERIAL: Record<string, Order["material"]> = {
  oil:             "Cooking Oil",
  cookingOil:      "Cooking Oil",
  plastic:         "Plastic Bottles",
  electronics:     "Electronics",
  batteries:       "Electronics",
  copperAluminium: "Electronics",
  paper:           "Paper & Cardboard",
  cardboard:       "Paper & Cardboard",
  glass:           "Plastic Bottles",
  metal:           "Plastic Bottles",
};

function mapWasteTypes(wasteTypes: string[]): Order["material"] {
  for (const wt of wasteTypes) {
    const mapped = WASTE_TO_MATERIAL[wt];
    if (mapped) return mapped;
  }
  return "Plastic Bottles";
}

// ─── CO₂ estimate ─────────────────────────────────────────────────────────────
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
  if (status === "inTransit")  return "inTransit";
  if (status === "completed")  return "completed";
  if (status === "accepted")   return "accepted";
  return "pending";
}

function deriveRiderStatus(orders: Order[]): Rider["status"] {
  const active = orders.find(o => o.status === "inTransit" || o.status === "accepted");
  if (!active) return "idle";
  return active.status === "inTransit" ? "delivering" : "picking_up";
}

function mapVehicleType(vt: SupabaseProfile["vehicle_type"]): Rider["vehicle"] {
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
    deliveryLat:  31.963,  // placeholder — orders don't have coords in dashboard context
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
  profile: SupabaseProfile,
  location: SupabaseDriverLocation | null,
  orders: SupabaseOrder[]
): Rider {
  const adaptedOrders = orders.map(adaptOrder);
  const status = deriveRiderStatus(adaptedOrders);
  return {
    id:        profile.auth_id,           // UUID string
    name:      profile.name,
    nameAr:    profile.name,
    phone:     profile.phone,
    lat:       location?.lat ?? 31.963,   // Amman centre fallback
    lng:       location?.lng ?? 35.910,
    status,
    vehicle:   mapVehicleType(profile.vehicle_type),
    orders:    adaptedOrders,
    idleSince: status === "idle" ? Date.now() - 5 * 60 * 1000 : undefined,
  };
}

export function adaptHub(row: SupabaseHub): Hub {
  return {
    id:               row.id,
    name:             row.name,
    address:          row.address,
    lat:              Number(row.lat),
    lng:              Number(row.lng),
    active:           row.active,
    capacityKg:       Number(row.capacity_kg),
    currentLoad:      row.current_load as HubMaterials,
    schedule:         row.schedule,
    nextShipmentDate: row.next_shipment_date ?? "",
    lastShipmentDate: row.last_shipment_date ?? "",
    status:           row.status,
  };
}

export function adaptClient(profile: SupabaseProfile): Client {
  return {
    id:            profile.auth_id,
    name:          profile.name,
    type:          "other" as ClientType,
    address:       profile.address ?? "",
    phone:         profile.phone,
    email:         profile.email ?? "",
    contractTier:  (profile.contract_tier ?? "free") as ContractTier,
    joinedDate:    profile.created_at.split("T")[0],
    orders:        [],
    totalCo2Saved: 0,
    totalEarnings: 0,
    renewalDate:   profile.renewal_date ?? "",
    billingCycle:  (profile.billing_cycle ?? "monthly") as "monthly" | "annual",
    greenPoints:   profile.green_points ?? 0,
    customPriceJD: profile.custom_price_jd ?? undefined,
    contractNotes: profile.contract_notes ?? undefined,
    lastCertificateDownload: profile.last_certificate_download ?? undefined,
    referredBy:    profile.referred_by ?? undefined,
  };
}
```

After creating the file:

```bash
npm run build 2>&1
```

Expected: no errors.

```bash
git add src/lib/adapters.ts
git commit -m "feat(dashboard): add data adapters — Supabase rows to dashboard types"
```

---

## Task 5 — Live Rider Hook (`src/hooks/useRiders.ts`)

Create `src/hooks/useRiders.ts`:

```typescript
// src/hooks/useRiders.ts
import { useState, useEffect } from "react";
import { supabase, SupabaseProfile, SupabaseDriverLocation, SupabaseOrder } from "../lib/supabase";
import { adaptRider } from "../lib/adapters";
import { Rider } from "../app/types";

export function useRiders() {
  const [riders, setRiders]   = useState<Rider[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  async function fetchAll() {
    setLoading(true);
    setError(null);

    const { data: profiles, error: pErr } = await supabase
      .from("profiles")
      .select("*")
      .eq("role", "driver");

    if (pErr) { setError(pErr.message); setLoading(false); return; }
    if (!profiles || profiles.length === 0) { setRiders([]); setLoading(false); return; }

    const driverIds = (profiles as SupabaseProfile[]).map(p => p.auth_id);

    const [{ data: locations }, { data: orders }] = await Promise.all([
      supabase.from("driver_locations").select("*").in("driver_id", driverIds),
      supabase
        .from("orders")
        .select("*")
        .in("driver_id", driverIds)
        .in("status", ["pending", "accepted", "inTransit"]),
    ]);

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

    const adapted = (profiles as SupabaseProfile[]).map(p =>
      adaptRider(p, locationMap[p.auth_id] ?? null, ordersByDriver[p.auth_id] ?? [])
    );

    setRiders(adapted);
    setLoading(false);
  }

  useEffect(() => {
    let cancelled = false;

    const wrappedFetch = async () => {
      if (!cancelled) await fetchAll();
    };

    wrappedFetch();

    // Realtime: re-fetch on any driver_location change (live map updates)
    const locationChannel = supabase
      .channel("dashboard-driver-locations")
      .on("postgres_changes", { event: "*", schema: "public", table: "driver_locations" }, () => {
        if (!cancelled) fetchAll();
      })
      .subscribe();

    // Realtime: re-fetch on any order change (status badge updates)
    const ordersChannel = supabase
      .channel("dashboard-driver-orders")
      .on("postgres_changes", { event: "*", schema: "public", table: "orders" }, () => {
        if (!cancelled) fetchAll();
      })
      .subscribe();

    return () => {
      cancelled = true;
      supabase.removeChannel(locationChannel);
      supabase.removeChannel(ordersChannel);
    };
  }, []);

  return { riders, loading, error, refetch: fetchAll };
}
```

```bash
npm run build 2>&1
git add src/hooks/useRiders.ts
git commit -m "feat(dashboard): add useRiders hook with Supabase Realtime"
```

---

## Task 6 — Hub Hook (`src/hooks/useHubs.ts`) with CRUD

Create `src/hooks/useHubs.ts`:

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

  useEffect(() => { fetchHubs(); }, []);

  /** Add a new hub. lat/lng come from the map click in AddHubModal. */
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

  /** Toggle a hub's active status. */
  const toggleHubActive = useCallback(async (hubId: string, active: boolean) => {
    const { error: err } = await supabase
      .from("hubs")
      .update({ active })
      .eq("id", hubId);
    if (err) throw new Error(err.message);
    await fetchHubs();
  }, []);

  /** Advance hub status: collecting → ready → shipped → collecting. */
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

```bash
npm run build 2>&1
git add src/hooks/useHubs.ts
git commit -m "feat(dashboard): add useHubs hook with CRUD operations"
```

---

## Task 7 — Partners Hook (`src/hooks/useClients.ts`)

Create `src/hooks/useClients.ts`:

```typescript
// src/hooks/useClients.ts
import { useState, useEffect, useCallback } from "react";
import { supabase, SupabaseProfile } from "../lib/supabase";
import { adaptClient } from "../lib/adapters";
import { Client, ContractTier } from "../app/types";

export function useClients() {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);

  async function fetchClients() {
    const { data, error: err } = await supabase
      .from("profiles")
      .select("*")
      .eq("role", "recyclingCo")
      .order("created_at", { ascending: false });

    if (err) { setError(err.message); return; }
    setClients((data as SupabaseProfile[]).map(adaptClient));
    setLoading(false);
  }

  useEffect(() => { fetchClients(); }, []);

  /** Update a partner's contract tier. */
  const updateTier = useCallback(
    async (clientId: string, tier: ContractTier) => {
      const { error: err } = await supabase
        .from("profiles")
        .update({ contract_tier: tier })
        .eq("auth_id", clientId);
      if (err) throw new Error(err.message);
      await fetchClients();
    },
    []
  );

  /** Update a partner's contract notes. */
  const updateNotes = useCallback(
    async (clientId: string, notes: string) => {
      const { error: err } = await supabase
        .from("profiles")
        .update({ contract_notes: notes })
        .eq("auth_id", clientId);
      if (err) throw new Error(err.message);
      await fetchClients();
    },
    []
  );

  /** Award green points (additive). */
  const awardPoints = useCallback(
    async (clientId: string, points: number) => {
      const client = clients.find(c => c.id === clientId);
      if (!client) return;
      const { error: err } = await supabase
        .from("profiles")
        .update({ green_points: client.greenPoints + points })
        .eq("auth_id", clientId);
      if (err) throw new Error(err.message);
      await fetchClients();
    },
    [clients]
  );

  return { clients, loading, error, updateTier, updateNotes, awardPoints };
}
```

```bash
npm run build 2>&1
git add src/hooks/useClients.ts
git commit -m "feat(dashboard): add useClients hook for B2B partner management"
```

---

## Task 8 — Wire Hooks into `App.tsx`

This is the largest change. Follow these steps carefully.

### Step 1: Add hook imports to `App.tsx`

Add these imports at the top of `App.tsx`:

```typescript
import { useRiders } from "../hooks/useRiders";
import { useHubs }   from "../hooks/useHubs";
```

### Step 2: Replace `RIDERS` and `INITIAL_HUBS` import in `App.tsx`

Find the line:
```typescript
import { RIDERS, ONLINE_COUNT, INITIAL_HUBS, HUB_STATUS_CONFIG, DISTRICTS, STATUS_CONFIG } from "./constants";
```

Change to (remove RIDERS and INITIAL_HUBS, keep everything else):
```typescript
import { ONLINE_COUNT, HUB_STATUS_CONFIG, DISTRICTS, STATUS_CONFIG } from "./constants";
```

### Step 3: Wire hooks inside `App()` function

Add these at the top of the `App()` function body, replacing the existing static state:

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

**Remove** the existing line:
```typescript
const [hubs, setHubs] = useState<Hub[]>(INITIAL_HUBS);
```

(The `hubs` variable now comes from `useHubs()`.)

### Step 4: Replace all `RIDERS` references in `App.tsx`

Every usage of the `RIDERS` constant in App.tsx now uses the `riders` variable from `useRiders()`:
- `RIDERS.find(r => r.id === riderId)` → `riders.find(r => r.id === riderId)`
- Any `RIDERS.filter(...)` → `riders.filter(...)`
- Props passed as `riders={RIDERS}` → `riders={riders}`

### Step 5: Add a loading screen

Add just before the `return (` in App:

```tsx
if (ridersLoading || hubsLoading) {
  return (
    <div style={{
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      height: "100vh",
      background: "#0F172A",
      color: "#64748B",
      fontFamily: "'DM Sans', sans-serif",
      fontSize: 15,
      gap: 12,
    }}>
      <div style={{ width: 20, height: 20, border: "2px solid #1E5C35", borderTopColor: "transparent", borderRadius: "50%", animation: "spin 0.8s linear infinite" }} />
      Connecting to Supabase…
    </div>
  );
}
```

Add to your CSS (or `index.css`): `@keyframes spin { to { transform: rotate(360deg); } }`

### Step 6: Update `handleHubConfirm` to use `addHub`

Find the function in App.tsx that handles the AddHubModal confirmation (likely called `handleAddHub` or inside the `onConfirm` prop). Replace the local `setHubs` call with:

```typescript
async function handleHubConfirm(
  coords: { lat: number; lng: number },
  name: string,
  address: string
) {
  await addHub(coords, name, address);
  setPendingCoords(null);
}
```

### Step 7: Update `HubsPanel` props in App.tsx JSX

Replace the `setHubs` prop with the new CRUD callbacks:

```tsx
<HubsPanel
  hubs={hubs}
  selectedId={selectedHub}
  onSelect={handleHubSelect}
  onToggleActive={toggleHubActive}
  onUpdateStatus={updateHubStatus}
/>
```

### Step 8: Remove `RIDERS` and `INITIAL_HUBS` from `constants.ts`

Open `src/app/constants.ts`. Delete:
- The entire `RIDERS: Rider[]` export array (from `const rawRiders` or `export const RIDERS`)
- The `export const INITIAL_HUBS: Hub[] = [...]` array
- The `export const ONLINE_COUNT = RIDERS.filter(...).length` line (or update: `export const ONLINE_COUNT = 0;` — it will be computed dynamically in the dashboard later)
- The `seedOrderDates` helper function if it was only used by RIDERS

Keep: `MATERIAL_CONFIG`, `STATUS_CONFIG`, `ORDER_STATUS`, `TIER_CONFIG`, `TIER_PRICES_JD`, `TIER_ORDER`, `TIER_MONTHLY_THRESHOLDS`, `GREEN_POINTS_PER_KG`, `TIER_BENEFITS`, `HUB_STATUS_CONFIG`, `MATERIAL_DELIVERY_ESTIMATE_MS`, `IDLE_WARNING_MS`, `IDLE_CRITICAL_MS`, `DISTRICTS`, `CLIENTS`, `PANEL_WIDTH`, and all other config constants.

### Step 9: Build and fix all errors

```bash
npm run build 2>&1
```

Iterate until zero errors. Common issues:
- `ONLINE_COUNT` used in StatsBar — replace with `riders.filter(r => r.status !== "idle").length` passed as prop
- `RIDERS` referenced in any sub-component via import — remove those imports
- `setHubs` passed to HubsPanel — remove (replaced by callbacks)

### Step 10: Commit

```bash
git add src/app/App.tsx src/app/constants.ts
git commit -m "feat(dashboard): wire useRiders + useHubs into App — replace all static mock data"
```

---

## Task 9 — Update `HubsPanel.tsx` to Use Async CRUD

### Step 1: Update props interface

Replace the current `HubsPanelProps`:

```typescript
interface HubsPanelProps {
  hubs: Hub[];
  selectedId: string | null;
  onSelect: (id: string) => void;
  onToggleActive: (id: string, active: boolean) => Promise<void>;
  onUpdateStatus: (id: string, status: Hub["status"]) => Promise<void>;
}
```

### Step 2: Replace local state mutation functions

Remove `toggleActive`, `scheduleShipment`, and `markShipped` local functions (they used `setHubs`).

Replace with calls to the async props:

```typescript
// In the hub card UI:
<button onClick={() => onToggleActive(hub.id, !hub.active)}>
  {hub.active ? "Deactivate" : "Activate"}
</button>

// Next status helper
function nextStatus(current: Hub["status"]): Hub["status"] {
  if (current === "collecting") return "ready";
  if (current === "ready") return "shipped";
  return "collecting";
}

// In the hub card UI:
<button onClick={() => onUpdateStatus(hub.id, nextStatus(hub.status))}>
  {hub.status === "collecting" ? "Mark Ready" : hub.status === "ready" ? "Mark Shipped" : "Reopen"}
</button>
```

### Step 3: Build

```bash
npm run build 2>&1
```

Expected: no errors.

### Step 4: Commit

```bash
git add src/app/components/HubsPanel.tsx
git commit -m "feat(dashboard): update HubsPanel to use async Supabase CRUD props"
```

---

## Task 10 — Update `AddHubModal.tsx` for Async Submit

### Step 1: Find the `onConfirm` prop in `AddHubModal.tsx`

The modal currently calls `onConfirm(coords, name)` synchronously. Make it async with loading state:

```typescript
// In AddHubModal.tsx:
const [submitting, setSubmitting] = useState(false);
const [submitError, setSubmitError] = useState<string | null>(null);

async function handleConfirm() {
  if (!pendingCoords || !name.trim() || !address.trim()) return;
  setSubmitting(true);
  setSubmitError(null);
  try {
    await onConfirm(pendingCoords, name.trim(), address.trim());
    onClose();
  } catch (e) {
    setSubmitError("Failed to save hub. Try again.");
  } finally {
    setSubmitting(false);
  }
}
```

Update the confirm button to show a spinner and disable during submission:

```tsx
<button onClick={handleConfirm} disabled={submitting}>
  {submitting ? "Saving…" : "Add Hub"}
</button>
```

Show `submitError` inline if set.

### Step 2: Update the `onConfirm` prop type

```typescript
interface AddHubModalProps {
  // ...existing props
  onConfirm: (coords: { lat: number; lng: number }, name: string, address: string) => Promise<void>;
}
```

### Step 3: Build + commit

```bash
npm run build 2>&1
git add src/app/components/AddHubModal.tsx
git commit -m "feat(dashboard): make AddHubModal async — shows spinner while Supabase insert runs"
```

---

## Task 11 — Update `PartnersView.tsx` to Use `useClients`

### Step 1: Replace `CLIENTS` import with `useClients` hook

In `PartnersView.tsx`, remove:
```typescript
import { CLIENTS, TIER_CONFIG, TIER_ORDER } from "../../constants";
```

Add:
```typescript
import { useClients } from "../../../hooks/useClients";
import { TIER_CONFIG, TIER_ORDER } from "../../constants";
```

### Step 2: Replace `useState<Client[]>(CLIENTS)` with the hook

Change the top of `PartnersView()`:

```typescript
export function PartnersView() {
  const { clients, loading, updateTier, updateNotes, awardPoints } = useClients();
  const [selectedId, setSelectedId] = useState<string | null>(null);
  // ...rest of existing state (tierFilter, typeFilter, search) unchanged
```

Remove the existing:
```typescript
const [clients, setClients] = useState<Client[]>(CLIENTS);
```

### Step 3: Add a loading guard

```tsx
if (loading) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "center", height: "100%", color: "#64748B" }}>
      Loading partners…
    </div>
  );
}
```

### Step 4: Wire tier update to `updateTier`

Find where the `PartnerDetailDrawer` or `PartnerCard` calls `setClients` to update a tier (e.g., a select dropdown change). Replace any local `setClients(prev => ...)` with `updateTier(clientId, newTier)`.

### Step 5: Wire notes update to `updateNotes`

Find the notes textarea save handler. Replace `setClients(prev => ...)` with `updateNotes(clientId, notesText)`.

### Step 6: Build

```bash
npm run build 2>&1
```

Expected: no errors.

### Step 7: Visual verification

```bash
npm run dev
```

Open `http://localhost:5173`. Verify:
- Partners view shows real `recyclingCo` users from Supabase (may be empty if no users with that role exist yet)
- Changing a tier in the drawer calls Supabase and the change persists after page refresh
- Hubs panel shows the 4 seeded hubs from Phase 1

### Step 8: Commit

```bash
git add src/app/components/partners/PartnersView.tsx
git commit -m "feat(dashboard): PartnersView reads from Supabase via useClients hook"
```

---

## Pinpoint Verification

Run all of these after every task is committed.

### V1 — Build is clean

```bash
npm run build 2>&1
```

Expected: exit 0, no TypeScript errors.

### V2 — Riders panel shows real data

```bash
npm run dev
```

Open `http://localhost:5173`. If any driver profiles exist in `public.profiles` with `role = 'driver'`, they appear in the rider panel with their last GPS location. If no drivers exist yet, the panel shows an empty list (not a crash).

### V3 — Hubs panel shows 4 seeded hubs

With the dashboard open, navigate to Hubs view. Expect to see:
- Hub Al-Sweifieh (active, collecting)
- Hub Downtown (active, ready)
- Hub Jubaiha (active, collecting)
- Hub Tabarbour (inactive, collecting)

### V4 — Real-time driver location update

In the Supabase SQL editor, run:
```sql
UPDATE public.driver_locations SET lat = lat + 0.001 WHERE true;
```

The dashboard rider markers should update within 2 seconds without a page refresh.

### V5 — Hub CRUD works end-to-end

In the dashboard, click "+ Add Hub" on the map. Fill in name and address. Click confirm. The new hub should appear in the list immediately and persist after page refresh (check via `SELECT * FROM public.hubs`).

Toggle a hub active/inactive. Check the change in Supabase.

### V6 — Partners view connected

If a recyclingCo user exists in `public.profiles`, they appear in the Partners view. Changing their tier in the drawer updates `public.profiles.contract_tier` in Supabase.

### V7 — No regressions in existing features

- Heat map still renders with DISTRICTS data (static, unaffected)
- Reports screen still loads
- Map still renders
- Sidebar navigation still works

---

## Verification Report

| Check | Expected | Pass? |
|---|---|---|
| V1 — Build clean | 0 TS errors | ✅/❌ |
| V2 — Riders from Supabase | Live data or empty list (no crash) | ✅/❌ |
| V3 — 4 hubs displayed | All 4 seeded hubs visible | ✅/❌ |
| V4 — Realtime location update | Markers move within 2s of SQL update | ✅/❌ |
| V5 — Hub add/toggle persists | DB updated, visible after refresh | ✅/❌ |
| V6 — Partners from Supabase | recyclingCo users visible, tier update persists | ✅/❌ |
| V7 — No regressions | Heat map, reports, sidebar all work | ✅/❌ |

**All 7 must pass before Phase 2 is declared complete.**

---

## What Phase 2 Does NOT Touch

- ❌ No changes to the Flutter app Dart code
- ❌ No changes to Supabase SQL migrations
- ❌ No changes to `DISTRICTS` (stays static — not in Supabase)
- ❌ No changes to reports (they use aggregated computed data, not live Supabase)
- ❌ No changes to heat map layers
- ❌ No `useOrders` hook — orders are read as part of `useRiders` (driver-scoped). A standalone orders view is a future phase.

---

## Known Corrections vs the Original Plan

These were discovered during Phase 1 and Phase 3 — do not follow the original plan on these points:

| Original plan said | Reality |
|---|---|
| `public.users` | `public.profiles` |
| Primary key `id` | `auth_id` (UUID) |
| Project ref `bpzuwwbtqqrpohfqjcuo` | `bbpleeddaquwwvexzmdc` |
| `SupabaseUser` interface | Use `SupabaseProfile` (matches actual table) |
| `adaptClient` uses `user.id` | Use `profile.auth_id` |
| Index named `users_recycling_co_idx` | Named `profiles_recycling_co_idx` |
