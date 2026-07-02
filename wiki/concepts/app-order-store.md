---
name: app-order-store
description: AppOrderStore — the central ChangeNotifier singleton managing all order state, persistence, and remote sync for all three user roles
metadata:
  type: concept
---

# AppOrderStore

`lib/data/services/app_order_store.dart`

The **single source of truth** for all orders. Provided at app root so Driver, Supplier, and Recycling Company VMs all watch the same list.

## Responsibilities

- Bootstraps orders from `LocalStore` on first mount (or seeds from `OrderMockData` on first launch)
- Subscribes to `SupabaseOrderRepository.watchOrdersForUser()` and merges updates
- Auto-persists on every `notifyListeners()` call (fire-and-forget, no UI blocking)
- Exposes role-scoped filtered views (driver feed, supplier orders, company jobs, marketplace)
- Handles all order state transitions as atomic mutations

## Filtered Views by Role

| Getter | Who Uses | Description |
|---|---|---|
| `driverFeedFor({vehicleType, hasChemicalPermit})` | Driver home tab | Pending orders the driver's vehicle can handle; filters out adminPending/rejected |
| `driverActiveOrder` | Driver home | The one order driver is currently working on |
| `driverHistory` | Driver orders tab | Completed orders (seeded: ORD-H01, ORD-H02) |
| `supplierOrdersFor(name)` | Supplier orders tab | Pickup orders for that supplier |
| `companyIncoming` | Recycling home tab | Active pickups heading to the company |
| `companyJobs` | Recycling home tab | All collection jobs posted by company |
| `marketItems` | Marketplace tab | Shared items, non-expired, non-admin-blocked |
| `pendingCollectionJobs` | Marketplace tab | Open collection jobs for marketplace display |

## Key Driver Actions

- `acceptOrder(orderId, driver)` → blocks if already has active order; validates vehicle capacity
- `markArrivedAtPickup(orderId)` → sets status + starts 5-min supplier response window
- `handleSupplierAvailable(orderId)` → advances to inTransit
- `handleSupplierUnavailable(orderId)` → cancels with 25% driver compensation
- `handleArrivalTimeout(orderId)` → cancels with 50% driver compensation
- `markArrivedAtDropoff(orderId)` → enters dropoff geofence
- `completeOrder(order)` → finalizes, triggers `RewardService.calculate()`, releases wallet hold
- `recordFraudAttempt(orderId)` → increments counter (no cancellation)

## Key Supplier Actions

- `createPickupRequest(...)` → creates pickup order; chemicals auto-set `adminApprovalStatus.pendingApproval`
- `submitPickupRequest(request)` → domain-layer wrapper returning `AppResult<Order>`
- `cancelOrder(orderId)` → only allowed if still pending
- `assignDriver(orderId, driver)` → supplier manually assigns a driver

## Key Company Actions

- `createCollectionJob(...)` → posts new job to marketplace
- `updateCollectionJob(...)` → edits in-place, sets `isEdited` flag
- `deleteCollectionJob(jobId, companyName)` → removes from list
- `claimCollectionJob(jobId, driver)` → driver accepts a company job
- `createCollectionSale(...)` → supplier/driver commits to sell waste to company
- `markCollectionSaleInTransit(saleId)` → accepted → inTransit
- `completeCollectionSale(saleId)` → inTransit → completed

## Marketplace Actions

- `addMarketListing(order)` → adds order with `isMarketplaceShared: true`
- `claimMarketItem(orderId, driver)` → driver claims; sets status accepted
- `purchaseMarketItem(...)` → buyer purchases; `requiresRider` if delivery needed
- `receiveAtFacility(orderId, address)` → company receives at facility

## Fee Calculation (Internal)

Delivery fee = base (2 JD) + weight surcharge (0–8 JD). See `FeeCalculator` for full formula.

## Error Handling

`_pushRemote()` catches all remote write failures and stores them in `_lastError`. UI widgets observe `lastError` and call `clearError()` after showing the toast/snackbar.

## Related Pages

- [[concepts/order-lifecycle]]
- [[concepts/reward-service]]
- [[concepts/app-architecture]]
- [[patterns/driver-order-flow]]
