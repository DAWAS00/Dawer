# Dwaar — Pricing & Vehicle Matching Formula Plan
**Version:** 2.0  
**Date:** 2026-05-22  
**Status:** Decisions Locked — Ready for Implementation

---

## Decisions Log

| # | Question | Decision |
|---|---|---|
| 1 | VAT? | **Yes — 16% on B2B transactions** |
| 2 | Payout timing? | **Daily batch to drivers** |
| 3 | Copper/Aluminium separate WasteType? | **Yes — add as own enum value** |
| 4 | Chemicals listing? | **Admin approval required before listing goes live** |
| 5 | Furniture flat-fee flow? | **Phase 2 — out of scope for now** |
| 6 | Vehicle-based order filtering? | **Yes — drivers only see orders their vehicle can handle** |

---

## Overview

This document defines four systems:
1. **Driver fee formula** — what the driver earns per order
2. **Vehicle type system** — which orders each vehicle type can accept
3. **Marketplace listing price** — what a supplier charges for recyclables
4. **Platform commission + VAT** — what Dwaar keeps and what gets taxed

All amounts are in **Jordanian Dinar (JD)**.

---

## Part 1 — Vehicle Type System

### 1.1 Vehicle Type Enum

Replace the current free-text `driverVehicle` string field with a proper `VehicleType` enum.

```dart
enum VehicleType {
  motorcycle,   // دراجة نارية
  car,          // سيارة خاصة
  pickup,       // بيك آب
  van,          // فان / ونيت
  truck,        // شاحنة
  heavyTruck,   // شاحنة ثقيلة
}
```

---

### 1.2 Vehicle Capacity & Restrictions

| VehicleType | Arabic Label | Max Weight | Allowed Weight Categories | Restricted Waste Types |
|---|---|---|---|---|
| `motorcycle` | دراجة نارية | **10 kg** | `light` only | Banned: liquids, chemicals, batteries, electronics, construction, tires, furniture, oil |
| `car` | سيارة خاصة | **50 kg** | `light`, `medium` | Banned: chemicals, construction, tires, furniture, oil (bulk) |
| `pickup` | بيك آب | **500 kg** | `light`, `medium`, `heavy` | Banned: chemicals (requires permit), bulk liquids |
| `van` | فان / ونيت | **1,000 kg** | `light`, `medium`, `heavy` | Banned: chemicals (requires permit) |
| `truck` | شاحنة | **5,000 kg** | all categories | Chemicals allowed with admin-approved permit |
| `heavyTruck` | شاحنة ثقيلة | **20,000 kg** | all categories | No restrictions — all waste types allowed |

**Rule:** A driver sees an order in their feed **only if**:
1. `order.estimatedWeightKg <= vehicle.maxWeightKg`
2. All `order.wasteTypes` are in the vehicle's allowed list
3. If `order.requiresChemicalPermit == true`, driver must have `hasChemicalPermit == true`

---

### 1.3 Vehicle Class → Driver Base Fee

Larger vehicles have higher operating costs. The base fee scales with vehicle type:

| VehicleType | Base Fee (JD) | Distance Rate (JD/km) | Notes |
|---|---|---|---|
| `motorcycle` | 0.80 | 0.30 | Cheapest — light loads only |
| `car` | 1.20 | 0.45 | Mid-range |
| `pickup` | 1.50 | 0.60 | **Current default (keep as-is)** |
| `van` | 2.00 | 0.75 | Higher capacity |
| `truck` | 3.50 | 1.00 | Heavy fuel cost |
| `heavyTruck` | 5.00 | 1.20 | Maximum capacity |

---

### 1.4 Order Feed Filtering Logic

In `app_order_store.dart`, the `driverFeed` getter currently returns all pending orders. It must be filtered:

