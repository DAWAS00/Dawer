---
goal: Analytics "Decisions Layer" — add 4 high-insight features (streak, cycle-time, waste-type profitability, earnings-per-km) that help each role make decisions, computed client-side from the existing Order model
version: 1.0
date_created: 2026-06-28
last_updated: 2026-06-28
owner: mohammad
status: 'Planned'
tags: [feature, analytics, ui, gamification, driver, supplier, recycling]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

The analytics tab (redesigned 2026-06-28, see `docs/superpowers/specs/2026-06-28-analytics-tab-redesign-design.md`) currently shows *what happened* — totals, deltas, a trend chart, and a waste-type breakdown. It does not yet answer the questions each role actually asks themselves:

- **Driver:** "Am I keeping up my pace?" / "Where do my minutes go?" / "Which jobs are worth taking?"
- **Supplier:** "What should I recycle more of?" / "Am I on a roll?"
- **Recycling Co:** "How efficiently are orders flowing through?"

This plan adds a **"Decisions Layer"** — 4 client-side-computed features that turn numbers into *actionable insight*. All four are computed from fields already present on the `Order` model (`completedAt`, lifecycle timestamps, `distanceKg`, `reward`, `wasteTypes`). **No backend work, no migrations, no new API calls.**

The features are layered into the existing analytics tab layout; they do not replace what is there.

## 1. Requirements & Constraints

- **REQ-001**: All four features must be computed purely from the `Order` list already held by `AnalyticsViewModel`. No new repository methods, no Supabase calls, no migrations.
- **REQ-002**: Each feature degrades gracefully when its source data is absent (nullable timestamps, missing `distanceKg`, zero orders) — showing either an empty state or hiding itself, never throwing or rendering `NaN`.
- **REQ-003**: The existing analytics tab layout and its 335 passing tests must remain intact. New features are *additive* sections inserted into the `CustomScrollView`; no existing section is removed or reordered.
- **REQ-004**: All four features must respect RTL and the existing `AppColors` / Cairo + DmSans typography. No new dependencies.
- **REQ-005**: `flutter_animate` (already a dependency, already used in the analytics tab) provides entrance animations; durations 300–400ms with 40ms stagger between sibling sections.
- **REQ-006**: Feature visibility is role-scoped: Streak = all roles; Cycle-time + Earnings/km = Driver only; Profitability = Supplier + Recycling Co (those who set `wasteTypes` + `pricePerKg`).
- **SEC-001**: No PII leaves the device. All computation is local.
- **CON-001**: `Order.completedAt` is nullable (`DateTime?`); every feature that uses it must null-guard. Same for `acceptedAt`, `inTransitAt`, `arrivedAtPickupAt`, `arrivedAtDropoffAt`, `distanceKg`, `pricePerKg`, `weightKg`.
- **CON-002**: Localization follows the current analytics-tab convention (hardcoded Arabic strings); ARB migration is tracked separately and out of scope here.
- **GUD-001**: Follow AGENTS.md §7 — semantic colors from `AppColors`, `flutter analyze` clean before commit, widget tests for every new widget.
- **PAT-001**: Mirror the existing widget pattern: one file per widget under `lib/ui/features/analytics/widgets/`, `StatelessWidget` unless animation state is needed, `RepaintBoundary` around any `CustomPaint`.

## 2. Implementation Steps

### Implementation Phase 1 — ViewModel extensions (the math)

- GOAL-001: Extend `AnalyticsViewModel` with the four computed read-only getters the widgets will consume. Pure logic, fully unit-testable.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Add `currentStreak` (int) + `longestStreak` (int) to `AnalyticsViewModel`. Algorithm: collect the set of distinct dates (day-granularity) from `completedAt` across **all** orders (not period-filtered — streaks span history); starting from today (or the most recent active day if today is silent), count consecutive days backward that appear in the set. Return 0 if no completed orders. | | |
| TASK-002 | Add `CycleTimeBreakdown` value class: `avgAcceptMinutes`, `avgPickupMinutes`, `avgTransitMinutes`, `avgDropoffMinutes`, `avgTotalMinutes`, all `double?`. Add `cycleTime` getter to `AnalyticsViewModel` that computes per-stage averages from `createdAt`→`acceptedAt`→`arrivedAtPickupAt`→`inTransitAt`→`arrivedAtDropoffAt`→`completedAt` over `filteredOrders`, skipping any order missing a needed timestamp. Any stage with zero valid samples → null. | | |
| TASK-003 | Add `WasteProfitability` value class: `type` (WasteType), `rewardPerKg` (double), `totalKg`, `totalReward`, `sampleCount`. Add `wasteProfitability` getter to `AnalyticsViewModel` that, over `filteredOrders`, attributes each order's `reward` across its `wasteTypes` (split evenly when an order has >1 type), divides by the order's `weightKg`, and accumulates per type; returns list sorted by `rewardPerKg` desc. Empty list when no weighted orders. | | |
| TASK-004 | Add `earningsPerKm` (double?) + `bestJobsByEfficiency` (List<({Order order, double jodPerKm})>, max 3) to `AnalyticsViewModel`. Compute `reward / distanceKm` per order over `filteredOrders` where both fields are present and `distanceKm > 0`; `earningsPerKm` = mean of all such ratios; `bestJobsByEfficiency` = top 3 sorted desc. Null/empty when no qualifying orders. | | |
| TASK-005 | Extend `test/ui/features/analytics/analytics_viewmodel_test.dart` with unit tests for all four getters: streak (0 / 3-day / gap-breaks-streak), cycle-time (null when timestamps missing, correct averages when present), profitability (sorted desc, split on multi-type orders, empty when unweighted), earnings/km (null when no distance, mean correct, top-3 sorted). | | |

