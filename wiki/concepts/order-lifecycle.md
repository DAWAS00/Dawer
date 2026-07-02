---
name: order-lifecycle
description: The Order model, its three types (pickup/collection/collectionSale), status state machine, and all fields
metadata:
  type: concept
---

# Order Lifecycle

The `Order` is a **freezed** model — the central entity of the entire app. All three user roles interact with it differently.

Source: `lib/data/models/order/order.dart`

## Three Order Types (`OrderType`)

| Type | Who Creates | Purpose |
|---|---|---|
| `pickup` | Supplier | Supplier requests waste collected and delivered to recycling co |
| `collection` | Recycling Co | Company posts a job offering to accept waste |
| `collectionSale` | Driver or Supplier | Commitment to deliver to a collection job |

## Status State Machine (`OrderStatus`)

```
pending → accepted → arrivedAtPickup → inTransit → arrivedAtDropoff → completed
                                                                    ↘ cancelled
```

Special cancellation paths:
- **Supplier unavailable** at pickup: cancelled + driver gets 25% compensation (clamped 0.5–5 JD)
- **Arrival timeout** (5-min window): cancelled + driver gets 50% compensation (clamped 1–10 JD)
- **No-show ghost timer**: cancelled, no compensation

## Arrival Confirmation Flow (`ArrivalConfirmationStatus`)

When driver enters 200m pickup geofence: `arrivedAtPickup` + `awaiting`
- Supplier confirms → `inTransit` + `confirmed`
- Supplier presses "not available" → `cancelled` + `unavailable`
- 5-min timeout fires → `cancelled` + `timedOut`

## Key Fields

| Field | Purpose |
|---|---|
| `isMarketplaceShared` | True = item appears in Marketplace tab |
| `requiresRider` | True = marketplace purchase needs delivery driver |
| `requiresChemicalPermit` | True = only permitted vehicles can accept |
| `adminApprovalStatus` | Chemical orders need admin approval before appearing in driver feed |
| `linkedJobId` | On `collectionSale` — links back to parent `collection` job |
| `collectionDeliveryMethod` | `selfDelivery` or `assignRider` |
| `collectionTransactionType` | `donate` or `sell` |
| `isVatApplicable` / `vatAmountJd` | VAT logic (implemented) |
| `rewardBreakdown` | Detailed fee breakdown after completion |
| `invoices` | Line-item invoice data |
| `proof` / `proofImagePath` | Delivery proof photo |
| `fraudAttemptCount` | Incremented when driver tries to mark arrived > 200m away |

## Vehicle Constraints (`VehicleType`)

```dart
VehicleType.motorcycle  → max 10 kg, hard-bans: oil, batteries, electronics, rubber, tires, etc.
VehicleType.car         → max 50 kg, hard-bans: oil, tires, construction, furniture
VehicleType.pickup      → max 500 kg
VehicleType.van         → max 1000 kg
VehicleType.truck       → max 5000 kg
VehicleType.heavyTruck  → max 20000 kg
```

Chemicals require `hasChemicalPermit = true` on any vehicle ≥ pickup.

## Waste Types (16 total)

`paper, plastic, metal, glass, electronics, organic, textile, wood, rubber, oil, chemicals, batteries, furniture, tires, construction, copperAluminium`

All have Arabic `.label` extensions in `order_enums.dart`.

## Code Generation

Never edit `.freezed.dart` or `.g.dart`. After changing `order.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Related Pages

- [[concepts/app-order-store]]
- [[concepts/reward-service]]
- [[patterns/driver-order-flow]]
- [[patterns/supplier-order-flow]]
- [[patterns/collection-job-flow]]
