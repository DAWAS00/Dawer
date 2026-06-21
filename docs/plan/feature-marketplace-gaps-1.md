---
goal: Map the recycling-marketplace spec onto Dwaar — close the real gaps (FCM push, driver auto-matching, tracking hardening, proof-photo storage)
version: 2.0
date_created: 2026-06-12
last_updated: 2026-06-12
owner: Mohammad (DAWAS00)
status: 'Planned'
tags: [feature, tracking, notifications, matching, storage, roadmap]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

## Context

The provided "Recycling Marketplace App with Real-Time Rider Tracking" spec was written as a greenfield prompt. Dwaar already implements **most** of it. This plan is a gap analysis + phased implementation of only what's missing, reusing existing infrastructure instead of rebuilding.

**Already exists (do NOT rebuild):**

| Spec asks for | Dwaar already has |
|---|---|
| Background GPS streaming every 10m | `lib/data/services/location_publisher.dart` — upserts to `driver_locations` every 10m, Android `ForegroundNotificationConfig` |
| Real-time broadcast to customer | `lib/data/services/driver_location_stream.dart` — Realtime channel `driver-tracking-$orderId` |
| Live map with rider marker | `lib/ui/common/map/live_tracking_map_view.dart` (google_maps_flutter, auto-fit bounds) |
| Haversine / geofence | `lib/data/services/proximity_service.dart` (200m geofences) + `verify_arrival` edge function (server-side, anti-fraud) |
| Order lifecycle + timestamps | `OrderStatus` enum (7 states) + DB trigger `enforce_order_status_transition()` + `AppOrderStore` methods |
| File storage | `lib/data/repositories/supabase_file_storage_repository.dart` — buckets `profile-photos`, `user-documents`, signed URLs |
| Notifications table + types | `notifications` table, `notification_type` enum, `INotificationService` interface + mock impl |
| Rider matching primitives | `nearby_drivers()` SQL function, `users.location` GEOGRAPHY, `users.is_available` |
| FCM token storage | `users.fcm_token` column (unused) |
| Offline-capable local persistence | `LocalStore` (lib/backend_integration_locally/) — no Hive needed |

**Deliberate deviations from the spec** (Dwaar conventions win):
- Supabase Storage, **not** Google Cloud Storage — already wired, RLS-integrated, one vendor (see ALT-001).
- Provider MVVM, **not** flutter_bloc/get_it/injectable — codebase pattern (PAT-002).
- `AppResult<T>`/`AppFailure`, **not** dartz `Either` — existing Result type (PAT-001).
- `LocalStore`, **not** Hive — existing offline persistence.
- Phone-only auth is a **prerequisite tracked separately**: `PHONE_AUTH_PLAN.md` + vault plan `Projects/Dawer/Phone-Only Auth — Implementation Plan.md`. Not duplicated here.

## 1. Requirements & Constraints

- **REQ-001**: Order status changes (accepted, in transit, completed, cancelled) and driver assignment must produce push notifications via FCM, with in-foreground local notification fallback.
- **REQ-002**: When a pickup order is created, the system automatically finds the nearest available driver within 5 km (via existing `nearby_drivers()`), assigns, and notifies; if none, the order stays `pending` and the supplier sees a "searching" state.
- **REQ-003**: Driver location updates must survive intermittent connectivity: queue locally when offline, flush in order when back online.
- **REQ-004**: Tracking history is persisted append-only (`order_tracking` table) for route playback; old rows cleaned up by a scheduled job.
- **REQ-005**: Order completion uploads a proof photo to Supabase Storage and persists the existing `OrderProof` (imagePath, capturedAt, lat, lng, checksum) fields already on the Order model.
- **SEC-001**: RLS on all new tables; `order_tracking` readable only by the order's supplier/company/driver; FCM sends happen server-side (edge function with service role), never from the client.
- **CON-001**: FCM requires a Firebase project + `google-services.json` — user must create these in the Firebase console (USER ACTION, blocks Phase 1 device testing only; code can land first).
- **CON-002**: `flutter analyze` = 0 issues, `flutter test` fully green after each phase. Re-run `AppOrderStore` tests after any order-state change.
- **CON-003**: Do not edit generated files; Order model changes go through freezed source + build_runner.
- **GUD-001**: New user-facing strings via `.arb` keys (Arabic template) + `flutter gen-l10n`.
- **PAT-001**: Cross-layer returns use `AppResult<T>`; new services bind through `lib/domain/` interfaces in `main.dart` `MultiProvider`.
- **PAT-002**: Feature-scoped MVVM with Provider; ChangeNotifier VMs.

## 2. Implementation Steps

### Implementation Phase 1 — Push notifications (FCM)