```dart
// Pseudocode
List<Order> get driverFeed {
  final vehicle = currentDriver.vehicleType;
  final maxWeight = vehicle.maxWeightKg;
  final allowedWasteTypes = vehicle.allowedWasteTypes;

  return _orders.where((o) {
    if (o.status != OrderStatus.pending) return false;
    if ((o.estimatedWeightKg ?? 0) > maxWeight) return false;
    if (o.wasteTypes.any((w) => !allowedWasteTypes.contains(w))) return false;
    if (o.requiresChemicalPermit == true && !currentDriver.hasChemicalPermit) return false;
    return true;
  }).toList();
}
```

**On the supplier side (post_to_market_sheet):** when a supplier posts a listing, the app should show a tag like "يناسب: بيك آب أو أكبر" (Suitable for: pickup or larger) based on weight and waste type — so suppliers know who can collect their listing.

---

### 1.5 Supabase Schema Changes for Vehicle Type

```sql
-- Add vehicle_type enum to Supabase
CREATE TYPE vehicle_type AS ENUM (
  'motorcycle', 'car', 'pickup', 'van', 'truck', 'heavyTruck'
);

-- Add to users table
ALTER TABLE users
  ADD COLUMN vehicle_type vehicle_type,
  ADD COLUMN has_chemical_permit BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN vehicle_capacity_kg INTEGER GENERATED ALWAYS AS (
    CASE vehicle_type
      WHEN 'motorcycle' THEN 10
      WHEN 'car'        THEN 50
      WHEN 'pickup'     THEN 500
      WHEN 'van'        THEN 1000
      WHEN 'truck'      THEN 5000
      WHEN 'heavyTruck' THEN 20000
      ELSE 0
    END
  ) STORED;

-- Add to orders table: which vehicle class is required
ALTER TABLE orders
  ADD COLUMN required_vehicle_type vehicle_type,
  ADD COLUMN requires_chemical_permit BOOLEAN NOT NULL DEFAULT false;
```

---

## Part 2 — Driver Fee Formula

### 2.1 Full Formula

```
grossFee = baseFee[vehicleType]
         + (distanceKm × distanceRate[vehicleType])
         + weightSurcharge[weightCategory]
         + (actualWeightKg × materialRate[primaryWasteType])
         + (isUrgent ? 0.50 : 0.00)

platformCut  = grossFee × 0.10
driverPayout = grossFee − platformCut

driverPayout = clamp(driverPayout, min=baseFee[vehicleType], max=50.00)
```

> Use `actualWeightKg` (recorded at delivery), not `estimatedWeightKg`.  
> If `actualWeightKg` is null (order not completed yet), use `estimatedWeightKg` for preview only.

---

### 2.2 Weight Surcharge Table (same for all vehicle types)

| WeightCategory | Range | Surcharge |
|---|---|---|
| `light` | 0 – 5 kg | +0.00 JD |
| `medium` | 5 – 20 kg | +1.50 JD |
| `heavy` | 20 – 100 kg | +4.00 JD |
| `veryHeavy` | 100 kg+ | +8.00 JD |

---

### 2.3 Material Rate Table (JD per kg)

| WasteType | Rate (JD/kg) |
|---|---|
| `electronics` | 0.10 |
| `chemicals` | 0.08 |
| `batteries` | 0.08 |
| `metal` | 0.07 |
| `copperAluminium` *(new)* | 0.15 |
| `oil` | 0.05 |
| `plastic` | 0.03 |
| `tires` | 0.03 |
| `paper` | 0.02 |
| `textile` | 0.02 |
| `wood` | 0.02 |
| `rubber` | 0.02 |
| `construction` | 0.02 |
| `glass` | 0.02 |
| `furniture` | 0.02 |
| `organic` | 0.01 |

---

### 2.4 Worked Examples

**Example A — Motorcycle, 3 kg paper, 2 km**
```
baseFee        = 0.80
distanceFee    = 2 × 0.30     = 0.60
weightSurcharge = light        = 0.00
materialBonus  = 3 × 0.02     = 0.06
grossFee       = 1.46 JD
platformCut    = 0.146 → 0.15 JD
driverPayout   = 1.31 JD  (clamped to min 0.80 — above min, ok)
```

