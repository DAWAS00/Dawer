# Analytics Tab Redesign — Design Spec

> **Date:** 2026-06-28
> **Scope:** Frontend-only redesign of the analytics experience across all roles (Driver, Supplier, Recycling Company).
> **Approach:** A — "Hero Summary + Insight Cards" with full polish animation, trend + Gantt charts both retained.

---

## 1. Problem Statement

The current analytics experience has three concrete problems, observed in code and in the user's screenshot:

1. **Layout bug.** Per-role home stat rows (e.g. `recycling_home_tab.dart::_buildStatsRow`) render 4 `_StatCard`s in a `Row` of `Expanded`s with long Arabic labels. On narrow screens this overflows — visible as `BOTTOM OVERFLOWED BY X PIXELS` in the screenshot. The shared `KpiStrip` avoids this by horizontal scrolling, but the two surfaces use different components, so the bug exists in one and not the other.
2. **Flat visual feel.** The shared `AnalyticsTab` is a vertical dump of equally-weighted sections (KPI strip → Gantt → activity list → milestones). No hierarchy, no "glance and know how you're doing" moment. Cards are plain white with tiny icons.
3. **No insight.** Numbers are static totals. There is no period-over-period delta, no trend over time, no breakdown by waste type. A user cannot tell whether this week is better or worse than last.

## 2. Goals & Non-Goals

**Goals**
- Fix the overflow bug at its root by replacing both stat surfaces with one unified component.
- Establish clear visual hierarchy: one hero metric → secondary KPIs → trend → breakdown → history → milestones.
- Add insight: deltas, trend series, waste-type breakdown.
- Add delight: count-up numbers, fade+slide-in, animated deltas, milestone unlock pulse — consistent with the existing `flutter_animate` usage in the recycling home.
- Keep the existing Gantt as a secondary "material timeline" chart.

**Non-Goals (deferred to Phase 2)**
- Pull-to-refresh.
- Drill-down detail screens (KPI taps will be no-op-ready hooks, not full routes).
- Realtime subscription on `report_requests` (status currently reloads on tab re-entry).
- New ARB keys for every string (the current tab uses hardcoded Arabic; this redesign continues that pattern for consistency with the surrounding code and is tracked as a separate l10n task). *Note: this defers AGENTS.md §7's ARB guideline and should be flagged in review.*

## 3. User-Facing Layout

Single shared `AnalyticsTab`, role-configured. Top-to-bottom:

```
┌──────────────────────────────────────────┐
│  SliverAppBar  "تقاريري"                 │   ← pinned, surface bg
│  [ أسبوع ] [ شهر ] [ الكل ]              │   ← PeriodSelector (kept)
├──────────────────────────────────────────┤
│  ╭──────────────────────────────────╮    │
│  │  AnalyticsHeroCard (gradient)    │    │   ← deep-green gradient
│  │  +12.4%  ▲                        │    │   ← delta chip vs last period
│  │   342.5 د.أ                       │    │   ← count-up animated big number
│  │  إجمالي الأرباح · هذا الشهر       │    │
│  │  ╱╲╱╲╲╱  (mini sparkline)        │    │   ← 7-point sparkline
│  ╰──────────────────────────────────╯    │
├──────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐              │   ← KpiGrid 2×2
│  │ وزن معالج│  │ CO₂ وُفِّر│              │      (tappable, no-op hook)
│  │  120 كغ  │  │  180 كغ  │              │
│  │ +8% ▲    │  │ +8% ▲    │              │
│  └──────────┘  └──────────┘              │
│  ┌──────────┐  ┌──────────┐              │
│  │ طلبات    │  │ متوسط/طلب│              │      4th card = role-tuned
│  │   12     │  │ 28.5 د.أ │              │
│  └──────────┘  └──────────┘              │
├──────────────────────────────────────────┤
│  الاتجاه                                  │   ← TrendChart (fl_chart area)
│  ╭──────────────────────────────────╮    │      primary metric over period
│  │      ╱╲                          │    │
│  │   ╱╲╱  ╲___                      │    │
│  │  ╱        ╲╲                     │    │
│  │ 1  7  14  21  28                 │    │
│  ╰──────────────────────────────────╯    │
├──────────────────────────────────────────┤
│  توزيع المواد                            │   ← WasteTypeBreakdown
│  ████████████████塑料 ████████ paper ...  │      horizontal stacked bar
│  ● بلاستيك 40%  ● ورق 25%  ...           │      + legend
├──────────────────────────────────────────┤
│  الجدول الزمني                            │   ← MaterialTimelineChart (kept, refined)
│  ╭──────────────────────────────────╮    │      secondary chart
│  ╰──────────────────────────────────╯    │
├──────────────────────────────────────────┤
│  سجل النشاط                              │   ← ActivityStatementList (richer rows)
│  ◉ بلاستيك  25 يونيو · 12 كغ   +10 د.أ   │
│  ◉ ورق      24 يونيو · 8 كغ    +6 د.أ    │
├──────────────────────────────────────────┤
│  إنجازاتي  (supplier/driver only)         │   ← MilestoneStrip (horizontal scroll)
│  [✓ أول طلب] [✓ 100كغ] [🔒 10 طلبات] →   │
├──────────────────────────────────────────┤
│  طلب تقرير  (supplier/recycling only)    │   ← ReportCenterSection (unchanged)
└──────────────────────────────────────────┘
```

