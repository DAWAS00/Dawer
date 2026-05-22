# Implementation Report: Pricing and Vehicle Matching Formula

**Date:** 2026-05-22
**Context:** Dawer Project
**Status:** Implemented

## Overview

This document details the technical implementation of the Pricing and Vehicle Matching Formula (Task 1). The logic establishes the pricing structures for driver payouts, vehicle-specific load capabilities, and platform fee calculations without relying on external Supabase Edge Functions.

## 1. Vehicle Type System

A rigorous vehicle type system was introduced to control which drivers can see and accept specific orders.

### 1.1 The `VehicleType` Enum

We defined a `VehicleType` enum within `lib/data/models/order.dart` replacing the free-text `driverVehicle` approach. 

```dart
enum VehicleType {
  motorcycle,
  car,
  pickup,
  van,
  truck,
  heavyTruck,
}
```

### 1.2 Feed Filtering Logic

In `lib/data/services/app_order_store.dart`, the driver feed is dynamically filtered based on the current driver's vehicle capacity. An order is visible only if:
1. `order.estimatedWeightKg` <= `vehicle.maxWeightKg`
2. `order.wasteTypes` falls within the vehicle's allowed capabilities.

**Note:** For listings, we implemented a badge logic `minRequiredVehicle(Order order)` that analyzes the load to inform suppliers what size of vehicle will be required for collection (e.g., "يناسب: بيك آب أو أكبر").

## 2. Driver Fee Formula

The `RewardService` (`lib/data/services/reward_service.dart`) was entirely rewritten to operate locally, dropping the Supabase Edge Function call. It now encapsulates the exact fee formulas defined in the requirements.

### 2.1 Payout Calculation

The formula applied is:
```text
grossFee = baseFee[vehicleType] 
         + (distanceKm × distanceRate[vehicleType]) 
         + weightSurcharge[weightCategory] 
         + (actualWeightKg × materialRate[primaryWasteType]) 
         + urgencyBonus
```

**Constants Implemented:**
- `_platformCutRate`: 10%
- `_maxPayout`: 50 JD
- `_urgencyBonus`: 0.50 JD

### 2.2 Surcharges & Modifiers

- **Weight Surcharge:**
  - 0–4 kg: 0.0 JD
  - 5–19 kg: 1.5 JD
  - 20–99 kg: 4.0 JD
  - 100+ kg: 8.0 JD
- **Material Rate Table:** Integrated specific multipliers per kg for all values (e.g., Copper/Aluminium at `0.15`, Plastics at `0.03`, Organics at `0.01`).

### 2.3 Reward Breakdown Updates

The `RewardBreakdown` model (`lib/data/models/reward_breakdown.dart`) was expanded to hold the full transparency of the transaction:
- `weightSurcharge`
- `grossFee`
- `platformCut`
- `driverPayout`

## 3. UI and State Updates

- **Supplier Tabs / Sheets:** Updated `post_to_market_sheet` and `supplier_order_card` to show the correct limits, Condition Stars (1-5), and required vehicles. 
- **Driver Profile:** Free-text vehicle input updated to an enum dropdown.
- **Order Details:** Added UI elements to show the completed pricing breakdown to the driver.

## Summary

The entire fee and vehicle matching logic is now fully integrated into the Dart domain and data layers. The system dynamically clamps maximum driver payouts to 50 JD while ensuring a base payout corresponding to the vehicle type. Platform cuts (10%) are automatically segregated in the math.