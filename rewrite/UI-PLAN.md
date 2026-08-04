# Ghuson — UI Phase Plan

**Date:** 2026-07-25 · **Status:** Proposed · **Precedes:** backend phases (ARCHITECTURE.md §9 P1, P3–P11)
**Inputs:** `ARCHITECTURE.md` · `BRAND.md` · legacy app `A-Dawer/Dawer` (behavior reference) · [FigJam contract](https://www.figma.com/board/FuwRum13uGgAIb83tzzGr0/)

## 0. Decisions driving this plan

| Decision | Choice |
|---|---|
| Visual fidelity | **Full redesign** — flows and navigation may change, not just skin |
| Data source | **Fixtures behind repository interfaces** (`lib/fixtures/`), one swap point to Supabase |
| Build order | **Design system → Supplier → Driver → Company** |
| Maps · AI · Analytics/charts | **Deferred** to their backend phases; UI phase ships defined placeholders |

Goal of this phase: a **fully navigable, fully designed app** running on fixtures — every core screen real, every flow clickable end-to-end, zero backend. When Phase 1 lands, screens don't change; only the provider overrides do.

## 1. Legacy audit — what we're replacing

`A-Dawer/Dawer/lib/ui` — 217 Dart files, **53,108 lines**, ~60 full screens/sheets, 1,173 Arabic l10n keys, 5-tab navigation per role.

**Worth carrying over (concepts, not code):**
- The `AppTokens extends ThemeExtension` + `context.dt` pattern — genuinely good semantic tokens (surface / surfaceVariant / scaffold / onSurfaceMuted / border). We adopt this pattern with Ghuson values (upgrade from the current static `ColorScheme`-only `tokens.dart`).
- **The Arabic copy corpus.** 1,173 `.arb` keys of real, reviewed Arabic UX copy. Port the *strings*, not the widgets — this is the single biggest time-saver available and it protects the Arabic-first quality bar.
- Order-details decomposition into sections (14 files) — right instinct, wrong sizes (some 500-line "sections").
- The 3-step pickup wizard shape (material+photo → quantity+price → location+review) tested well; keep the step model.

**Explicitly not carried:** 5-tab navs (too many; one tab was a report dumping ground), 800-line screen files, `new_order_sheet.dart` at 847 lines, duplicated order-card variants per role (`order_card` / `supplier_order_card` / `driver_available_order_card` / `driver_active_order_card` / `collection_job_card` / `collection_sale_card` / `market_item_card` / `market_listing_card` — eight card widgets for one concept), the separate `restaurant/` UI tree, `dev_testing_panel`.

## 2. Redesign principles (from BRAND.md)

1. **Dark-led.** Dark is the default theme; light is a first-class alternative, not an afterthought. Every screen reviewed in both.
2. **Canvas over white.** Light theme uses `#F4F1EA`, never pure white.
3. **Monoline + node + arc.** Icons on a 24px grid at the mark's stroke weight; the node/arc motif carries status and connection meaning (an order's lifecycle *is* a node chain — use it).
4. **Radius scale 6 / 12 / 18 / full.** No arbitrary radii.
5. **One accent.** Copper Signal `#A9744E` for data highlights only — never body text, never a second brand color.
6. **Tabular figures for all data** (weights, JOD, percentages, scores).
7. **RTL-first.** Built Arabic-first, verified LTR. Directional icons/paddings use logical (`start`/`end`) properties only.
8. **Quiet premium.** Generous spacing, low-contrast structure, restraint over decoration. No eco clichés, no gradients-for-flair.
9. **"Green Score"** is brand vocabulary — it names the supplier/company impact metric surfaced on home and profile.

## 3. Proposed information architecture

Four tabs per role, maximum. Each role's most-used action is the tab, not a hidden button.

### Supplier (individual + business, one shell configured by type)
| Tab | Purpose |
|---|---|
| **Home** | Green Score, active order tracker, primary "New pickup" CTA, recent activity |
| **Market** | Browse buyers/listings, sell material, collection jobs open to suppliers |
| **Orders** | All own orders, filterable by state |
| **Account** | Profile, credits/rewards, addresses, settings |

