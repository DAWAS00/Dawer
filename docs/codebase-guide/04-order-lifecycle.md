# 4. Order Lifecycle

## The Order model

A single Freezed model represents all order-like concepts in the app:

```dart
// lib/data/models/order/order.dart
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required OrderType type,
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    required String dropoffAddress,
    required OrderStatus status,
    required double reward,
    required DateTime createdAt,
    // ... 80+ optional fields
  }) = _Order;
}
```

`OrderType` has three values:

```dart
enum OrderType { pickup, collection, collectionSale }
```

`OrderStatus` has seven values:

```dart
enum OrderStatus {
  pending,
  accepted,
  arrivedAtPickup,
  inTransit,
  arrivedAtDropoff,
  completed,
  cancelled,
}
```

## Central state: AppOrderStore

`AppOrderStore` is a root-level `ChangeNotifier` and the single source of truth for orders. It:

1. Seeds mock/local orders on first launch.
2. Subscribes to remote Supabase streams.
3. Exposes role-specific views.
4. Handles all order mutations.
5. Persists to `LocalStore` on every change.
6. Pushes remote writes asynchronously.

```dart
// lib/data/services/app_order_store.dart
class AppOrderStore extends ChangeNotifier {
  AppOrderStore({LocalStore? store, IOrderRepository? remote, ...}) {
    _bootstrap();
  }

  void _bootstrap() {
    // seed from LocalStore or mock data
    // subscribe to _remote.watchOrders() / watchOrdersForUser(...)
  }
}
```

## Status state machine

The database enforces a strict state machine:

```sql
-- supabase/migrations/00001_initial_schema.sql
CREATE OR REPLACE FUNCTION enforce_order_status_transition()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status IN ('completed', 'cancelled') THEN
    RAISE EXCEPTION 'Order % is terminal (%). No transitions allowed.', OLD.id, OLD.status;
  END IF;
  IF NOT (
    (OLD.status = 'pending'   AND NEW.status IN ('accepted', 'cancelled')) OR
    (OLD.status = 'accepted'  AND NEW.status IN ('inTransit', 'cancelled')) OR
    (OLD.status = 'inTransit' AND NEW.status IN ('completed', 'cancelled'))
  ) THEN
    RAISE EXCEPTION 'Invalid status transition: % -> %', OLD.status, NEW.status;
  END IF;
  ...
END;
$$;
```

Allowed transitions:

| From | To |
|---|---|
| `pending` | `accepted`, `cancelled` |
| `accepted` | `inTransit`, `cancelled` |
| `inTransit` | `completed`, `cancelled` |
| `completed` | — (terminal) |
| `cancelled` | — (terminal) |

Note: `arrivedAtPickup` and `arrivedAtDropoff` are **client-only statuses**. The DB does not know these states; the client uses them to show arrival UI before transitioning to `inTransit`.

## Pickup order flow

### 1. Supplier creates a pickup request

```dart
Order createPickupRequest({
  required List<WasteType> wasteTypes,
  required String supplierName,
  ...
}) {
  final order = Order(
    id: orderId,
    type: OrderType.pickup,
    wasteTypes: wasteTypes,
    status: OrderStatus.pending,
    reward: 0,
    ...
  );
  _orders.insert(0, order);
  notifyListeners();
  unawaited(_pushRemote(_remote.insertOrder(order)));
  return order;
}
```

If the waste type includes `chemicals`, `adminApprovalStatus` is set to `pendingApproval`.

### 2. Driver accepts

```dart
String? acceptOrder(String orderId, User driver) {
  ...
  _orders[idx] = order.copyWith(
    status: OrderStatus.accepted,
    acceptedAt: DateTime.now(),
    driverName: driver.name,
    ...
  );
  _activeOrderId = orderId;
  notifyListeners();

  unawaited(_pushRemote(_remote.markAccepted(orderId)));
  if (order.reward > 0) {
    unawaited(_wallet.holdForOrder(orderId, order.reward));
  }
}
```

The DB trigger `enforce_driver_single_active_order` prevents a driver from having more than one `accepted`/`inTransit` order.

### 3. Driver arrives at pickup

`markArrivedAtPickup` sets `arrivedAtPickup` status and starts the supplier response timer:

```dart
void markArrivedAtPickup(String orderId) {
  _orders[idx] = _orders[idx].copyWith(
    status: OrderStatus.arrivedAtPickup,
    arrivedAtPickupAt: DateTime.now(),
    arrivalConfirmationStatus: ArrivalConfirmationStatus.awaiting,
  );
  notifyListeners();
  unawaited(_pushRemote(_remote.markInTransit(orderId)));
}
```

The actual arrival is gated by the `verify_arrival` Edge Function (see [`05-tracking-and-proximity.md`](05-tracking-and-proximity.md)).

### 4. Supplier responds

| Supplier action | Result |
|---|---|
| Available | `handleSupplierAvailable` → `inTransit` |
| Not Available | `handleSupplierUnavailable` → `cancelled`, driver gets 25% compensation |
| Timeout (5 min) | `handleArrivalTimeout` → `cancelled`, driver gets 50% compensation |