### Role configuration

| Role | Hero metric | Hero label | 4th KPI | Milestones | Report center |
|---|---|---|---|---|---|
| Driver | `totalEarnings` | إجمالي الأرباح | avg reward/order | ✓ | ✗ |
| Supplier | `totalEarnings` | إجمالي الأرباح | avg reward/order | ✓ | ✓ |
| Recycling Co | `totalWeightKg` | إجمالي الوزن المعالج | active jobs count | ✗ | ✓ |

The `AnalyticsTab` constructor gains a `heroMetric` enum (`earnings` | `weight`) and a `secondaryKpi` widget slot, so the role home decides what the 4th card shows without the analytics package knowing about roles.

## 4. Component Specifications

All files under `lib/ui/features/analytics/`. Existing widgets that change are marked **(rewrite)**; new ones **(new)**.

### 4.1 `AnalyticsViewModel` (rewrite — additive)

Keeps all current getters (`filteredOrders`, `totalEarnings`, `totalWeightKg`, `estimatedCo2Kg`, `orderCount`, `ganttOrders`). Adds:

```
+ previousPeriodOrders : List<Order>     // orders in the immediately-prior period of same length
+ deltaEarningsPct : double?             // (cur-prev)/prev * 100, null if prev==0
+ deltaWeightPct   : double?
+ deltaOrdersPct   : double?
+ dailySeries      : List<({DateTime day, double value})>  // for TrendChart; value = hero metric per day
+ wasteBreakdown   : List<({WasteType type, double kg, double share})>  // sorted desc
+ avgRewardPerOrder : double             // totalEarnings / orderCount (0 if none)
```

Period math: `previousPeriodOrders` uses `_range` shifted earlier by `(_range.end - _range.start)`. `dailySeries` buckets `filteredOrders` by day (or by month if `allTime`).

### 4.2 `AnalyticsHeroCard` (new)