- GOAL-001: Real push delivery for the notification types the schema already defines.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Add `firebase_core`, `firebase_messaging`, `flutter_local_notifications` to pubspec; run `flutterfire configure` (USER ACTION: Firebase project + google-services.json into `android/app/`). | | |
| TASK-002 | Create `lib/data/services/fcm_notification_service.dart` implementing `INotificationService` (`lib/domain/services/i_notification_service.dart`): init FCM, request permission, foreground messages → `flutter_local_notifications`, tap → navigate to order. Keep `MockNotificationService` as the test binding. | | |
| TASK-003 | Token registration: on login/session restore, write `FirebaseMessaging.instance.getToken()` to `users.fcm_token`; listen to `onTokenRefresh`. Hook into the auth flow after `verifyOtp` success. | | |
| TASK-004 | New edge function `supabase/functions/send_push/index.ts`: input `{recipientId, type, title, body, orderId}`; reads `users.fcm_token`, calls FCM HTTP v1 API (service-account secret in function env), inserts row into `notifications` table. | | |
| TASK-005 | DB webhook (or trigger → `pg_net`) on `orders` status changes invoking `send_push` for the mapped `notification_type` (orderAccepted, orderInTransit, orderCompleted, orderCancelledBy*). | | |
| TASK-006 | In-app notifications screen: VM + tab reading `notifications` table for current user (Realtime stream), mark-as-read. Wire `RiderProximityViewModel`'s existing `notifyProximity()` calls to the real service via the interface binding in `main.dart`. | | |

### Implementation Phase 2 — Driver auto-matching

- GOAL-002: Automatic nearest-driver assignment using existing primitives.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-007 | New edge function `supabase/functions/match_driver/index.ts`: input `{orderId}`; calls `nearby_drivers(pickup_point, 5000)` filtered by `is_available = true` and no active order (existing `enforce_driver_single_active_order` constraint as source of truth); picks nearest; sends push `newOrderAvailable` to that driver (no hard-assign — driver still accepts via existing flow). If none found: return `{matched: false}`. | | |
| TASK-008 | Invoke `match_driver` from `AppOrderStore` order-creation path after successful remote insert (fire-and-forget with logged failure). | | |
| TASK-009 | Driver online/offline toggle: `DriverHomeViewModel.toggleAvailability` currently flips a local flag only — persist to Supabase `users.is_available`. | | |
| TASK-010 | Supplier "searching for driver" state: in order details / new-pickup success UI, show pending-match state with retry; retry re-invokes `match_driver`. New `.arb` keys. | | |

### Implementation Phase 3 — Tracking hardening (history + offline queue)

- GOAL-003: Make existing live tracking production-grade.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-011 | Migration: `order_tracking` table (`id bigserial`, `order_id`, `driver_id`, `lat`, `lng`, `speed`, `accuracy`, `battery_level`, `recorded_at`) + RLS (driver inserts own; supplier/company of the order reads) + index on `order_id`. | | |
| TASK-012 | Extend `LocationPublisher`: each fix also inserts into `order_tracking`; include `speed`/`accuracy` from the geolocator `Position`; `battery_level` optional (skip if no cheap source). | | |
| TASK-013 | Offline queue in `LocationPublisher`: on write failure, append fix to a `LocalStore` queue; flush FIFO on next successful write. Unit-test queue logic following `MockProximityService` patterns. | | |
| TASK-014 | Cleanup job: scheduled edge function (or `pg_cron`) deleting `order_tracking` rows older than 30 days for completed/cancelled orders. | | |
| TASK-015 | Customer map polish in `LiveTrackingMapView`: animate marker between updates (lerp via `AnimationController`), straight-line polyline pickup→driver. Defer Google Directions/Distance Matrix (paid APIs); the stored `eta` field stays the ETA source for now. | | |

### Implementation Phase 4 — Proof-photo upload

- GOAL-004: Wire the already-modeled `OrderProof` into the completion flow.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-016 | Migration: private bucket `order-proofs` + RLS (driver writes `{orderId}/…`, order participants read via signed URL). | | |
| TASK-017 | Extend `SupabaseFileStorageRepository` with `uploadOrderProof({orderId, file})` → path `{orderId}/proof.<ext>`; reuse existing extension whitelist + signed-URL helper. | | |
| TASK-018 | Driver completion flow: before `completeOrder`, capture photo (`image_picker`, camera source), compute SHA256 (`crypto` already in pubspec), build `OrderProof`, upload, persist via existing `proof_*` columns (`order_supabase_ext.dart` already serializes them). Block completion if upload fails, with retry. | | |
| TASK-019 | Order details (supplier/company side): show proof photo via signed URL when present. | | |

### Implementation Phase 5 — Verification gate

- GOAL-005: Quality gates after each phase, full sweep at end.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-020 | `flutter analyze` (0 issues) + `flutter test` (all pass) per phase; new unit tests per §6. | | |
| TASK-021 | Manual emulator smoke per §6 TEST-006. | | |

**Deferred / out of scope** (from the spec, by decision):
- Admin dashboard → use Supabase Studio for now; revisit as Flutter-web app later.
- Google Distance Matrix ETA + Directions polyline → paid APIs, defer to production phase.
- GCS, Hive, bloc, get_it, dio adoption → rejected, see Alternatives.

