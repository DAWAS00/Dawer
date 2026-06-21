---
name: reward-service
description: RewardService — driver payout calculation formula, material rates, vehicle base fees, platform cut, and RewardBreakdown model
metadata:
  type: concept
---

# RewardService

`lib/data/services/reward_service.dart`

Calculates driver payout after order completion. Called by `AppOrderStore.completeOrder()`.

## Formula

```
grossFee = baseFee + distanceFee + weightSurcharge + materialFee + urgencyBonus
platformCut = grossFee × 10%
driverPayout = clamp(grossFee - platformCut, baseFee, 50 JD)
```

## Vehicle Base Fees (JD)

| Vehicle | Base Fee | Distance Rate (JD/km) |
|---|---|---|
| Motorcycle | 0.80 | 0.30 |
| Car | 1.20 | 0.45 |
| Pickup | 1.50 | 0.60 |
| Van | 2.00 | 0.75 |
| Truck | 3.50 | 1.00 |
| Heavy Truck | 5.00 | 1.20 |

## Weight Surcharge

| Weight | Surcharge |
|---|---|
| < 5 kg | 0 JD |
| 5–20 kg | 1.5 JD |
| 20–100 kg | 4.0 JD |
| ≥ 100 kg | 8.0 JD |

## Material Rates (JD/kg — by primary waste type)

| Waste | Rate |
|---|---|
| Copper/Aluminium | 0.15 |
| Electronics | 0.10 |
| Chemicals / Batteries | 0.08 |
| Metal | 0.07 |
| Oil | 0.05 |
| Plastic / Tires | 0.03 |
| Paper / Textile / Wood / Rubber / Construction / Glass / Furniture | 0.02 |
| Organic | 0.01 |

## Manual Review Triggers

`needsManualReview = true` when:
- Primary waste type has no rate entry
- Actual weight varies >50% from estimated (`hasWeightVariance`)

## FeeCalculator (Delivery Fee — Supplier-Facing)

`lib/data/services/fee_calculator.dart`

Separate from reward — this is what the **supplier pays**:
```
deliveryFee = 2.0 (base) + weightSurcharge + (distanceKm × 0.20)
```

`AppOrderStore._calculateFee()` uses only the weight surcharge (no distance at creation time since route isn't calculated yet).

## VAT

`Order.isVatApplicable` + `Order.vatAmountJd` — fields exist, logic is implemented at creation time. VAT is stored on the order, not dynamically computed on display.

## Related Pages

- [[concepts/order-lifecycle]]
- [[concepts/app-order-store]]
- [[products/supabase]]