- Gradient background: `LinearGradient` from `AppColors.primaryGreen` (#0F5A34) to `AppColors.primaryDark` (#06331C), 16px radius.
- Layout: delta chip (top-right, animated color), big value (center-left, count-up via `flutter_animate`), label below, mini sparkline (bottom, 7 points) drawn with a tiny `CustomPaint`.
- Count-up: animate value from 0 → final over 800ms on first build and on period change.
- Empty state: if `orderCount == 0`, show "لا يوجد نشاط بعد" instead of "0 د.أ".

### 4.3 `KpiCard` v2 (rewrite)

Unified, used by both `KpiGrid` and the per-role home stat rows. Props:

```
KpiCard({
  required String value,
  required String label,
  required IconData icon,
  required Color color,
  String? delta,         // e.g. "+12%"
  bool? deltaPositive,
  VoidCallback? onTap,   // no-op-ready hook for drill-down
})
```

- Fixed `aspectRatio: 1.4` via `AspectRatio` (not a fixed height) → never overflows.
- Padding 16, radius 14, soft shadow (light) / hairline border (dark) — matches current.
- Icon chip top-left, delta chip top-right (animated in), value (DmSans 22 bold), label (Cairo 11 muted).
- Tap → ink ripple + `onTap` callback.

### 4.4 `KpiGrid` (new, replaces `KpiStrip` in the tab)

- `Wrap` or 2-column `GridView` with `aspectRatio` children. On widths > 600 (tablet/web), 3–4 columns.
- Receives 4 `KpiCard`s from the tab; the 4th is role-specific (passed in).

### 4.5 `TrendChart` (new)

- `fl_chart: ^0.69.0` `LineChart` with gradient fill below the line (`belowBarData`).
- X-axis: dates (day labels for week/month, month labels for allTime).
- Y-axis: hidden (clean look); optional soft gridlines.
- Line color = hero metric color (green for earnings, blue for weight).
- Empty state: "لا يوجد بيانات كافية" with a muted icon.
- Height 180, horizontal margin 16.

### 4.6 `WasteTypeBreakdown` (new)

- Horizontal stacked bar via `Row` of `Expanded(flex: share, child: ColoredBox)` — no extra dep.
- Below: legend (color dot + type label + percentage), wrapped, max 6 shown + "أخرى".
- Empty state if no weight.

### 4.7 `MaterialTimelineChart` (refine, keep)

- Add `RepaintBoundary` around the `CustomPaint`.
- Date labels: Arabic month abbreviations (reuse `ActivityRow._formatDate` logic).
- Touch: wrap in `GestureDetector` → `onTap` hook (no-op for now).
- Otherwise unchanged.

### 4.8 `ActivityRow` / `ActivityStatementList` (refine)

- Row gains a subtle status chip (e.g. "مكتمل" in green) on the right under the reward.
- Tap → `onTap` hook (no-op).
- List unchanged otherwise; keep `shrinkWrap: true` + `NeverScrollableScrollPhysics`.

### 4.9 `MilestoneStrip` (new, replaces `MilestoneGrid` in the tab)

- Horizontal `ListView`, achieved badges first (full color), locked ones dimmed at the end.
- Each badge: circular icon + label, 120px wide.
- Unlock pulse: if a milestone flipped to achieved this period, `flutter_animate` pulse on first build.

### 4.10 Per-role home stat rows (overflow fix)

`recycling_home_tab.dart::_buildStatsRow` (and the equivalent in driver/supplier home tabs if present) switches from `_StatCard`-in-`Expanded` to the new `KpiCard` inside a 2×2 `KpiGrid` (or a 4-in-a-row `KpiStrip`-style horizontal scroll if the home wants compact). Decision: home screens use **horizontal-scroll `KpiStrip` rebuilt on `KpiCard` v2** (compact, no overflow, consistent component), while the dedicated Analytics tab uses the **2×2 `KpiGrid`** (room for deltas). Same card component, two layouts.

## 5. Data Flow

```
RoleHomeView
  └─ AnalyticsTab(heroMetric, secondaryKpi, allOrders, ...)
       └─ ChangeNotifierProvider<AnalyticsViewModel>
            ├─ reads allOrders, computes period-filtered + previous-period + series + breakdown
            └─ AnalyticsHeroCard  (reads vm.heroValue[heroMetric], vm.delta...)
            └─ KpiGrid            (4 × KpiCard v2)
            └─ TrendChart         (reads vm.dailySeries)
            └─ WasteTypeBreakdown (reads vm.wasteBreakdown)
            └─ MaterialTimelineChart (reads vm.ganttOrders)
            └─ ActivityStatementList (reads vm.filteredOrders)
            └─ MilestoneStrip     (reads vm.totals)
            └─ ReportCenterSection (unchanged)
```

State stays in `AnalyticsViewModel` (already a `ChangeNotifier`). No new providers. Period changes call `vm.setPeriod()` → `notifyListeners()` → all sections rebuild.

## 6. Visual / Token Decisions

- **Hero gradient:** `AppColors.primaryGreen` → `AppColors.primaryDark` (already defined, already used by recycling header).
- **Delta positive:** `Color(0xFF16A34A)` green; **negative:** `Color(0xFFDC2626)` red; **null:** hide chip.
- **Card radius:** 14 (KPI), 16 (hero, chart containers) — matches existing.
- **Section spacing:** 24px between sections, 8px between header and content.
- **Fonts:** Cairo (Arabic labels), DmSans (numbers) — unchanged.
- **Animation:** `flutter_animate` (already a dep, already used in recycling tab). Durations: count-up 800ms, card fade+slide 300ms with 40ms stagger, delta chip 250ms.

## 7. Testing Strategy

- **Unit (`analytics_viewmodel_test.dart`):** extend with tests for `deltaEarningsPct` (positive/negative/null-when-prev-zero), `dailySeries` bucketing, `wasteBreakdown` share math, `previousPeriodOrders` windowing.
- **Widget:** `kpi_card_test.dart` (tap callback fires, delta shows/hides, no overflow at narrow width via `tester.binding.window.physicalSizeTestValue`), `analytics_hero_card_test.dart` (renders value, empty state), `waste_type_breakdown_test.dart` (legend renders, empty state).
- **Existing tests:** `material_timeline_chart_test.dart`, `period_selector_test.dart` must still pass.
- **Verification gate:** `flutter analyze` clean + `flutter test` green after each commit, per AGENTS.md §4.

## 8. File Impact Summary

**New:**
- `lib/ui/features/analytics/widgets/analytics_hero_card.dart`
- `lib/ui/features/analytics/widgets/kpi_grid.dart`
- `lib/ui/features/analytics/widgets/trend_chart.dart`
- `lib/ui/features/analytics/widgets/waste_type_breakdown.dart`
- `lib/ui/features/analytics/widgets/milestone_strip.dart`

**Rewritten:**
- `lib/ui/features/analytics/widgets/kpi_card.dart` (v2 — unified, tappable, aspect-ratio)
- `lib/ui/features/analytics/analytics_viewmodel.dart` (additive — deltas, series, breakdown)
- `lib/ui/features/analytics/analytics_tab.dart` (new layout)
- `lib/ui/features/analytics/widgets/kpi_strip.dart` (rebuilt on KpiCard v2, used by home screens)

**Refined:**
- `lib/ui/features/analytics/widgets/material_timeline_chart.dart` (RepaintBoundary, Arabic labels, tap hook)
- `lib/ui/features/analytics/widgets/activity_row.dart` (status chip, tap hook)
- `lib/ui/features/analytics/widgets/milestone_badge.dart` (extract reusable badge for the strip)

**Removed:**
- `lib/ui/features/analytics/widgets/milestone_grid.dart` (replaced by `milestone_strip.dart`; logic moves into the strip)

**Touched outside analytics (overflow fix):**
- `lib/ui/features/home/recycling/tabs/recycling_home_tab.dart` (`_buildStatsRow` → uses new `KpiStrip`/`KpiCard`)
- Driver / Supplier home tabs — only if they have an equivalent overflowing stat row; verify during implementation.

**Localization note:** all new Arabic strings are hardcoded in this phase (consistent with current analytics code). A follow-up l10n task will migrate them to ARB keys; tracked separately, flagged in PR review.

## 9. Out of Scope / Risks

- **Realtime report status** not added (Phase 2).
- **ARB migration** deferred — violates AGENTS.md §7 guideline, flagged for follow-up.
- **fl_chart API drift:** pin to `^0.69.0` already in pubspec; if API differs at build time, adapt.
- **Performance:** count-up + multiple animated sections on one screen — mitigate with `RepaintBoundary` on chart and list, and by animating only on first build / period change (not every rebuild).
