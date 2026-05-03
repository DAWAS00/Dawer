# Edge Functions Catalogue

Server-side logic that must not live in the Flutter client (Principle #3).

## `calculate_reward`

**Status:** shipped (MVP)
**Trigger:** HTTPS POST from Flutter
**File:** `supabase/functions/calculate_reward/index.ts`
**Client:** `lib/data/services/reward_service.dart` (`RewardService.calculate(...)`) returning `RewardBreakdown` (`lib/data/models/reward_breakdown.dart`)

### Contract

Request:
```json
{
  "waste_types": ["plastic", "metal"],
  "estimated_weight_kg": 10.0,
  "distance_km": 3.5,
  "is_urgent": false
}
```

Response (200):
```json
{
  "base_fee": 1.5,
  "distance_fee": 2.1,
  "material_fee": 0.3,
  "urgency_bonus": 0,
  "total_jd": 3.9
}
```

When the primary waste type is unknown (e.g. `furniture`), the response adds `"needs_manual_review": true` and `material_fee` is 0.

### Pricing model

| Component | Formula |
|---|---|
| `base_fee` | 1.500 JD (flat) |
| `distance_fee` | `distance_km * 0.60` JD |
| `material_fee` | `estimated_weight_kg * MATERIAL_RATES[waste_types[0]]` |
| `urgency_bonus` | 0.500 JD if `is_urgent`, else 0 |
| `total_jd` | sum, rounded to 3 decimals |

`MATERIAL_RATES` is defined at the top of the function file — update there when pricing changes.

### Deploy

```bash
supabase functions deploy calculate_reward --project-ref [FILL: dev-ref]
```

### Error codes

- `400 invalid JSON` — body not parseable
- `400 <field> must be ...` — validation failure
- `405 Method not allowed` — non-POST (except OPTIONS)

---

## `handle_order_event` (deferred — Phase 5)

**Status:** not implemented
**Trigger:** Postgres webhook on `orders` INSERT/UPDATE
**Purpose:** Insert `notifications` rows + dispatch FCM push messages

Requires FCM project setup. Schema columns `fcm_token` already exist on `users`.

---

## `nearby_drivers` (deferred — Phase 5)

**Status:** SQL RPC shipped in migration `006_rpcs.sql`; HTTP wrapper deferred
**Trigger:** HTTPS POST from `handle_order_event`
**Purpose:** Return available drivers + FCM tokens within radius for multicast

The Postgres function is already deployed with `SECURITY DEFINER` + `service_role`-only EXECUTE grant, so it's ready for the Edge wrapper when FCM lands.
