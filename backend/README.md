# `backend/` — GCP-native reference architecture (NOT WIRED)

> **Status: REFERENCE ONLY.** This Python backend is **not wired into the
> Flutter app** and is not deployed. It is preserved as the blueprint for a
> future Supabase → GCP re-platform. See
> [`docs/architecture-decisions/backend-strategy.md`](../docs/architecture-decisions/backend-strategy.md)
> for the decision and rationale.

## What this is

A clean, idiomatic **Supabase → GCP re-platform** of the Dwaar backend, built
on **2026-06-19** as a single focused pass. It models the **exact same domain**
(users, drivers, suppliers, recyclingCo, orders, waste types, transactions,
notifications) as the Supabase schema — the Cloud SQL migrations are a literal
port of `supabase/migrations/`, with Supabase-specific bits stripped because
enforcement moved into Cloud Run.

## Stack

| Layer | Technology |
| --- | --- |
| Services | FastAPI 0.115 + Pydantic 2 + asyncpg (5 services) |
| Hosting | Google Cloud Run, region `me-west1`, project `dawer-prod` |
| Database | Cloud SQL Postgres + PostGIS (Cloud SQL Connector, private IP) |
| Identity | **Firebase Phone Auth** (services verify Firebase-issued JWTs) |
| Files | Google Cloud Storage (signed PUT URLs) |
| Events | Cloud Pub/Sub (order status changes) |
| Realtime | Firestore order-status mirror (intended for client live updates) |
| CI/CD | Cloud Build → Artifact Registry → Cloud Run (`cloudbuild.yaml`) |

## Services

| Service | Routes | Notes |
| --- | --- | --- |
| `auth_svc` | `/users/profile`, `/users/me`, `/users/me/fcm-token`, `/users/me/availability` | Role-gated; real parameterized SQL |
| `order_svc` | `/orders` (CRUD), `/orders/{id}/status`, `/orders/{id}/proof-photo` | State machine (409 server-wins), PostGIS insert, GCS signed URLs, Pub/Sub publish |
| `geo_svc` | `/drivers/nearby` | Calls `nearby_drivers(lat, lng, radius)` SQL function (PostGIS `ST_DWithin`) |
| `notif_svc` | `/pubsub/push`, `/health` | Pub/Sub push → FCM, stale-token cleanup |
| `reward_svc` | `/rewards/calculate` | Stateless: 16 material rates, distance/weight/urgency + 16% VAT |

## Why it's not wired

- **Uncommitted** (was untracked until the ADR decision to commit it).
- **Untested** — no pytest suite, no CI test step in `cloudbuild.yaml`.
- **Never deployed** — Cloud Build pipeline exists but was never run.
- The Flutter client that consumed it (`cloud_run_client.dart`,
  `firestore_order_listener.dart`, `secure_token_store.dart`) was **deleted**
  from the working tree the same day this backend was written.
- `admin_svc` (`/admin/orders`, `/admin/users/{id}/verify`,
  `/admin/transactions`) is specified in `api/openapi.yaml` but has **no
  implementation**.
- Duplicate broken `services/*/Dockerfile` set (uses `COPY ../../`, illegal in
  Docker); the working set is `dockerfiles/*.Dockerfile`.

## When to pick this up

Per the backend-strategy ADR, this is the **blueprint for the Phase 6 scale
gate** or any deliberate move to GCP. The client swap is a `MultiProvider`
config change in `main.dart` because all backend access goes through
`lib/domain/` interfaces. To activate:

1. Commit + test it (add pytest, fix the duplicate Dockerfiles, enforce the
   Pub/Sub push token, implement `admin_svc`).
2. Deploy via `cloudbuild.yaml` to the `dawer-prod` GCP project.
3. Write Cloud Run-backed implementations of `IAuthRepository`,
   `IOrderRepository`, `IWalletRepository`, `IFileStorageRepository`.
4. Swap the bindings in `main.dart`.

## Related

- `cloud-sql/migrations/` — the schema port (read `001_initial_schema.sql`
  header comment).
- `api/openapi.yaml` — the full API contract.
- `../supabase/migrations/` — the original schema this was ported from.