**Example B — Pickup, 30 kg metal, 8 km, urgent**
```
baseFee        = 1.50
distanceFee    = 8 × 0.60     = 4.80
weightSurcharge = heavy        = 4.00
materialBonus  = 30 × 0.07    = 2.10
urgencyBonus   = 0.50
grossFee       = 12.90 JD
platformCut    = 1.29 JD
driverPayout   = 11.61 JD
```

**Example C — Truck, 800 kg construction waste, 15 km**
```
baseFee        = 3.50
distanceFee    = 15 × 1.00    = 15.00
weightSurcharge = veryHeavy   =  8.00
materialBonus  = 800 × 0.02   = 16.00
grossFee       = 42.50 JD
platformCut    =  4.25 JD
driverPayout   = 38.25 JD  (under 50 JD cap, ok)
```

---

### 2.5 Cancellation Compensation (Keep Existing Logic)

| Scenario | Driver Gets | Charged To |
|---|---|---|
| Supplier unavailable | `reward × 0.25`, clamp(0.50, 5.00) | `supplierHoldAmount` |
| Arrival timeout (5 min) | `reward × 0.50`, clamp(1.00, 10.00) | `supplierHoldAmount` |
| Ghost/no-show (15 min) | 0 JD | Driver forfeits |

---

### 2.6 Daily Batch Payout Flow

```
Every day at 02:00 AM Jordan time (UTC+3):
  For each driver with wallet balance > 0 AND no active holds:
    1. Sum all wallet_transactions.type='release' since last payout
    2. Deduct any pending holds
    3. Transfer net amount to driver's registered bank/eFAWATEERcom account
    4. Insert wallet_transaction(type='payout', amount=netAmount)
    5. Reset wallet balance to 0
    6. Send push notification: "تم تحويل X د.أ إلى حسابك"
```

Implemented as a Supabase Edge Function triggered by `pg_cron` at `'0 23 * * *'` (UTC, = 02:00 AM Amman).

---

## Part 3 — Marketplace Listing Price

### 3.1 Reference Market Rates (JD/kg)

Stored in `waste_rates` Supabase table — updatable by admin without app release.

| WasteType | `baseRate` JD/kg | Floor (×0.5) | Ceiling (×3.0) |
|---|---|---|---|
| `copperAluminium` *(new)* | 0.60 | 0.30 | 1.80 |
| `electronics` | 0.25 | 0.12 | 0.75 |
| `batteries` | 0.20 | 0.10 | 0.60 |
| `metal` (iron/steel) | 0.15 | 0.08 | 0.45 |
| `oil` | 0.10 | 0.05 | 0.30 |
| `plastic` | 0.08 | 0.04 | 0.24 |
| `rubber` | 0.05 | 0.02 | 0.15 |
| `tires` | 0.05 | 0.02 | 0.15 |
| `paper` | 0.04 | 0.02 | 0.12 |
| `textile` | 0.04 | 0.02 | 0.12 |
| `glass` | 0.03 | 0.01 | 0.09 |
| `wood` | 0.03 | 0.01 | 0.09 |
| `construction` | 0.02 | 0.01 | 0.06 |
| `organic` | 0.01 | 0.005 | 0.03 |
| `chemicals` | *admin-set* | — | — |

---

### 3.2 Listing Price Formula

```
suggestedPricePerKg = baseRate[primaryWasteType]
                    × qualityMultiplier[wasteForm]
                    × conditionMultiplier[conditionStars]

totalSuggestedPrice = suggestedPricePerKg × listingWeightKg

minAllowedTotal = baseRate × 0.5 × listingWeightKg
maxAllowedTotal = baseRate × 3.0 × listingWeightKg
```

#### Quality Multipliers

| WasteForm | Multiplier |
|---|---|
| `solid` (clean, sorted) | 1.00 |
| `liquid` | 0.90 |
| `gas` | 0.80 |
| `mixed` (unsorted) | 0.70 |

#### Condition Stars (supplier self-declares)

