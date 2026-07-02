# 6. Wallet and Pricing

## Pricing engine: RewardService

`RewardService` is the client-side pricing engine. It computes the driver's payout for a trip.

```dart
// lib/data/services/reward_service.dart
class RewardService {
  static const double _urgencyBonus = 0.50;
  static const double _platformCutRate = 0.10;
  static const double _maxPayout = 50.0;

  static const Map<VehicleType, double> _baseFees = {
    VehicleType.motorcycle: 0.80,
    VehicleType.car:        1.20,
    VehicleType.pickup:     1.50,
    VehicleType.van:        2.00,
    VehicleType.truck:      3.50,
    VehicleType.heavyTruck: 5.00,
  };

  static const Map<VehicleType, double> _distanceRates = {
    VehicleType.motorcycle: 0.30,
    VehicleType.car:        0.45,
    VehicleType.pickup:     0.60,
    VehicleType.van:        0.75,
    VehicleType.truck:      1.00,
    VehicleType.heavyTruck: 1.20,
  };

  static const Map<WasteType, double> _materialRates = {
    WasteType.copperAluminium: 0.15,
    WasteType.electronics:     0.10,
    WasteType.chemicals:       0.08,
    ...
  };
}
```

### Formula

```
baseFee       = vehicle-based (0.80–5.00 JD)
distanceFee   = distanceKm * vehicle rate
weightSurch   = weightSurchargeFor(kg)
materialFee   = kg * materialRate
urgency       = 0.50 JD if isUrgent
grossFee      = baseFee + distanceFee + weightSurch + materialFee + urgency
platformCut   = grossFee * 10%
driverPayout  = (grossFee - platformCut).clamp(baseFee, 50.0 JD)
```

### Weight surcharge tiers

```dart
static double weightSurchargeFor(double weightKg) {
  if (weightKg < 5) return 0.0;
  if (weightKg < 20) return 1.5;
  if (weightKg < 100) return 4.0;
  return 8.0;
}
```

### Manual review triggers

```dart
final weightVariance = actualWeightKg != null &&
    hasWeightVariance(estimatedWeightKg, actualWeightKg);
final needsManualReview = rate == null || weightVariance;
```

The order is flagged for manual review if the waste type has no material rate or if actual weight varies >50% from estimate.

## RewardBreakdown model

```dart
// lib/data/models/reward_breakdown.dart
class RewardBreakdown {
  final double baseFee;
  final double distanceFee;
  final double weightSurcharge;
  final double materialFee;
  final double urgencyBonus;
  final double grossFee;
  final double platformCut;
  final double driverPayout;
  final double totalJd;
  final bool needsManualReview;
}
```

## Wallet schema

### driver_wallet

```sql
-- supabase/migrations/20260519_security_tables.sql
CREATE TABLE IF NOT EXISTS driver_wallet (
  driver_id    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  balance      numeric(10,2) NOT NULL DEFAULT 0.00,
  held_amount  numeric(10,2) NOT NULL DEFAULT 0.00,
  updated_at   timestamptz NOT NULL DEFAULT now()
);
```

- `balance` — spendable earnings.
- `held_amount` — escrow reserved for active orders.

### wallet_transactions

```sql
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id   uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  order_id    text,
  type        text NOT NULL
    CHECK (type IN ('hold','release','partial_release','refund','penalty')),
  amount      numeric(10,2) NOT NULL,
  note        text,
  created_at  timestamptz NOT NULL DEFAULT now()
);
```

RLS restricts writes to `service_role` / SECURITY DEFINER functions.

## Hold and release RPCs

### driver_wallet_hold

Called when driver accepts an order:

```sql
CREATE OR REPLACE FUNCTION driver_wallet_hold(
  p_order_id text,
  p_amount   numeric
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_driver_id uuid := auth.uid();
BEGIN
  INSERT INTO driver_wallet (driver_id) VALUES (v_driver_id)
  ON CONFLICT (driver_id) DO NOTHING;

  UPDATE driver_wallet
  SET held_amount = held_amount + p_amount,
      updated_at  = now()
  WHERE driver_id = v_driver_id;

  INSERT INTO wallet_transactions (driver_id, order_id, type, amount, note)
  VALUES (v_driver_id, p_order_id, 'hold', p_amount, 'قبول الطلب');
END;
$$;
```

### driver_wallet_release

Called when driver completes an order:

```sql
CREATE OR REPLACE FUNCTION driver_wallet_release(
  p_order_id text,
  p_amount   numeric
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_driver_id uuid := auth.uid();
BEGIN
  UPDATE driver_wallet
  SET held_amount = GREATEST(0, held_amount - p_amount),
      balance     = balance + p_amount,
      updated_at  = now()
  WHERE driver_id = v_driver_id;

  INSERT INTO wallet_transactions (driver_id, order_id, type, amount, note)
  VALUES (v_driver_id, p_order_id, 'release', p_amount, 'إتمام الطلب');
END;
$$;
```

