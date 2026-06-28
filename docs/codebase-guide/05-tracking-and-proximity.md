# 5. Tracking and Proximity

## Overview

Dwaar implements a privacy-preserving, real-time driver tracking system. Location is shared only while an order is `inTransit`, only with the order participants, and is gated by server-side geofence verification.

## Components

| Component | File | Responsibility |
|---|---|---|
| `LocationPublisher` | `lib/data/services/location_publisher.dart` | Publishes driver GPS to Supabase every ~10 m |
| `DriverLocationStream` | `lib/data/services/driver_location_stream.dart` | Subscribes to Supabase Realtime for a given order |
| `ProximityService` | `lib/data/services/proximity_service.dart` | Client-side haversine geofence + fraud timers |
| `verify_arrival` | `supabase/functions/verify_arrival/index.ts` | Server-side authoritative geofence gate |
| `driver_locations` | `supabase/migrations/20260522_driver_locations.sql` | Live GPS table |

## Driver location publishing

`LocationPublisher` is a singleton that runs a foreground geolocator stream while a driver has an active order.

```dart
// lib/data/services/location_publisher.dart
class LocationPublisher implements ILocationPublisher {
  static final instance = LocationPublisher._();

  Future<void> start(String orderId) async {
    ...
    _sub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) => _upsert(pos, orderId));
  }

  Future<void> stop() async {
    await _sub?.cancel();
    await _deleteRow(_orderId!);
  }
}
```

Settings:

- Android foreground service notification: "دوّر — تتبع الموقع" / "جاري تتبع موقعك لإتمام الطلب"
- `distanceFilter: 10` meters
- `LocationAccuracy.high`

Each position is upserted to `driver_locations` keyed by `driver_id`:

```dart
await Supabase.instance.client.from('driver_locations').upsert({
  'driver_id': uid,
  'order_id': orderId,
  'lat': pos.latitude,
  'lng': pos.longitude,
  'updated_at': DateTime.now().toUtc().toIso8601String(),
});
```

On `stop()`, the row is deleted.

## Driver location table

```sql
-- supabase/migrations/20260522_driver_locations.sql
CREATE TABLE IF NOT EXISTS driver_locations (
  driver_id   uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  order_id    text NOT NULL,
  lat         double precision NOT NULL,
  lng         double precision NOT NULL,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

ALTER PUBLICATION supabase_realtime ADD TABLE driver_locations;
```

RLS:
- Drivers can upsert/delete their own row.
- All authenticated users can read (so the live map works for order participants).
- `service_role` bypasses RLS for `verify_arrival`.

## Subscribing to driver location

`DriverLocationStream` creates a Supabase Realtime channel for a specific order and emits `LatLng` updates. The consumer (supplier/company) sees the driver's live position on `google_maps_flutter`.

## Proximity service

`ProximityService` is a pure-Dart helper for client-side distance checks.

```dart
// lib/data/services/proximity_service.dart
class ProximityService {
  static const double pickupRadiusMeters = 200.0;
  static const double dropoffRadiusMeters = 200.0;
  static const double ghostTimeoutMinutes = 15.0;
  static const double arrivalResponseMinutes = 5.0;

  static double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    // haversine formula
  }

  static int minimumTravelSeconds(double distanceKm) =>
      (distanceKm / 30.0 * 3600).round();
}
```

### Constants

| Constant | Value | Meaning |
|---|---|---|
| `pickupRadiusMeters` | 200 m | Driver must be within this radius to mark arrived at pickup |
| `dropoffRadiusMeters` | 200 m | Driver must be within this radius to mark arrived at dropoff |
| `ghostTimeoutMinutes` | 15 min | If driver never reaches pickup geofence, order is auto-cancelled |
| `arrivalResponseMinutes` | 5 min | Time supplier has to respond after driver arrives |

## Server-side arrival verification

The `verify_arrival` Edge Function is the **authoritative** gate. The client calls it before marking arrival.

```typescript
// supabase/functions/verify_arrival/index.ts
const GEOFENCE_RADIUS_M = 200

serve(async (req) => {
  const { orderId, driverId, targetLat, targetLng } = await req.json()

  const { data: loc } = await supabase
    .from('driver_locations')
    .select('lat, lng, updated_at')
    .eq('driver_id', driverId)
    .eq('order_id', orderId)
    .single()

  const distanceMeters = haversineMeters(loc.lat, loc.lng, targetLat, targetLng)
  const allowed = distanceMeters <= GEOFENCE_RADIUS_M

  if (!allowed) {
    supabase.from('fraud_audit').insert({
      driver_id: driverId,
      order_id: orderId,
      event_type: 'proximity_block',
      distance_m: distanceMeters,
      ...
    })
  }

  return JSON.stringify({ allowed, distanceMeters: Math.round(distanceMeters) })
})
```

Key points:
- Uses **service role** to read `driver_locations` and write `fraud_audit`.
- Reads the **server's** copy of the driver's GPS, not the client-reported location.
- If no server GPS exists yet, returns `{ allowed: false, reason: 'no_server_gps' }` without logging fraud.

## Fraud signals

The fraud/audit system combines several signals:

| Signal | Trigger | Action |
|---|---|---|
| `proximity_block` | Driver marks arrived but `verify_arrival` says >200 m | Log to `fraud_audit`; increment `fraudAttemptCount` on order |
| `no_show` | Ghost timer expires before driver reaches pickup | Cancel order, no compensation |
| `fast_completion` | Completion time < `minimumTravelSeconds(distanceKm)` | Log suspicious event |
| `weight_variance` | Actual weight deviates >50% from estimate | Flag for manual review |

## Arrival confirmation flow

1. Driver enters 200 m pickup geofence (client-side `ProximityService`).
2. App calls `verify_arrival` Edge Function with server GPS.
3. If allowed, app calls `AppOrderStore.markArrivedAtPickup`.
4. Order status becomes `arrivedAtPickup`; supplier gets a notification.
5. 5-minute response timer starts.
6. Supplier taps **Available** → `inTransit`.
7. Supplier taps **Not Available** → `cancelled` with 25% driver compensation.
8. Timer expires → `cancelled` with 50% driver compensation.

## Privacy-by-design rules

- Location is published only when an order is `accepted` or `inTransit`.
- `driver_locations` row is deleted when the order completes or cancels.
- Only authenticated participants in the order can read the location stream (enforced by RLS + app filtering).
- `updated_at` lets the UI show a "freshness" chip so users know if the stream is stale.

## Files referenced

- `lib/data/services/location_publisher.dart`
- `lib/data/services/driver_location_stream.dart`
- `lib/data/services/proximity_service.dart`
- `lib/data/services/geolocator_proximity_service.dart`
- `lib/data/services/app_order_store.dart` — arrival actions
- `supabase/migrations/20260522_driver_locations.sql`
- `supabase/migrations/20260519_security_tables.sql`
- `supabase/functions/verify_arrival/index.ts`