| Stars | Multiplier |
|---|---|
| 1 — ضعيف | 0.70 |
| 2 — مقبول | 0.85 |
| 3 — جيد | 1.00 |
| 4 — جيد جداً | 1.15 |
| 5 — ممتاز | 1.30 |

---

### 3.3 Marketplace Limits

| Constraint | Individual | Business |
|---|---|---|
| Min weight to list | **1 kg** | **10 kg** |
| Max weight per listing | **2,000 kg** | **10,000 kg** |
| Min listing price | 5 JD ✅ | 20 JD ✅ |
| Max listing price | `baseRate × 3.0 × weight` | `baseRate × 3.0 × weight` |
| Max active listings | **5** | **20** |
| Listing TTL (auto-expire) | **14 days** | **30 days** |
| Images required | 1 minimum ✅ | 1 minimum ✅ |
| Max images per listing | **5** | **5** |

---

### 3.4 Chemicals Listing — Admin Approval Flow

```
Supplier selects WasteType.chemicals →
  listing created with status = 'pendingAdminApproval'
  NOT visible in marketplace feed
  Admin receives notification in dashboard
  Admin reviews: approve / reject with reason
  If approved → status = 'pending' → visible in feed
  If rejected → supplier notified with reason → can resubmit
```

New `Order` field needed: `adminApprovalStatus` (enum: `notRequired`, `pending`, `approved`, `rejected`).

---

## Part 4 — Platform Commission + VAT

### 4.1 Transaction Breakdown on Completion

```
salePrice          = listingPrice set by supplier
platformFeeSupplier = salePrice × 0.05          (5% from supplier)
supplierReceives   = salePrice − platformFeeSupplier

grossDriverFee     = baseFee + distanceFee + weightSurcharge + materialBonus + urgencyBonus
platformFeeDriver  = grossDriverFee × 0.10      (10% from driver)
driverPayout       = grossDriverFee − platformFeeDriver

platformRevenue    = platformFeeSupplier + platformFeeDriver
```

---

### 4.2 VAT — 16% on B2B Transactions

VAT applies **only when both parties are registered businesses** (supplier_type = `storeBusiness` or `recyclingCo`).

```
isB2B = supplier.supplierType == storeBusiness || supplier.role == recyclingCo

if (isB2B):
  vatAmount     = salePrice × 0.16
  totalSupplierPays = salePrice + platformFeeSupplier + vatAmount
  vatInvoiceRequired = true
else:
  vatAmount = 0
  totalSupplierPays = salePrice + platformFeeSupplier
```

VAT is collected by Dwaar and remitted to Jordan's Income & Sales Tax Department.  
New `Order` field needed: `vatAmount`, `isVatApplicable`.  
New `transactions` column: `vat_amount_jd`.

---

### 4.3 Supplier Hold (Escrow on Order Acceptance)

```
supplierHoldAmount = salePrice
                   + platformFeeSupplier
                   + (isVatApplicable ? vatAmount : 0)
                   + 10.00 JD buffer  ← covers worst-case driver compensation
```

Release logic:
- **Order completed** → hold released, all parties paid per breakdown above
- **Supplier unavailable** → driver compensated from hold, remainder released to supplier
- **Timeout** → driver compensated, listing re-listed
- **Dispute raised** → hold frozen until admin resolves

---

### 4.4 Worked Example (B2B, Full Calculation)

**Scenario:** Business supplier sells 200 kg plastic (16 JD listing price) to recycling company. Pickup truck driver, 8 km.

```
── Supplier Side ──
salePrice              = 16.00 JD
platformFeeSupplier    = 16.00 × 0.05         =  0.80 JD
vatAmount              = 16.00 × 0.16         =  2.56 JD  (B2B)
supplierPays total     = 16.00 + 0.80 + 2.56  = 19.36 JD
supplierReceives       = 16.00 − 0.80         = 15.20 JD

── Driver Side (Pickup, 200 kg = veryHeavy, primary: plastic) ──
baseFee                = 1.50
distanceFee            = 8 × 0.60             =  4.80
weightSurcharge        = veryHeavy            =  8.00
materialBonus          = 200 × 0.03           =  6.00
grossDriverFee         = 20.30 JD
platformFeeDriver      = 20.30 × 0.10         =  2.03 JD
driverPayout           = 18.27 JD

── Dwaar Revenue ──
platformRevenue        = 0.80 + 2.03          =  2.83 JD
vatCollected           = 2.56 JD  (remitted to tax authority)
```