### Implementation Phase 2 — Streak widget (all roles)

- GOAL-002: Build the streak UI and wire it into the hero + as a section.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-006 | Create `lib/ui/features/analytics/widgets/streak_heatmap.dart`: a `StatelessWidget` rendering a 5-week (35-cell) GitHub-style calendar heatmap. Each cell = one day; color intensity scales with number of completed orders that day (0 = neutral `AppColors.surfaceAlt`, 1–2 = light green, 3+ = `AppColors.primaryGreen`). Cells for future days render as outlined-empty. Tooltip via `Semantics(label:)`. RTL: week columns flow right-to-left. | | |
| TASK-007 | Add a streak chip to `AnalyticsHeroCard`: when `currentStreak >= 2`, render "🔥 {n} أيام متتالية" as a small badge next to the delta chip (top-left). Pass `currentStreak` through a new optional ctor param. Hide entirely when streak < 2. | | |
| TASK-008 | Insert a "سلسلة النشاط" section (header + `StreakHeatmap`) into `analytics_tab.dart` between the hero and the KPI grid, shown for **all roles**. Read `vm.currentStreak` + the per-day counts (expose a `Map<DateTime,int> activityByDay` getter on the viewmodel for the last 35 days). Animate fade-in. | | |

### Implementation Phase 3 — Cycle-time widget (Driver)

- GOAL-003: Build the cycle-time breakdown bar and wire it for the Driver role.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-009 | Create `lib/ui/features/analytics/widgets/cycle_time_breakdown.dart`: horizontal proportional stacked bar showing the 4 stages' share of avg total time, each segment colored differently (`accept`=blue, `pickup`=amber, `transit`=green, `dropoff`=purple). Below: a legend with each stage's avg minutes. Caption above: "متوسط زمن الطلب: {N} دقيقة". Empty state when all stages null. | | |
| TASK-010 | Add a `showCycleTime` bool param to `AnalyticsTab` (default false). Insert the "زمن دورة الطلب" section after the Waste-Type Breakdown, rendered only when `showCycleTime && vm.cycleTime.avgTotalMinutes != null`. Driver home passes `showCycleTime: true`. | | |

### Implementation Phase 4 — Profitability widget (Supplier + Recycling Co)

- GOAL-004: Build the waste-type profitability chart and wire it for Supplier + Recycling Co.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-011 | Create `lib/ui/features/analytics/widgets/waste_profitability_chart.dart`: horizontal bar chart (one row per waste type, sorted desc by `rewardPerKg`). Each row: colored leading chip + type label + a horizontal bar (width ∝ `rewardPerKg` / max) + the value "{x.x} د.أ/كغ" on the trailing edge. Top row gets a "🏆 الأعلى ربحًا" badge. Empty state when list empty. | | |
| TASK-012 | Add a `showProfitability` bool param to `AnalyticsTab` (default false). Insert the "أربح المواد" section after the Waste-Type Breakdown (or after Cycle-Time when both show), rendered only when `showProfitability && vm.wasteProfitability.isNotEmpty`. Supplier + Recycling homes pass `showProfitability: true`. | | |

### Implementation Phase 5 — Earnings-per-km widget (Driver)

- GOAL-005: Build the earnings-efficiency hero number + best-jobs list and wire it for Driver.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | Create `lib/ui/features/analytics/widgets/earnings_efficiency_card.dart`: a compact card showing the big ratio "{x.xx} د.أ/كم" + a one-line caption "متوسط ما تربحه لكل كيلومتر". Below the ratio: a mini list of the top-3 most efficient jobs (date + the ratio + waste-type chip). Empty state when `earningsPerKm == null`. | | |
| TASK-014 | Add a `showEarningsEfficiency` bool param to `AnalyticsTab` (default false). Insert the "كفاءة الأرباح" section after the Cycle-Time section (driver-only block), rendered only when `showEarningsEfficiency && vm.earningsPerKm != null`. Driver home passes `showEarningsEfficiency: true`. | | |