Business-type suppliers get category presets and larger default quantities in the wizard — same shell, different configuration.

### Driver
| Tab | Purpose |
|---|---|
| **Jobs** | Available job feed (the driver's home screen — filters: vehicle fit, distance, material) |
| **Active** | The one active order, full-bleed: route, next action, proof capture. Empty state when idle |
| **Earnings** | Balance, holds, per-trip ledger |
| **Account** | Profile, vehicles, availability toggle, settings |

Driver holds **one active order at a time** — that constraint deserves its own tab rather than being buried in a list.

### Recycling Company
| Tab | Purpose |
|---|---|
| **Overview** | Hub load/capacity, today's inbound, Green Score |
| **Jobs** | Own collection jobs (post / edit / close) |
| **Inbound** | Incoming shipments + collection-sale commitments awaiting weight approval |
| **Account** | Company profile, hubs, team, settings |

**Modal/pushed flows (not tabs):** new-pickup wizard, order details, post-job sheet, market item purchase flow, reservation create/detail, chat room, notifications inbox, weight approval, proof capture, settings sub-pages.

## 4. Screen inventory (~46 screens vs legacy ~60)

Reduction comes from merging role-duplicated screens and dropping deferred surfaces — not from cutting features.

### A. Design system (no screens — components)
`GhButton` (filled/tonal/text/destructive) · `GhCard` · `GhSheet` (drag handle, safe-area) · `GhTextField` · `GhChip` · `GhSegmentedBar` · `GhStatusPill` (order states) · `GhNodeTimeline` (the arc/node lifecycle visual) · `GhKpiTile` · `GhScoreRing` (Green Score) · `GhMoney` + `GhWeight` (tabular formatters) · `GhAvatar` · `GhListTile` · `GhEmptyState` · `GhErrorState` · `GhSkeleton` · `GhAppBar` · `GhBottomNav` · `GhMapPlaceholder` · `GhStepper` (wizard progress) · `GhPhotoPicker` · `GhBanner` (offline/stale) · `GhSnackbar`.

**One order card, not eight:** `GhOrderCard` with a `variant` enum (`supplierOwn`, `driverAvailable`, `driverActive`, `marketListing`, `collectionJob`, `collectionSale`, `inbound`) driving which facts show. This single decision removes ~3,000 lines of legacy duplication.

### B. Entry & auth (7)
Splash · Language/first-run · Login (phone) · OTP verification · Signup: role select → identity → role details → documents (AI panel stubbed) · Account-pending/verification state

### C. Supplier (11)
Home · Market browse · Market item details · Purchase/sell choice sheet · Orders list · New-pickup wizard (3 steps + review) · Pickup confirmation/success · Account · Credits & rewards · Addresses · Settings

### D. Driver (9)
Jobs feed · Job filters sheet · Job preview sheet · Active order · Proof capture (photo + weight) · Arrival confirm state · Earnings dashboard · Earnings trip detail · Account (incl. vehicles, availability)

### E. Company (8)
Overview · Jobs list · Post/edit job sheet · Job details · Inbound list · Collection-sale details · Weight approval · Account (incl. hubs list)

### F. Shared (11)
Order details (sectioned, all roles) · Order status timeline · Cancel-order flow · Chat room · Chat list · Notifications inbox · Reservation create · Reservation inbox · Reservation detail · Rate driver sheet · Profile edit

### Deferred (built as `GhMapPlaceholder` / stub panels now, real in later phases)
Live tracking map, location picker, route map, hubs map (→ P5 tracking) · AI waste scan, doc/vehicle verification analysis, Dawa chatbot (→ P10 via `gemini-proxy`) · Analytics tab, all charts, report center (→ P11).

Each deferred surface still gets its **entry point and placeholder** now, so no navigation dead-ends exist and the later phase is a drop-in.

## 5. Fixtures architecture (the anti-mock-mess design)

The legacy app's fatal flaw was mock and real implementations tangled together in the widget tree. Structure that makes it impossible:

```
lib/features/<f>/domain/    i_<x>_repository.dart   ← interface + provider declaration
lib/fixtures/               fixture_<x>_repository.dart, sample_<x>.dart
lib/fixtures/fixtures_scope.dart                    ← the ONE wiring file
```

Rules:
- Repository providers are declared in `domain` and **throw `UnimplementedError` by default**. A screen can never accidentally run against nothing.
- `fixtures_scope.dart` supplies every override; `main.dart` applies it while `Env.hasBackend` is false. Phase 1+ swaps that list for Supabase implementations — **one file changes, `lib/features/` doesn't**.
- `lib/features/**` importing `lib/fixtures/**` is a **CI failure** (grep gate, same mechanism as the brand check).
- Fixtures are in-memory and mutable within a session, so flows feel real (create a pickup → it appears in Orders → driver accepts it → supplier sees the state change). Deleting `lib/fixtures/` at the end must leave a compiling app.
- Fixture data is realistic Jordanian: Amman districts, JOD amounts, Arabic names, plausible weights.

## 6. Build stages

Each stage gets its own implementation-plan doc (bite-sized TDD tasks, exact paths, complete code) and ends with a runnable, reviewable app.

| Stage | Scope | Exit criterion |
|---|---|---|
| **U0** | l10n copy port from legacy `.arb` (curated, renamed to new IA); tokens upgraded to `ThemeExtension` + `context.dt`; golden-test harness (ar-RTL/en-LTR × dark/light) | `flutter test` green; token audit shows zero raw hex |
| **U1** | Design system: all §4.A components + a `/dev/gallery` route showing every component in every state | Gallery renders all components in 4 theme/direction combos |
| **U2** | App frame: splash, language, auth + signup wizard, role shells with new 4-tab navs, empty/loading/error states, notifications inbox shell | Every role's shell navigable; auth flow completes on fixtures |
| **U3** | Fixtures foundation: domain interfaces, fixture repos, `fixtures_scope`, sample data; CI import gate | Fixture-backed order/user/market data flows into U2 screens |
| **U4** | **Supplier complete** (§4.C) incl. pickup wizard end-to-end | Create pickup → appears in Orders → details → cancel, all working |
| **U5** | **Driver complete** (§4.D) incl. proof capture | Accept job → active order → proof → complete; earnings updates |
| **U6** | **Company complete** (§4.E) | Post job → receives commitment → approve weight |
| **U7** | Shared secondary (§4.F): order details deep sections, chat, reservations, rate driver, profile edit | Cross-role order details renders correctly for all three roles |
| **U8** | Polish: RTL/LTR audit, dark/light audit, motion pass, a11y (44px targets, contrast, semantics), golden tests per screen | Screenshot review passed; goldens committed; analyze clean |

Cross-cutting rule for every stage: **no screen file exceeds ~250 lines** (extract sections/widgets), every string is an `.arb` key, every color a token.

## 7. Review gates

- After each stage: I present screenshots (widget-test captures or your emulator run) before moving on.
- Golden tests are the regression net — added in U8 per screen, so the redesign can't silently drift later.
- Any deviation from this plan's IA gets recorded in a decisions log at the bottom of the stage's plan doc.

## 8. Open questions

1. **Wordmark/lockup assets** — I have the primary square mark only. The stacked lockup and app-icon variants from the guidelines would improve splash/auth screens.
2. **Fonts offline** — `google_fonts` fetches at runtime. Recommend bundling Hanken Grotesk + IBM Plex Sans Arabic as assets before U1 (field users, flaky networks, and it removes a first-frame flash).
3. **Green Score formula** — brand shows "92 score" in mockups. Is it derived from credits, weight diverted, verification rate, or a composite? Needed for U4 (a placeholder number is fine short-term).
4. **Business-supplier presets** — which waste categories/quantities differ from individual, for the wizard defaults.