## Flutter wallet integration

`AppOrderStore` calls hold/release on accept/complete:

```dart
String? acceptOrder(String orderId, User driver) {
  ...
  unawaited(_pushRemote(_remote.markAccepted(orderId)));
  if (order.reward > 0) {
    unawaited(_wallet.holdForOrder(orderId, order.reward));
  }
}

void completeOrder(Order completedOrder) {
  ...
  unawaited(_wallet.releaseForOrder(completedOrder.id, completedOrder.reward));
}
```

`SupabaseWalletRepository` maps these to the RPCs:

```dart
// lib/data/repositories/supabase_wallet_repository.dart
Future<AppResult<void>> holdForOrder(String orderId, double amount) async {
  return _run(() => _client.rpc('driver_wallet_hold', params: {
    'p_order_id': orderId,
    'p_amount': amount,
  }));
}
```

> **Note:** `AppOrderStore` defaults to `NoOpWalletRepository` if no wallet repository is injected. The production wiring must pass `SupabaseWalletRepository`.

## Cancellation compensation

When a supplier cancels after the driver has arrived or the response timer expires, the driver receives compensation from the supplier's hold:

| Scenario | Compensation | Wallet transaction type |
|---|---|---|
| Supplier unavailable | 25% of reward, clamped 0.5–5.0 JD | `penalty` |
| Arrival timeout | 50% of reward, clamped 1.0–10.0 JD | `penalty` |

The compensation is auto-credited by the trigger `auto_credit_driver_compensation`.

```sql
CREATE OR REPLACE FUNCTION auto_credit_driver_compensation()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'cancelled' AND NEW.driver_compensation_amount IS NOT NULL THEN
    -- map public.users.id → auth.users.id
    -- release hold, add compensation to balance, insert 'penalty' transaction
  END IF;
  RETURN NEW;
END;
$$;
```

## Daily payout

The `daily_payout` Edge Function settles driver balances once per day.

```typescript
// supabase/functions/daily_payout/index.ts
const { data: wallets } = await supabase
  .from('driver_wallet')
  .select('driver_id, balance')
  .gt('balance', 0)
  .eq('held_amount', 0)

for (const wallet of wallets) {
  await supabase.from('wallet_transactions').insert({
    driver_id,
    type: 'payout',
    amount: balance,
    note: `Daily payout — ${new Date().toISOString().slice(0, 10)}`,
  });
  await supabase.from('driver_wallet')
    .update({ balance: 0 })
    .eq('driver_id', driver_id);
}
```

It is intended to run via `pg_cron` at 23:00 UTC / 02:00 Amman.

> **Known inconsistency:** `daily_payout` inserts `type = 'payout'`, but the DDL constraint in `20260519_security_tables.sql` only allows `('hold','release','partial_release','refund','penalty')`.

## Transaction recording

After completion, `AppOrderStore` records the full pricing breakdown via `record_order_transaction` RPC:

```dart
Future<void> _recordTransactionFor(Order order) async {
  final result = await _rewardService.calculate(...);
  result.fold(
    onSuccess: (breakdown) => unawaited(_pushRemote(_remote.recordTransaction(
      orderId: order.id,
      breakdown: breakdown,
      vehicleType: order.requiredVehicleType?.name,
    ))),
    onFailure: (_) {},
  );
}
```

The RPC writes to `transactions` with the fee breakdown.

## VAT and admin approval

The schema supports VAT and chemical-material admin approval:

```sql
-- added by 20260522_vehicle_type.sql and related migrations
ALTER TABLE orders ADD COLUMN required_vehicle_type vehicle_type;
ALTER TABLE orders ADD COLUMN requires_chemical_permit boolean DEFAULT false;
ALTER TABLE orders ADD COLUMN admin_approval_status text;
ALTER TABLE orders ADD COLUMN is_vat_applicable boolean DEFAULT false;
ALTER TABLE orders ADD COLUMN vat_amount_jd numeric;
```

When a supplier creates a pickup request containing `chemicals`, `adminApprovalStatus` is set to `pendingApproval` and the order is hidden from drivers until approved.

## Files referenced

- `lib/data/services/reward_service.dart`
- `lib/data/models/reward_breakdown.dart`
- `lib/data/repositories/supabase_wallet_repository.dart`
- `lib/data/services/app_order_store.dart`
- `supabase/migrations/20260519_security_tables.sql`
- `supabase/migrations/20260522_wallet_functions.sql`
- `supabase/migrations/20260522_vehicle_type.sql`
- `supabase/functions/daily_payout/index.ts`
