# 8. Supabase Backend

## Overview

The backend is built on **Supabase**:

- **Postgres** database with RLS.
- **Realtime** for live driver locations and order streams.
- **Edge Functions** (Deno/TypeScript) for push, matching, arrival verification, and payouts.
- **Storage** for profile photos, identity documents, and proof photos.
- **Auth** (GoTrue) for phone/email authentication.

## Flutter connection

Initialized in `main.dart`:

```dart
await SupabaseService.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? 'https://bpzuwwbtqqrpohfqjcuo.supabase.co',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable__JiNp6XeCpIOC1rWi9PwpA_JA51eBU7',
);
```

> The fallback URL and key are hardcoded for dev convenience. Production builds must set real values in `.env.local`.

## Schema

### Core tables

| Table | Purpose |
|---|---|
| `public.users` | Profiles bound to `auth.users` |
| `public.orders` | Pickup requests, collection jobs, collection sales, marketplace listings |
| `public.notifications` | In-app notification inbox |
| `public.transactions` | Recorded payout/fee breakdowns |
| `public.driver_locations` | Live driver GPS |
| `public.driver_wallet` | Driver escrow/balance |
| `public.wallet_transactions` | Immutable wallet ledger |
| `public.fraud_audit` | Fraud and suspicious-event log |

### Enums

```sql
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
```

### public.users

