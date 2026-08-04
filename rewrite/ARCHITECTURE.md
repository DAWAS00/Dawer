# Rewrite Architecture Plan — **Ghuson (غصن)**

**Date:** 2026-07-11 · **Identity updated:** 2026-07-25 · **Status:** Proposed · **Supersedes:** the legacy Dawer/Dwaar codebase (reference only)
**Shared contract:** [FigJam board — Flutter App + Admin Dashboard on One Supabase](https://www.figma.com/board/FuwRum13uGgAIb83tzzGr0/) (updated 2026-07-11)
**Brand:** Ghuson · غصن · "The Operating System for the Circular Economy" · `ghuson.io` — tokens in `rewrite/BRAND.md`, master assets in `rewrite/brand/`

> The identity landed (Ghuson). The one-file brand isolation in §2 stays anyway — it's what made this swap a config change, and it keeps future identity evolution (tagline, palette, sub-brands) cheap.

---

## 1. Goals & Non-Goals

**Goals**
- Production-grade mobile app for recycling logistics in Jordan. Three roles: Supplier (individual / store-business), Driver, Recycling Company.
- Full feature parity with the legacy app (parity checklist lives in `rewrite/PARITY.md`, Stage 0 output).
- Server-authoritative: every business invariant enforced in Postgres/Edge Functions, never trusted to the client.
- Arabic-first, RTL-first, bilingual (ar template / en secondary) from the first commit.
- One codebase, zero demo/mock forks: demo behavior is runtime configuration, not parallel code paths.

**Non-Goals**
- No payment gateway. Money is ledger-only (`driver_wallet`, `wallet_transactions`, `transactions`); a provider interface exists but is unimplemented.
- No web admin dashboard — owned by the dashboard team, built against the same Supabase project per the FigJam contract.
- No offline-first write model for order actions (see §7 for what IS offline-tolerant).

---

## 2. The Identity Layer (brand = Ghuson, isolated anyway)

**Rule: brand strings ("Ghuson"/"غصن" — and any legacy "Dawer"/"Dwaar") may appear in exactly ONE Dart file.**

```
lib/core/brand/brand.dart          ← the only identity-aware file
```

```dart
/// All user-facing identity. Brand evolution = editing this file + assets.
abstract final class Brand {
  static const appNameAr = 'غصن';
  static const appNameEn = 'Ghuson';
  static const taglineEn = 'The Operating System for the Circular Economy';
  static const domain = 'ghuson.io';
  static const logoAsset = 'assets/brand/logo.png';       // from master PDF, rewrite/brand/
  static const splashAsset = 'assets/brand/splash.png';
  // "Copper Patina" palette — full token sheet in rewrite/BRAND.md
  static const primaryLight = Color(0xFF13605B);  // deep patina teal
  static const primaryDark  = Color(0xFF6FB8AE);  // AA on dark scaffold
  static const deepAnchor   = Color(0xFF183B38);
  static const canvasLight  = Color(0xFFF4F1EA);  // never pure white
  static const scaffoldDark = Color(0xFF101C1B);
  static const copperSignal = Color(0xFFA9744E);  // single data accent
  static const supportEmail = 'support@ghuson.io';
  static const deepLinkScheme = 'ghuson';
}
```

**Enforcement & mechanics**
- Dart package name: `ghuson` (pubspec `name:`) — set once, never renamed.
- App display name lives in platform string resources only (`android/.../values*/strings.xml` `app_name`, iOS `CFBundleDisplayName`) — referenced, never inlined.
- **`applicationId` / bundle ID: `io.ghuson.app`** (dev flavor: `io.ghuson.app.dev`) — ⚠️ confirm `ghuson.io` ownership with Laith before first store upload; unchangeable on Android afterwards.
- Logo/splash under `assets/brand/`, exported from the master files in `rewrite/brand/` (never reconstruct the mark; icon-only below 90 px; clear space = one node height).
- Theme derives from `Brand` constants → `ThemeData.colorScheme`. Fonts: **Hanken Grotesk** (Latin) + **IBM Plex Sans Arabic** — replaces legacy Cairo/DM Sans. **Dark theme is the default** per guidelines ("dark leads product surfaces"); light remains available.
- l10n `.arb` files use an `{appName}` placeholder wherever the name appears in copy.
- FCM channel IDs, bucket names, analytics keys use `ghuson` (stable even if display brand evolves).
- CI lint: `grep -riE "dwaar|dawer|دوّر" lib/ && exit 1` — legacy brand must never enter the codebase; "Ghuson/غصن" outside `brand.dart`/`.arb` placeholders fails review.

---

## 3. System Architecture

```
┌────────────────┐        ┌─────────────────────────── Supabase ───────────────────────────┐
│  Flutter app   │  REST/ │  Auth │ PostgREST │ Realtime │ Storage │ Edge Functions        │
│  (this repo)   │◄──────►│                                        │  • dispatch-order     │
└────────────────┘  RT/WS │  Postgres (RLS + RPCs + triggers)      │  • send-push → FCM    │
┌────────────────┐        │  Buckets: user-documents (private),    │  • gemini-proxy → AI  │
│ Admin dashboard│◄──────►│  profile-photos, order-photos, chat    │  • make-server (Hono, │
│ (other team)   │        │                                        │    ALL admin writes)  │
└────────────────┘        └─────────────────────────────────────────────────────────────────┘
```

**Non-negotiables (pinned on the FigJam board):**
1. All admin writes go through `make-server` and are logged to `admin_audit_log`. No direct table writes from the dashboard.
2. Order status changes only via `transition_order_status()` RPC — the state machine lives in Postgres; illegal transitions are rejected server-side.
3. Wallet operations (hold/release/refund/penalty) are atomic SQL functions: ledger row + cached balance update in one transaction. `driver_wallet.balance` is never client-written.
4. All Gemini calls go through the `gemini-proxy` Edge Function. The API key never ships in the app (the legacy app leaks it via bundled .env — this is the fix).
5. Client reads via PostgREST + Realtime under RLS scoped to own rows; client writes that carry business rules go via RPC, plain CRUD (e.g. chat messages) via PostgREST under RLS `WITH CHECK`.

**Schema:** as drawn on the board — `profiles`, `vehicles`, `orders` (with `parent_order_id`, `is_marketplace_shared`, location/photos/schedule columns, `waste_type[]` enum array), `transactions`, `driver_wallet` + `wallet_transactions`, `driver_locations` (uuid `order_id`, `updated_at`), `notifications`, `chat_messages`, `report_requests`, `hubs`, `reservations`, `green_credit_entries`, `fraud_audit`, plus admin-side `admin_users`, `admin_audit_log`, `zones`, `pricing_rules`, `api_keys`, `support_messages`. Enums are Postgres enums (`user_role`, `supplier_type`, `order_type`, `order_status`, `waste_type`, `vehicle_type`, …) — the single source of truth the Dart enums are generated to match.

---

## 4. Flutter App Architecture

**Stack:** Flutter stable · Riverpod 3 (+ riverpod codegen) · go_router · freezed + json_serializable · supabase_flutter · firebase_messaging + flutter_local_notifications · google_maps_flutter · geolocator · intl/gen-l10n.

**Structure — feature-first, three layers inside each feature:**

```
lib/
  core/
    brand/          brand.dart (see §2)
    config/         env.dart (dart-define reader), feature_flags.dart (demoMode lives here)
    router/         app_router.dart (go_router, auth-guarded, role-aware redirect)
    theme/          app_theme.dart, tokens.dart (light+dark from Brand seeds)
    l10n/           app_ar.arb (template), app_en.arb, l10n.dart
    supabase/       client provider, realtime channel helpers
    error/          app_failure.dart (sealed), result.dart, global error listener
    widgets/        shared primitives (buttons, cards, empty/loading states)
  features/
    auth/           data/ domain/ presentation/   (login, OTP, signup wizard, onboarding)
    orders/         …                             (create wizard, feed, lifecycle, details)
    marketplace/    …                             (listings, buy flow, collection jobs, collectionSale)
    tracking/       …                             (GPS publisher, live map, geofence arrival)
    wallet/         …                             (balance, ledger, earnings dashboard)
    credits/        …                             (green credits, streaks, milestones)
    chat/           …                             (per-order rooms, realtime)
    notifications/  …                             (FCM registration, inbox, deep-link routing)
    reservations/   …                             (escrow flow, countdown, penalty states)
    analytics/      …                             (KPIs, charts, report requests)
    ai/             …                             (waste scan, doc verification UI → gemini-proxy)
    profile/        …                             (profile, vehicles, settings, language/theme)
  app.dart          MaterialApp.router + ProviderScope
  main.dart         bootstrap only (Firebase, Supabase, env) — no logic
```

**Layer rules (enforced by review + import lint):**
- `presentation` (views + Riverpod notifiers) may import `domain`; never `data` directly.
- `domain` = entities (freezed), repository interfaces, pure logic (fee math, credit formulas — mirrored from SQL for display only; server result wins).
- `data` = repository implementations over Supabase; the ONLY layer that imports `supabase_flutter`.
- No feature imports another feature's `data/`. Cross-feature reads go through exposed providers.

**State pattern (locked, every feature identical):**
```dart
// data:      supabase repo, exposed as a provider
// domain:    freezed entities + repo interface
// presentation:
@riverpod class OrderFeed extends _$OrderFeed { … }          // async list state
final orderStreamProvider = StreamProvider.family<Order, String>(…); // realtime
```
Views `watch` notifiers/streams only. No `ChangeNotifier`, no manual listeners, no `context.read` state access. `autoDispose` by default; `keepAlive` only with a written justification comment.

**Role shells:** one `HomeShell` per role (driver / supplier / recyclingCo) selected by `profiles.role` at the router redirect. Supplier is ONE shell configured by `supplier_type` + business category (presets: default waste types, wizard defaults, copy) — no separate restaurant UI tree.

**Demo mode:** `--dart-define=DEMO=true` → `feature_flags.dart` → seeded Supabase *dev* project + auto-login test accounts. Same code, different environment. The prod build physically cannot enter demo mode.

---

## 5. Key Flows (server-authoritative versions)

- **Order lifecycle:** create via `create_order()` RPC (validates pricing against `pricing_rules`) → drivers see feed via RLS-scoped realtime query → accept via `transition_order_status(order_id, 'accepted')` which atomically assigns driver + places wallet hold → arrival via `verify_arrival` Edge Fn (geofence, server-checked) → complete → wallet release + `green_credit_entries` insert + `transactions` row, all in one SQL function.
- **Dispatch:** `dispatch-order` Edge Fn ranks candidate drivers (`nearby drivers × vehicle capacity × chemical permit`) — replaces the legacy client-side filtering and the removed fake-driver screen.
- **Tracking:** driver device upserts `driver_locations` every few seconds while an order is active; supplier/company subscribe via Realtime. Rows carry `updated_at`; consumers treat >30s-old positions as stale.
- **AI:** app sends images/prompts to `gemini-proxy` (auth-checked, rate-limited, key server-side). Same proxy serves waste scan, doc verification pre-check, chatbot.
- **Verification:** per the board's ID-photo sequence — private upload, admin review through make-server signed URLs, push notification on decision.

---

## 6. Localization, Theme, Accessibility

- `.arb` Arabic template; every string keyed from day one — **hardcoded UI strings fail review**, no exceptions (the legacy app's l10n debt started as "temporary" Arabic literals).
- Directionality from locale; layouts written RTL-first and verified LTR (golden tests run both).
- Fonts: IBM Plex Sans Arabic (ar) / Hanken Grotesk (latin) via theme tokens; tabular figures for data/dashboards.
- Dark + light themes generated from `Brand` seeds (dark is default per brand guidelines); all colors via tokens, raw hex fails review. Canvas `#F4F1EA` replaces pure white in light theme.

## 7. Connectivity & Offline Policy

Drivers work in the field; the app must degrade gracefully, not pretend to be offline-first.

- **Reads:** last-known data cached in memory + lightweight disk cache (SharedPreferences snapshot per feed); UI shows cached data + staleness banner when disconnected.
- **Realtime:** every channel subscription wrapped in a reconnect helper (exponential backoff, resubscribe on `connectivity_plus` regain) — fixes the legacy silent-drop bug at the infrastructure layer, once, for all features.
- **Writes:** order actions require connectivity; failures surface as retryable snackbars (never silently queued — a queued "accept order" executing an hour later is worse than an error).
- **GPS pings:** buffered in memory when offline, latest-wins flush on reconnect (position history has no value, currency does).

## 8. Testing & CI

- **Unit:** domain logic (credit/fee formulas vs SQL fixtures), notifiers via `ProviderContainer` overrides.
- **Repository:** against `supabase start` (local stack) in CI — RLS policies and RPCs are tested as code, including "role X cannot see/write Y" negative tests.
- **Widget/golden:** each screen ar-RTL + en-LTR, light + dark.
- **Integration smoke:** login → create order → accept → complete on the dev project, nightly.
- **CI (GitHub Actions):** `analyze` + `test` + brand-leak grep (§2) on every PR; APK build on main; migrations applied to dev project via `supabase db push` from PR-reviewed SQL only.

## 9. Delivery Phases

| Phase | Scope | Exit criterion |
|---|---|---|
| 0 | Behavior spec + parity checklist from legacy app | `PARITY.md` reviewed by Laith |
| 1 | Schema, RLS, RPCs, Edge Fns (the contract) | migrations green on fresh project; RLS negative tests pass; dashboard team sign-off |
| 2 | App skeleton: brand layer, router, theme, l10n, CI | app boots, role shells navigable, CI green |
| 3 | Auth + onboarding (real; demo via env) | all roles sign up + land on shell |
| 4 | Order core: create/feed/lifecycle via RPC + realtime | full pickup lifecycle on dev project |
| 5 | Tracking & geo: GPS, live map, geofence, dispatch | supplier watches driver arrive; server-verified |
| 6 | Marketplace + collection jobs + collectionSale | linked-order flows complete |
| 7 | Wallet, earnings, green credits (server ledgers) | balances match SQL fixtures |
| 8 | Chat + notifications (FCM deep links) | message + push round-trip |
| 9 | Reservations/escrow | penalty path verified server-side |
| 10 | AI suite via gemini-proxy | waste scan + doc check + chatbot live, key server-side |
| 11 | Analytics + reports | report request → ready → download |
| 12 | Parity audit vs Phase 0 checklist + rebrand flip | gaps named; brand file + IDs swapped |

Each phase ships as its own implementation plan (bite-sized TDD tasks per the writing-plans format), executed and reviewed before the next begins. The app is runnable at the end of every phase.

## 10. Decisions Log

| # | Decision | Why |
|---|---|---|
| D1 | Greenfield repo, legacy as behavior spec | 4-branch merge debt; fake paths woven through |
| D2 | Supabase stays; Python/GCP backend dropped | already the working backend; team contract |
| D3 | Riverpod 3 + codegen over Provider/Bloc | legacy bugs are Provider-shaped; async-first fits realtime |
| D4 | Server-side state machine + atomic wallet SQL | client-enforced invariants are the root legacy flaw |
| D5 | One supplier shell, profile-configured | "restaurant" is a category, not a role |
| D6 | Ledger-only money, provider interface unimplemented | no payments in scope; integration later, not redesign |
| D7 | Brand isolated to one file + platform strings | identity changes next week |
| D8 | We design schema; dashboard team follows | agreed 2026-07-11 |