---

## Part 5 — Code Changes Required

### 5.1 New Enum Values in `order.dart`

```dart
// Add to WasteType enum:
WasteType.copperAluminium  // نحاس / ألومنيوم

// New enum:
enum VehicleType {
  motorcycle, car, pickup, van, truck, heavyTruck
}

// New enum:
enum AdminApprovalStatus {
  notRequired, pendingApproval, approved, rejected
}
```

### 5.2 New Fields in `Order` model

```dart
final VehicleType? requiredVehicleType;        // min vehicle to take this order
final bool requiresChemicalPermit;
final AdminApprovalStatus adminApprovalStatus;
final double? vatAmount;
final bool isVatApplicable;
```

### 5.3 New Fields in Driver profile (User model / Supabase `users` table)

```dart
final VehicleType vehicleType;      // replaces free-text driverVehicle
final bool hasChemicalPermit;
```

### 5.4 Updated `RewardBreakdown` model

```dart
final double baseFee;
final double distanceFee;
final double weightSurcharge;      // NEW
final double materialFee;
final double urgencyBonus;
final double grossFee;             // NEW (sum before commission)
final double platformCut;          // NEW (10%)
final double driverPayout;         // NEW (grossFee - platformCut)
final bool needsManualReview;
```

### 5.5 Files to Update

| File | Change |
|---|---|
| `lib/data/models/order.dart` | Add `VehicleType`, `AdminApprovalStatus` enums; add new Order fields |
| `lib/data/models/reward_breakdown.dart` | Add `weightSurcharge`, `grossFee`, `platformCut`, `driverPayout` |
| `lib/data/services/reward_service.dart` | Use `actualWeightKg`; add `weightSurcharge`; add `platformCut`; vehicle-based `baseFee`/`distanceRate` |
| `lib/data/services/app_order_store.dart` | Filter `driverFeed` by vehicle type + capacity; wire `supplierHoldAmount` escrow |
| `lib/ui/features/home/shared/widgets/post_to_market_sheet.dart` | Add min weight validation; add condition stars picker; show suggested price; chemicals → approval flow |
| `lib/ui/features/home/driver/tabs/driver_profile_tab.dart` | Replace free-text vehicle field with `VehicleType` dropdown |
| `supabase/migrations/` | Add `vehicle_type` enum; alter `users`; alter `orders`; create `waste_rates` table; add `vat_amount_jd` to `transactions` |
| `supabase/functions/` | Add `daily_payout` Edge Function (pg_cron at 02:00 AM Amman) |

---

## Part 6 — Vehicle Suitability Badge on Listings

When a listing is shown in the marketplace, display which vehicle types can collect it:

```
Order weight 30 kg, metal (no special permit):
  → motorcycle: ✗ (over 10 kg limit)
  → car: ✗ (over 50 kg limit... wait, 30 kg < 50 kg but metal is not banned for car)
  → Actually car max = 50 kg, 30 kg metal ok
  → pickup+: ✓

Badge shown: "يناسب: سيارة أو أكبر" (Suitable for: car or larger)
```

Formula:
```dart
VehicleType minRequiredVehicle(Order order) {
  for (final v in VehicleType.values) {
    if ((order.estimatedWeightKg ?? 0) <= v.maxWeightKg &&
        order.wasteTypes.every((w) => v.allowedWasteTypes.contains(w))) {
      return v;
    }
  }
  return VehicleType.heavyTruck; // fallback
}
```

Store result as `order.requiredVehicleType` — set on listing creation, used in feed filter.