## 3. Alternatives

- **ALT-001**: Google Cloud Storage per spec. Rejected — `SupabaseFileStorageRepository` + buckets + RLS already work; GCS adds a second vendor, in-app service-account key management, and no RLS integration.
- **ALT-002**: `flutter_background_service` for tracking. Rejected for now — geolocator's `ForegroundNotificationConfig` (already configured in `LocationPublisher`) covers Android foreground tracking; revisit only if iOS background gaps appear.
- **ALT-003**: Hard auto-assign driver on match. Rejected — push `newOrderAvailable` to nearest driver and let them accept, preserving the existing accept flow + ghost-timer/no-show logic.
- **ALT-004**: Hive/sqflite offline queue. Rejected — `LocalStore` JSON persistence already exists and is tested.
- **ALT-005**: Client-side FCM sends. Rejected — would ship server keys in the app; edge function with service role only (SEC-001).

## 4. Dependencies

- **DEP-001**: `firebase_core`, `firebase_messaging`, `flutter_local_notifications` (new).
- **DEP-002**: Firebase project + `google-services.json` (USER ACTION, CON-001).
- **DEP-003**: FCM HTTP v1 service-account JSON as Supabase function secret.
- **DEP-004**: Existing: geolocator, google_maps_flutter, image_picker, crypto, supabase_flutter — no version changes.
- **DEP-005**: Phone-only auth plan (separate doc) — independent; can land before or after Phase 1.

## 5. Files

- **FILE-001**: `pubspec.yaml`, `android/app/google-services.json`, gradle google-services plugin.
- **FILE-002 (new)**: `lib/data/services/fcm_notification_service.dart`.
- **FILE-003 (new)**: `supabase/functions/send_push/index.ts`, `supabase/functions/match_driver/index.ts`.
- **FILE-004 (new)**: migrations for `order_tracking`, `order-proofs` bucket, status-change webhook.
- **FILE-005**: `lib/data/services/location_publisher.dart` — history insert + offline queue.
- **FILE-006**: `lib/ui/common/map/live_tracking_map_view.dart` — marker animation + polyline.
- **FILE-007**: `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart` — availability persistence, proof capture before complete.
- **FILE-008**: `lib/data/repositories/supabase_file_storage_repository.dart` — `uploadOrderProof`.
- **FILE-009**: `lib/data/services/app_order_store.dart` — invoke match on create.
- **FILE-010 (new)**: notifications tab VM/UI under `lib/ui/features/home/shared/`.
- **FILE-011**: `main.dart` — bind `INotificationService` → FCM impl (mock stays for tests).

## 6. Testing

- **TEST-001**: Unit — offline queue in `LocationPublisher` (enqueue on failure, FIFO flush, no duplicates).
- **TEST-002**: Unit — proof flow: checksum computed, completion blocked on upload failure.
- **TEST-003**: Unit — notifications VM (stream → list, mark-read).
- **TEST-004**: Regression — full `AppOrderStore` suite after TASK-008/009 (order-state safety net per CLAUDE.md).
- **TEST-005**: `flutter analyze` 0 issues each phase.
- **TEST-006**: Manual smoke — two emulators (driver + supplier): create order → driver gets push → accept → live map moves → arrive/complete with photo → supplier sees proof + completion push; airplane-mode the driver mid-route → locations queue → reconnect → history backfills.

## 7. Risks & Assumptions

- **RISK-001**: FCM on emulators needs Google Play images; physical device recommended for push testing.
- **RISK-002**: `nearby_drivers()` exists in schema but its signature is unverified against current `users.location` data — verify in migrations before TASK-007.
- **RISK-003**: DB webhook → edge function (`pg_net`) availability depends on Supabase plan/extensions; fallback is invoking `send_push` from the client-side store mutation path (less reliable, acceptable interim).
- **ASSUMPTION-001**: `users.is_available` is the intended online/offline flag (currently only a local VM flag).
- **ASSUMPTION-002**: Supabase project is the one configured in `.env.local`; MCP Supabase tools available for migrations/functions.
- **ASSUMPTION-003**: Per vault rule, this plan gets copied to the Obsidian vault (`Projects/Dawer/`) on approval, before any code changes.

## 8. Related Specifications / Further Reading

- Phone-only auth (prerequisite, separate): `C:\Users\dawas\dwaar\PHONE_AUTH_PLAN.md` + vault `Projects/Dawer/Phone-Only Auth — Implementation Plan.md`
- Original greenfield spec: pasted prompt (2026-06-12 session)
- FCM HTTP v1: https://firebase.google.com/docs/cloud-messaging/migrate-v1
- Supabase DB webhooks: https://supabase.com/docs/guides/database/webhooks
- geolocator foreground service: https://pub.dev/packages/geolocator#android
