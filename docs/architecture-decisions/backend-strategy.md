# ADR: Backend Strategy — Supabase Now, GCP-Native Later

**Status:** Accepted — 2026-06-20
**Branch:** `mohammad`
**Supersedes:** the implicit "three competing backends" state on this branch.

## Context

As of June 2026, the `mohammad` branch contained **three parallel, unreconciled
backend visions**, none of which was fully wired into the Flutter app:

1. **(A) Supabase** — `lib/data/repositories/supabase_*.dart` + `supabase/`
   (migrations + 2 edge functions). The most mature work in the repo:
   production-grade schema (RLS on all tables, PostGIS, state-machine triggers,
   `fraud_audit` ledger, `driver_wallet` with `SECURITY DEFINER` hold/release
   RPCs), and 4 real repositories (2 of which were the active binding at HEAD).
   **Recently deleted from the working tree** but recoverable from git
   history; was deleted as a side-effect of an abandoned Firebase/Cloud-Run
   "Phase 2" experiment, not because it was broken.

2. **(B) Python `backend/` microservices** — FastAPI services on GCP Cloud Run
   (auth, order, geo, notif, reward), Cloud SQL Postgres, GCS, Pub/Sub,
   Firestore mirror, **Firebase Phone Auth**. A deliberate, high-quality
   Supabase → GCP re-platform of the *same domain*. The Cloud SQL migrations
   are a literal port of the Supabase schema. **Uncommitted, untested, never
   deployed, and the Flutter client that talked to it was deleted the same
   day.** Nothing currently calls it.

3. **(C) AWS design doc** (`docs/system-design/Dwaar_System_Design.docx`) —
   prose + diagrams for a hybrid Supabase + AWS realtime tier (Aurora +
   ElastiCache Redis + DynamoDB + ECS WebSocket fleet). Excellent real-time
   pipeline theory, but **no code exists** and the doc *assumes* Supabase is
   already live (which it isn't on this branch).

The Flutter client at HEAD runs in a **hybrid/mock mode**: `AppOrderStore`
persists to `SharedPreferences`; auth/chat/wallet/notifications/earnings are
in-memory mocks or `NoOp` stubs. The only live network call is Google Gemini.

## Decision

### Primary backend: **Restore (A) Supabase** now.

- Re-add `supabase_flutter`, restore the `supabase/` directory (migrations +
  edge functions) and the 4 repositories from git history.
- Supabase Auth (**phone OTP** — matches `IAuthRepository` and the login/OTP
  UI), Postgres (system of record, PostGIS, RLS), Realtime (order status +
  driver position), Storage (proofs + profile photos).
- Re-wire `main.dart` `MultiProvider` to bind `Supabase*Repository`
  implementations. Keep `MockAuthRepository` / `NoOp*Repository` in the tree as
  **test doubles** and provide an env/flag toggle to flip back to them for
  offline dev and `flutter test`.

### Future re-platform: **(B) GCP-native, deferred behind a scale gate.**

- The Python `backend/` is **kept as a reference architecture**, committed to
  git but **not wired** into the Flutter app. It is the blueprint for the
  future swap: same schema (Cloud SQL migrations already port the Supabase
  schema), Firebase Phone Auth for identity, Cloud Run for Edge Functions, GCS
  for Storage, Firestore mirror for realtime.
- The client swap stays a config change in `main.dart` `MultiProvider`
  because all backend access goes through `lib/domain/` interfaces.

### Realtime pipeline: **Supabase Realtime now**; heavy tier deferred.

- Order status + driver position via Supabase Realtime broadcast on the
  `orders` and `driver_locations` tables (the latter is already in the
  `supabase_realtime` publication).
- Server-side geofence "arrived" via the restored `verify_arrival` Edge
  Function (200m haversine, service-role-authoritative, fraud audit).
- Movement-threshold publishing (~200m / 15s) to limit Postgres/Realtime load.
- The AWS design doc's Redis `GEOSEARCH` geo index + WebSocket/ECS tracking
  fleet + DynamoDB ping history is **not built now**. It is pulled off the
  shelf only when real usage data shows Supabase Realtime/PostGIS straining
  (ping write rate, fan-out latency, or cost). For a Jordan recycling app at
  MVP/Growth scale this is likely years away.

## Why this and not the alternatives

- **Why not full AWS-native (C) now?** Nothing exists — schema, auth, services,
  infra all greenfield. Highest cost, highest ops burden, longest time to a
  live multi-user backend. The 5,000 concurrent drivers / 1–3k writes/s targets
  in the doc are Uber-scale and speculative for this product.
- **Why not GCP-native (B) now?** The scaffold is good but uncommitted,
  untested, never deployed, `admin_svc` missing, broken duplicate Dockerfiles,
  and the Flutter client integration was just deleted. Completing it is weeks
  of work vs. days to restore Supabase.
- **Why Supabase (A)?** The schema is the single most production-ready artifact
  in the repo, the repos are real, 2 were already wired, and the domain
  interfaces already provide the seam for a future swap. Fastest path to a
  live backend with the cleanest future migration path.

## Consequences

- **Positive:** live multi-user backend in days; auth/RLS/storage/realtime
  handled by managed platform; future GCP swap remains a config change.
- **Negative:** carries Supabase's scaling ceiling for realtime geo. Acceptable
  at MVP/Growth scale; revisit at the Phase 6 scale gate.
- **Risk:** the live Supabase project (`bbpleeddaquwwvexzmdc` in `.env.local`)
  must be verified to have the migrations applied before the restored Dart
  (which assumes columns/functions exist) will work at runtime.

## Auth model

**Phone OTP only** (matches `IAuthRepository.signUp/requestOtp/verifyOtp` and
the login/verification UI). The deleted `SupabaseAuthService` (email/password
with a phone→email RPC lookup) caused the documented "auth methods mismatched"
issue and is **not restored** as an `IAuthRepository` binding. If email/password
is later needed (e.g. admin web), it is a separate, additive path.

## Not restored

- `secure_token_store.dart`, `cloud_run_client.dart`,
  `firestore_order_listener.dart` — dead code from the abandoned Firebase
  direction. Restoring re-adds unused `firebase_auth` / `cloud_firestore` /
  `dio` dependencies.
- `supabase_auth_service.dart` (email/password) — see Auth model above.
- `match_driver/index.ts`, `send_push/index.ts`, `_shared/fcm.ts` — referenced
  in `AGENTS.md` but **never existed** in the repo. They are new work whenever
  dispatch matching and FCM push are tackled (likely Phase 4+).

## Known gaps to fill after the restore (Phase 4)

The design doc and restored schema do **not** cover features already in the
client: marketplace/collection-sale flow, chat (no `chat_messages` table),
wallet/commission detail, push notifications (`flutter_local_notifications`
declared but never initialized; FCM not configured), and AI features (the doc
omits them entirely). These are tracked as follow-up work, not blockers.

## Reference

- Audit evidence: `git log -- supabase/`, `git show HEAD:lib/main.dart`,
  `git show HEAD:lib/data/repositories/supabase_*.dart`.
- North-star realtime design: `docs/system-design/Dwaar_System_Design.docx`.
- GCP re-platform blueprint: `backend/`, `cloud-sql/migrations/`,
  `api/openapi.yaml`.
