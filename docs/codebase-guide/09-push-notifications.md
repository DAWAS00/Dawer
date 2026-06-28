# 9. Push Notifications

## Overview

Push notifications use **Firebase Cloud Messaging (FCM)**. The architecture has two sides:

1. **Client side (Flutter)** — initializes FCM, requests permissions, registers the token with Supabase, and shows foreground notifications.
2. **Server side (Supabase Edge Functions)** — sends pushes triggered by DB webhooks, proximity events, or direct calls.

## Flutter client

`FcmNotificationService` handles the client side.

```dart
// lib/data/services/fcm_notification_service.dart
class FcmNotificationService implements INotificationService {
  Future<void> init() async {
    // Soft-fails if google-services.json is missing
    await Firebase.initializeApp();
    ...
  }
}
```

### What it does

1. Initializes Firebase (soft-fails if `google-services.json` is absent).
2. Requests notification permissions.
3. Listens to FCM token refresh and saves token to `users.fcm_token`.
4. Listens to incoming messages and shows foreground notifications via `flutter_local_notifications`.
5. Provides `notifyProximity()` to invoke the `send_push` Edge Function for proximity events.

### Token registration

On auth state change, the service updates the user's FCM token in Supabase:

```dart
Future<void> updateFcmToken(String? token) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null || token == null) return;
  await Supabase.instance.client
      .from('users')
      .update({'fcm_token': token})
      .eq('auth_id', user.id);
}
```

> **Production requirement:** A real Firebase project must be created and `google-services.json` / `GoogleService-Info.plist` must be added to Android/iOS projects.

## Server side: send_push

`send_push` is the central chokepoint for all outgoing notifications.

```typescript
// supabase/functions/send_push/index.ts
// Accepts three input shapes:
// 1. DB webhook: { type: 'UPDATE', table: 'orders', record, old_record }
// 2. Proximity event: { orderId, event: 'riderNearPickup' | 'riderNearDropoff' }
// 3. Direct dispatch: { recipientId, type, title, body, orderId? }
```

### Input shape 1: database webhook

The Postgres trigger `notify_order_status_change` calls `send_push` whenever an order status changes:

```sql
PERFORM net.http_post(
  url := 'https://bpzuwwbtqqrpohfqjcuo.supabase.co/functions/v1/send_push',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer ' || v_key
  ),
  body := jsonb_build_object(
    'type', 'UPDATE',
    'table', 'orders',
    'record', to_jsonb(NEW),
    'old_record', to_jsonb(OLD)
  )
);
```

`send_push` maps the status change to a dispatch:

| New status | Recipient | Notification type |
|---|---|---|
| `accepted` | supplier | `orderAccepted` |
| `inTransit` | supplier | `orderInTransit` |
| `completed` | supplier | `orderCompleted` |
| `cancelled` (by driver) | supplier | `orderCancelledByDriver` |
| `cancelled` (by supplier) | driver | `orderCancelledBySupplier` |

### Input shape 2: proximity event

From the app:

```dart
notifyProximity(orderId: orderId, event: 'riderNearPickup');
```

This sends a push-only notification (no inbox row because the event type is not in the `notification_type` enum).

### Input shape 3: direct dispatch

Used by `match_driver`:

```typescript
{
  recipientId: candidate.id,
  type: 'newOrderAvailable',
  title: 'طلب جديد بالقرب منك',
  body: `طلب استلام على بعد ${(candidate.distance_m / 1000).toFixed(1)} كم — اقبله الآن`,
  orderId
}
```

## Server side: match_driver

`match_driver` finds the nearest available driver within 5 km and notifies them.

```typescript
// supabase/functions/match_driver/index.ts
const MATCH_RADIUS_KM = 5

serve(async (req) => {
  const { orderId } = await req.json()

  // 1. Verify order is pending
  // 2. Get pickup coords via order_pickup_coords(orderId)
  // 3. Query nearby_drivers(lat, lng, radius_km)
  // 4. Exclude drivers already in active orders
  // 5. Insert in-app notification + send FCM push
})
```

Important: it does **not** auto-assign the order. The driver still accepts through the normal flow to preserve ghost-timer / no-show logic.

## FCM helper

`supabase/functions/_shared/fcm.ts` handles FCM HTTP v1:

1. Loads `FCM_SERVICE_ACCOUNT` secret (full Firebase service-account JSON).
2. Generates an OAuth2 access token using the service account's private key.
3. Sends POST to `https://fcm.googleapis.com/v1/projects/{project_id}/messages:send`.
4. Returns `false` (no throw) if FCM is not configured or token is invalid.

### Required secrets

```bash
supabase secrets set FCM_SERVICE_ACCOUNT="$(cat service-account.json)"
```

And for the status-change webhook:

```sql
SELECT vault.create_secret('<service-role-key>', 'service_role_key');
```

## Notification types (Postgres enum)

```sql
CREATE TYPE notification_type AS ENUM (
  'newOrderAvailable', 'orderAccepted', 'orderInTransit', 'orderCompleted',
  'orderCancelledBySupplier', 'orderCancelledByDriver',
  'collectionJobPosted', 'collectionJobAccepted',
  'collectionSaleInTransit', 'collectionSaleCompleted',
  'newIncomingShipment', 'pointsEarned'
);
```

> **Known inconsistency:** `daily_payout` inserts `type = 'payout'`, which is not in this enum.

## In-app notification inbox

Every dispatch (except proximity events) inserts a row into `public.notifications`. The UI can stream these per recipient:

```sql
SELECT * FROM public.notifications
WHERE recipient_id = current_user_id()
ORDER BY created_at DESC;
```

## Current gaps

- FCM client binding requires a real Firebase project.
- `google-services.json` is not present in the repo.
- `match_driver` is implemented but the app does not invoke it after order creation.
- `daily_payout` uses a notification `type` not in the enum.
- The hardcoded Edge Function URL in `20260612_push_and_matching.sql` should come from configuration.

## Files referenced

- `lib/data/services/fcm_notification_service.dart`
- `supabase/functions/send_push/index.ts`
- `supabase/functions/match_driver/index.ts`
- `supabase/functions/_shared/fcm.ts`
- `supabase/functions/daily_payout/index.ts`
- `supabase/migrations/20260612_push_and_matching.sql`