### Implementation Phase 6 — Wire role homes + final verification

- GOAL-006: Connect the role flags at each call site and verify the whole app is green.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-015 | Update `lib/ui/features/home/driver/driver_home_view.dart` (or wherever the driver `AnalyticsTab` is constructed): pass `showCycleTime: true`, `showEarningsEfficiency: true`. Streak shows automatically. | | |
| TASK-016 | Update `lib/ui/features/home/supplier/individual_supplier_home_view.dart`: pass `showProfitability: true`. Streak shows automatically. | | |
| TASK-017 | Update `lib/ui/features/home/recycling/recycling_home_view.dart`: pass `showProfitability: true` (in addition to the existing `heroMetric: HeroMetric.weight`). Streak shows automatically. | | |
| TASK-018 | Run `flutter analyze` — must report "No issues found!". Run `flutter test` — all analytics tests + the pre-existing 335 must pass (the 3 documented pre-existing failures in `mock_auth_repository_test.dart` / `chat_view_test.dart` remain acceptable per AGENTS.md §4). Fix any new failure introduced by these changes. | | |

## 3. Alternatives

- **ALT-001**: *Build all 8 ideas from the brainstorm (add forecast, share card, progress rings, funnel).* Rejected for v1 — the top 4 are the 80/20 of decision-power and ship faster; the remaining 4 are deferred to a Phase 3 polish pass once the core layer is validated by users.
- **ALT-002**: *Compute these metrics on the backend (Supabase view / Edge Function).* Rejected — all source fields are already on the `Order` model and the app runs in hybrid/mock mode against `AppOrderStore`; client-side computation works offline, needs no migration, and matches the existing pattern. A backend rollup is only worth it at scale (Phase 4).
- **ALT-003**: *Use `fl_chart` for the profitability bars and heatmap.* Rejected for the heatmap (no first-party calendar heatmap; a 35-cell `GridView`/`CustomPaint` is simpler and dependency-free). `fl_chart` *is* used for the profitability horizontal bars via `BarChart`, but only if it reads cleaner than a manual `Row` of `Expanded(flex:)` — the implementer may choose either, prioritizing the manual Row for simplicity unless animation is needed.
- **ALT-004**: *New ARB keys for every new string.* Deferred — consistent with the current analytics-tab convention; tracked as a separate l10n task to keep this plan focused.

## 4. Dependencies

- **DEP-001**: The 2026-06-28 analytics tab redesign must be merged (it is, on branch `mohammad`): `AnalyticsViewModel`, `AnalyticsHeroCard`, `analytics_tab.dart` layout, `WasteTypeBreakdown`. This plan layers on top of those.
- **DEP-002**: `flutter_animate` (already in `pubspec.yaml`, used in the current tab).
- **DEP-003**: `fl_chart: ^0.69.0` (already in `pubspec.yaml`, used by `TrendChart`) — optional, for the profitability bars if chosen.
- **DEP-004**: `AppColors` semantic tokens (`primaryGreen`, `surfaceAlt`, `mutedText`, `textMain`, `borderSubtle`) — already defined.
- **DEP-005**: The `Order` model lifecycle timestamps (`acceptedAt`, `inTransitAt`, `arrivedAtPickupAt`, `arrivedAtDropoffAt`, `completedAt`) and numeric fields (`distanceKg`, `reward`, `weightKg`, `pricePerKg`) — all confirmed present on `lib/data/models/order/order.dart`.

## 5. Files

**New files:**
- **FILE-001**: `lib/ui/features/analytics/widgets/streak_heatmap.dart` — 35-cell calendar heatmap.
- **FILE-002**: `lib/ui/features/analytics/widgets/cycle_time_breakdown.dart` — per-stage time bar.
- **FILE-003**: `lib/ui/features/analytics/widgets/waste_profitability_chart.dart` — reward-per-kg bars.
- **FILE-004**: `lib/ui/features/analytics/widgets/earnings_efficiency_card.dart` — د.أ/كم ratio + top jobs.