### 5. Driver marks in-transit and dropoff arrival

- `markInTransit` → sets `inTransitAt`, starts dropoff tracking.
- `markArrivedAtDropoff` → sets `arrivedAtDropoffAt`.

### 6. Driver completes

```dart
void completeOrder(Order completedOrder) {
  _orders[idx] = completedOrder.copyWith(
    status: OrderStatus.completed,
    completedAt: DateTime.now(),
  );
  _driverCompletedIds.add(completedOrder.id);
  _activeOrderId = null;
  notifyListeners();

  unawaited(_pushRemote(_remote.markCompleted(...)));
  unawaited(_recordTransactionFor(completedOrder));
  if (completedOrder.reward > 0) {
    unawaited(_wallet.releaseForOrder(completedOrder.id, completedOrder.reward));
  }
}
```

On completion:
- Order status becomes terminal.
- `RewardService` computes the final breakdown.
- `record_order_transaction` RPC writes a row to `transactions`.
- Wallet hold is released to the driver's balance.
- Supplier earns points via `update_supplier_points_on_complete` trigger.

## Collection job flow

### 1. Company posts a collection job

```dart
Order createCollectionJob({
  required List<WasteType> wasteTypes,
  required String pickupAddress,
  required String companyName,
  ...
}) {
  final order = Order(
    id: jobId,
    type: OrderType.collection,
    status: OrderStatus.pending,
    ...
  );
}
```

### 2. Driver/supplier claims or commits

- `claimCollectionJob` — driver accepts the job directly.
- `createCollectionSale` — driver/supplier creates a linked `collectionSale` commitment.

### 3. Collection sale lifecycle

```dart
String? markCollectionSaleInTransit(String saleId) {
  // status must be accepted
  _orders[idx] = current.copyWith(
    status: OrderStatus.inTransit,
    inTransitAt: DateTime.now(),
  );
}

String? completeCollectionSale(String saleId, {double? actualWeightKg}) {
  // status must be inTransit
  _orders[idx] = current.copyWith(
    status: OrderStatus.completed,
    completedAt: DateTime.now(),
    weightKg: actualWeightKg ?? current.weightKg,
  );
}
```

Cancellation is only allowed before `inTransit`.

## Marketplace flow

A marketplace listing is a `pickup` order with `isMarketplaceShared = true`.

### Listing

Supplier creates a pickup request and marks it as marketplace-shared.

### Purchase/claim

- `claimMarketItem` — driver buys the material and picks it up.
- `purchaseMarketItem` — buyer requests delivery (`requiresRider = true`) or self-pickup.
- `receiveAtFacility` — recycling company receives the listing at its facility.

## Role-specific views from AppOrderStore

```dart
// Driver
List<Order> driverFeedFor({VehicleType? vehicleType, bool hasChemicalPermit = false});
Order? get driverActiveOrder;
List<Order> get driverHistory;

// Supplier
List<Order> supplierOrdersFor(String supplierName);

// Recycling Company
List<Order> get companyIncoming;
List<Order> get companyJobs;
List<Order> salesForCompanyJobs(String companyName);

// Marketplace
List<Order> get marketItems;
List<Order> pendingCollectionJobs;
List<Order> myCollectionJobs(String companyName);
```

## Vehicle matching

The driver feed filters orders by vehicle capacity and waste-type compatibility:

```dart
extension VehicleTypeCapacity on VehicleType {
  double get maxWeightKg => switch (this) {
    VehicleType.motorcycle => 10,
    VehicleType.car        => 50,
    VehicleType.pickup     => 500,
    VehicleType.van        => 1000,
    VehicleType.truck      => 5000,
    VehicleType.heavyTruck => 20000,
  };

  bool canTakeOrder(Order order, {bool hasChemicalPermit = false}) {
    final weightOk = (order.estimatedWeightKg ?? 0) <= maxWeightKg;
    final typesOk = order.wasteTypes.every(
      (w) => supportsWasteType(w, hasChemicalPermit: hasChemicalPermit),
    );
    final permitOk = !order.requiresChemicalPermit || hasChemicalPermit;
    return weightOk && typesOk && permitOk;
  }
}
```

## Remote persistence

All mutations call `_pushRemote`, which runs the repository operation and surfaces failures via `lastError`:

```dart
Future<void> _pushRemote(Future<AppResult<void>> op) async {
  final result = await op;
  result.fold(
    onSuccess: (_) {},
    onFailure: (failure) {
      _lastError = failure;
      notifyListeners();
    },
  );
}
```

## Files referenced

- `lib/data/models/order/order.dart` — Order model
- `lib/data/models/order/order_enums.dart` — enums and Arabic labels
- `lib/data/models/order_supabase_ext.dart` — Supabase serialization
- `lib/data/services/app_order_store.dart` — central store
- `lib/data/repositories/supabase_order_repository.dart` — remote order ops
- `lib/domain/repositories/i_order_repository.dart` — interface
- `supabase/migrations/00001_initial_schema.sql` — status trigger, RLS