```sql
CREATE TABLE public.users (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  auth_id             UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
  categories          TEXT[] DEFAULT '{}',
  vehicle_type        vehicle_type,
  has_chemical_permit BOOLEAN DEFAULT false,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### public.orders

```sql
CREATE TABLE public.orders (
  id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type                        order_type NOT NULL,
  status                      order_status NOT NULL DEFAULT 'pending',
  supplier_id                 UUID REFERENCES public.users(id),
  driver_id                   UUID REFERENCES public.users(id),
  company_id                  UUID REFERENCES public.users(id),
  waste_types                 TEXT[] NOT NULL DEFAULT '{}',
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
  job_description             TEXT,
  payment_model               payment_model,
  price_per_kg                NUMERIC,
  item_price                  NUMERIC,
  min_quantity_kg             NUMERIC,
  collection_delivery_method  collection_delivery_method,
  collection_transaction_type collection_transaction_type,
  created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at                 TIMESTAMPTZ,
  in_transit_at               TIMESTAMPTZ,
  completed_at                TIMESTAMPTZ
);
```

Extended columns added by later migrations:
- `arrived_at_pickup_at`, `arrived_at_dropoff_at`
- `arrival_confirmation_status`
- `supplier_hold_amount`, `driver_compensation_amount`
- `fraud_attempt_count`, `weight_variance_flag`
- `proof_image_path`, `proof_captured_at`, `proof_lat`, `proof_lng`, `proof_checksum`
- `required_vehicle_type`, `requires_chemical_permit`, `admin_approval_status`
- `expires_at`, `is_vat_applicable`, `vat_amount_jd`

## Functions

### Helper functions

| Function | Purpose |
|---|---|
| `current_user_id()` | Returns `public.users.id` for the current JWT |
| `get_email_by_phone(phone_number)` | Looks up email by phone for sign-in |
| `identifier_exists(identifier)` | Duplicate phone/email check |
| `is_available_driver()` | True if current user is an available driver |
| `nearby_drivers(lat, lng, radius_km)` | PostGIS search for available drivers |
| `nearby_orders(lat, lng, radius_km)` | PostGIS search for pending orders |
| `order_pickup_coords(p_order_id)` | Returns pickup lat/lng of an order |

### RPCs / business logic

| Function | Purpose |
|---|---|
| `record_order_transaction(...)` | SECURITY DEFINER; drivers record payout rows |
| `driver_wallet_hold(order_id, amount)` | Escrow hold on accept |
| `driver_wallet_release(order_id, amount)` | Release held → balance on complete |

## Triggers

| Trigger | Function | Purpose |
|---|---|---|
| `on_auth_user_created` | `auto_confirm_user()` | Auto-confirms emails on signup (dev convenience) |
| `trg_order_status_transition` | `enforce_order_status_transition()` | Blocks invalid status transitions, timestamps |
| `trg_driver_single_active` | `enforce_driver_single_active_order()` | One active order per driver |
| `trg_supplier_points` | `update_supplier_points_on_complete()` | Awards points + notification on completion |
| `trg_auto_credit_driver_compensation` | `auto_credit_driver_compensation()` | Credits driver compensation on cancellation |
| `trg_notify_order_status` | `notify_order_status_change()` | Calls `send_push` Edge Function on status change |

## Row-Level Security (RLS)

RLS is enabled on all business tables. Key policies:

### users

- SELECT/INSERT/UPDATE only own row (`auth.uid() = auth_id`).
- SELECT participant rows for order parties.

### orders

- INSERT by supplier/company (`supplier_id`/`company_id` = me).
- SELECT by own supplier/driver/company.
- SELECT pending orders visible to drivers.
- UPDATE by assigned driver or supplier cancelling pending/accepted orders.

### notifications

- SELECT/UPDATE only own (`recipient_id = current_user_id()`).

### transactions

- SELECT by driver or linked order's company.
- Writes restricted to service role / SECURITY DEFINER RPC.

### driver_locations

- Drivers can upsert/delete own row only.
- All authenticated users can read.

### driver_wallet / wallet_transactions / fraud_audit

- Driver can read own wallet/transactions.
- Writes restricted to service role / SECURITY DEFINER functions.

## Storage buckets

| Bucket | Public | Size limit | MIME types |
|---|---|---|---|
| `profile-photos` | yes | 5 MB | image/jpeg, image/png, image/webp |
| `user-documents` | no | 10 MB | image/jpeg, image/png, image/webp, application/pdf |
| `proof-photos` | no | unlimited | all |

Storage RLS enforces owner/participant access. Profile photos use `{userId}/...` path prefixes.

## Migrations

| Migration | File | Purpose |
|---|---|---|
| `00001_initial_schema.sql` | `supabase/migrations/00001_initial_schema.sql` | Initial enums, tables, functions, triggers, RLS, storage |
| `00002_add_user_categories.sql` | `supabase/migrations/00002_add_user_categories.sql` | Adds `categories TEXT[]` to `users` |
| `20260519_security_tables.sql` | `supabase/migrations/20260519_security_tables.sql` | Security columns, `fraud_audit`, wallet tables |
| `20260522_driver_locations.sql` | `supabase/migrations/20260522_driver_locations.sql` | `driver_locations` table + realtime |
| `20260522_marketplace_limits.sql` | `supabase/migrations/20260522_marketplace_limits.sql` | `expires_at`, `record_order_transaction()` RPC |
| `20260522_transaction_commission.sql` | `supabase/migrations/20260522_transaction_commission.sql` | Full pricing breakdown columns |
| `20260522_vehicle_type.sql` | `supabase/migrations/20260522_vehicle_type.sql` | `vehicle_type` enum, chemical-permit/admin columns |
| `20260522_wallet_functions.sql` | `supabase/migrations/20260522_wallet_functions.sql` | Wallet hold/release RPCs, compensation trigger |
| `20260612_push_and_matching.sql` | `supabase/migrations/20260612_push_and_matching.sql` | `pg_net`, `order_pickup_coords()`, status-change webhook |

## Edge Functions

All functions live under `supabase/functions/`.

| Function | File | Purpose |
|---|---|---|
| `verify_arrival` | `supabase/functions/verify_arrival/index.ts` | Server-side geofence gate |
| `match_driver` | `supabase/functions/match_driver/index.ts` | Nearest-driver notification |
| `send_push` | `supabase/functions/send_push/index.ts` | Central FCM + inbox dispatch |
| `daily_payout` | `supabase/functions/daily_payout/index.ts` | Scheduled driver payout |

Shared FCM helper: `supabase/functions/_shared/fcm.ts`.

See [`09-push-notifications.md`](09-push-notifications.md) for push/matching details and [`05-tracking-and-proximity.md`](05-tracking-and-proximity.md) for `verify_arrival`.

## Files referenced

- `lib/core/services/supabase_service.dart`
- `lib/data/repositories/supabase_order_repository.dart`
- `lib/data/repositories/supabase_wallet_repository.dart`
- `lib/data/repositories/supabase_auth_repository.dart`
- `lib/data/repositories/supabase_file_storage_repository.dart`
- `supabase/migrations/*.sql`
- `supabase/functions/*`