**Modified files:**
- **FILE-005**: `lib/ui/features/analytics/analytics_viewmodel.dart` — add streak, cycle-time, profitability, earnings/km getters + value classes.
- **FILE-006**: `lib/ui/features/analytics/widgets/analytics_hero_card.dart` — add streak chip.
- **FILE-007**: `lib/ui/features/analytics/analytics_tab.dart` — add `showCycleTime` / `showProfitability` / `showEarningsEfficiency` params + insert the 4 new sections.
- **FILE-008**: `lib/ui/features/home/driver/driver_home_view.dart` — pass driver flags.
- **FILE-009**: `lib/ui/features/home/supplier/individual_supplier_home_view.dart` — pass supplier flags.
- **FILE-010**: `lib/ui/features/home/recycling/recycling_home_view.dart` — pass recycling flags.

**Test files:**
- **FILE-011**: `test/ui/features/analytics/analytics_viewmodel_test.dart` — extend with tests for all 4 new getters.
- **FILE-012**: `test/ui/features/analytics/streak_heatmap_test.dart` — widget renders 35 cells, empty state.
- **FILE-013**: `test/ui/features/analytics/cycle_time_breakdown_test.dart` — renders stages, empty state.
- **FILE-014**: `test/ui/features/analytics/waste_profitability_chart_test.dart` — sorted desc, top badge, empty state.
- **FILE-015**: `test/ui/features/analytics/earnings_efficiency_card_test.dart` — ratio shown, top-3 list, empty state.

## 6. Testing

- **TEST-001**: Unit — `currentStreak` returns 0 with no orders; returns N with N consecutive days; breaks on a gap day.
- **TEST-002**: Unit — `cycleTime` all-null when orders lack timestamps; correct per-stage averages with synthetic timestamps.
- **TEST-003**: Unit — `wasteProfitability` sorted by `rewardPerKg` desc; multi-type orders split evenly; empty when no weighted orders.
- **TEST-004**: Unit — `earningsPerKm` null when no `distanceKg`; mean correct; `bestJobsByEfficiency` returns ≤3 sorted desc.
- **TEST-005**: Widget — `StreakHeatmap` renders exactly 35 cells; future cells outlined; active cells colored by intensity.
- **TEST-006**: Widget — `CycleTimeBreakdown` renders 4 legend rows when data present; renders empty-state text when all null.
- **TEST-007**: Widget — `WasteProfitabilityChart` top row carries the 🏆 badge; bars proportional to max; empty state when list empty.
- **TEST-008**: Widget — `EarningsEfficiencyCard` shows the ratio and ≤3 job rows; empty state when null.
- **TEST-009**: Regression — existing `analytics_viewmodel_test.dart`, `kpi_card_test.dart`, `analytics_hero_card_test.dart`, `material_timeline_chart_test.dart`, `period_selector_test.dart` still pass unchanged.
- **TEST-010**: Static — `flutter analyze` reports "No issues found!".

## 7. Risks & Assumptions

- **RISK-001**: *Lifecycle timestamps may be sparsely populated in real data* (the app runs in hybrid/mock mode; mock orders may not set all stages). Mitigation: every cycle-time stage is independently nullable; the widget hides itself when `avgTotalMinutes == null`. The unit tests cover the all-null case.
- **RISK-002**: *`distanceKg`/`pricePerKg` may be null on many orders*, making earnings/km and profitability sparse. Mitigation: both features render an empty state and the section is hidden when empty; they never throw.
- **RISK-003**: *Heatmap performance* — 35 cells in a `GridView` is trivial, but wrapping in `RepaintBoundary` (per PAT-001) prevents rebuild cost during scroll.
- **RISK-004**: *Reward attribution to multiple waste types is approximate* (split evenly). Documented in the getter doc-comment; acceptable for an insight feature, not a billing surface.
- **ASSUMPTION-001**: The four lifecycle timestamps, when set, are monotonically ordered (`created ≤ accepted ≤ arrivedAtPickup ≤ inTransit ≤ arrivedAtDropoff ≤ completed`). The cycle-time getter clamps negative deltas to 0 to defend against clock skew.
- **ASSUMPTION-002**: "Today" for the streak is the device local date (`DateTime.now()`), consistent with the existing `AnalyticsPeriod.dateRange(now:)` usage.
- **ASSUMPTION-003**: Users find these insights valuable; if usage/retention data later shows low engagement on a specific feature, it can be hidden via its role flag without removing the code.

## 8. Related Specifications / Further Reading

- `docs/superpowers/specs/2026-06-28-analytics-tab-redesign-design.md` — the analytics tab redesign this layers onto.
- `devPlans/2026-06-28-analytics-and-reports-plan.md` — the broader analytics + reports effort (this plan is the Phase 2 "Decisions Layer" of that roadmap).
- `AGENTS.md` §4 (build/test commands), §6 (architecture), §7 (code style) — governing conventions.
- `lib/data/models/order/order.dart` — the source model for all four features' data.
