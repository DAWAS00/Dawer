# خُضَر Green Credits — Reward System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a green-credits (خُضَر) reward system to the Dawer Flutter app — earning logic triggered on order completion, persisted per user, and surfaced in the existing Analytics tab for all three roles.

**Architecture:** A pure-Dart `GreenCreditsService` computes credits per completed order (base + weight × material-multiplier × streak-bonus). `AppOrderStore.completeOrder()` calls the service and writes the balance to `LocalStore` (SharedPreferences). `AnalyticsTab` receives `greenPoints` as a plain `int` parameter and renders a `GreenLevelCard` widget. No new Providers needed.

**Tech Stack:** Flutter 3, Dart, SharedPreferences (existing `LocalStore`), Provider (existing), `fl_chart` not required (level progress is a `LinearProgressIndicator`).

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| **Create** | `lib/core/constants/green_credits_config.dart` | Material multipliers, level thresholds, redemption config |
| **Create** | `lib/data/services/green_credits_service.dart` | `creditsForOrder()` + static `weekStreakFrom()` |
| **Create** | `lib/domain/entities/green_level.dart` | `GreenLevel` enum + `GreenLevelInfo` extension |
| **Create** | `lib/ui/features/analytics/widgets/green_level_card.dart` | Widget: level badge + progress bar + خُضَر balance |
| **Create** | `test/data/services/green_credits_service_test.dart` | Unit tests for credits computation and streak |
| **Modify** | `lib/backend_integration_locally/local_store.dart` | Add `readGreenPoints(userId)` / `writeGreenPoints(userId, points)` |
| **Modify** | `lib/data/services/app_order_store.dart` | Store `_currentUserId`, award credits in `completeOrder()`, expose `greenPointsFor()` |
| **Modify** | `lib/ui/features/analytics/analytics_tab.dart` | Add `greenPoints: int` + `showGreenCredits: bool` params + section |
| **Modify** | `lib/ui/features/home/driver/driver_home_view.dart` | Pass `greenPoints` and `showGreenCredits: true` to `AnalyticsTab` |
| **Modify** | `lib/ui/features/home/supplier/individual_supplier_home_view.dart` | Same |
| **Modify** | `lib/ui/features/home/recycling/recycling_home_view.dart` | Same |

---

## Task 1: GreenCreditsConfig

**Files:**
- Create: `lib/core/constants/green_credits_config.dart`

- [ ] **Step 1: Create the config file**

```dart
// lib/core/constants/green_credits_config.dart

import '../../data/models/order/order.dart' show WasteType;

/// All tunable numbers for the خُضَر green-credits reward system.
///
/// Change values here only — never scatter magic numbers across the codebase.
class GreenCreditsConfig {
  GreenCreditsConfig._();

  // ── Earning ──────────────────────────────────────────────────────────────

  /// Flat credits earned for every completed order, regardless of material.
  static const int baseCreditsPerOrder = 10;

  /// Credits earned per kilogram of waste in the order.
  static const double creditsPerKg = 1.0;

  /// Per-material multiplier applied to (base + weightBonus).
  /// Higher = rarer / harder to recycle.
  static const Map<WasteType, double> materialMultiplier = {
    WasteType.electronics:     5.0,
    WasteType.batteries:       5.0,
    WasteType.chemicals:       4.0,
    WasteType.copperAluminium: 3.0,
    WasteType.oil:             3.0,
    WasteType.tires:           2.5,
    WasteType.rubber:          2.0,
    WasteType.metal:           2.0,
    WasteType.furniture:       1.5,
    WasteType.glass:           1.5,
    WasteType.construction:    1.5,
    WasteType.wood:            1.2,
    WasteType.textile:         1.2,
    WasteType.plastic:         1.0,
    WasteType.paper:           1.0,
    WasteType.organic:         1.0,
  };

  /// Bonus multiplier applied on top of earned credits based on consecutive
  /// week streak (weeks with at least one completed order).
  static double streakMultiplier(int weekStreak) {
    if (weekStreak >= 8) return 2.0;   // 8+ weeks → 2×
    if (weekStreak >= 4) return 1.5;   // 4–7 weeks → 1.5×
    if (weekStreak >= 2) return 1.25;  // 2–3 weeks → 1.25×
    return 1.0;                        // 0–1 weeks → no bonus
  }

  // ── Level thresholds (cumulative green points) ───────────────────────────

  static const int saplingThreshold        =  500;
  static const int treeThreshold           = 2000;
  static const int forestGuardianThreshold = 5000;

  // ── Redemption ───────────────────────────────────────────────────────────

  /// Every [redeemThreshold] خُضَر earned → [redeemJd] JD credit off next invoice.
  static const int    redeemThreshold = 500;
  static const double redeemJd        = 5.0;
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd path/to/dwaar && flutter analyze lib/core/constants/green_credits_config.dart
```

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/green_credits_config.dart
git commit -m "feat(credits): add GreenCreditsConfig with material multipliers and level thresholds"
```

---

## Task 2: GreenCreditsService + Tests

**Files:**
- Create: `lib/data/services/green_credits_service.dart`
- Create: `test/data/services/green_credits_service_test.dart`

- [ ] **Step 1: Write the failing tests first**

```dart
// test/data/services/green_credits_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/core/constants/green_credits_config.dart';
import 'package:dwaar/data/models/order/order.dart'
    show Order, OrderStatus, WasteType, OrderType;
import 'package:dwaar/data/services/green_credits_service.dart';

Order _makeOrder({
  List<WasteType> wasteTypes = const [WasteType.plastic],
  double? weightKg,
  double? estimatedWeightKg = 10.0,
  OrderStatus status = OrderStatus.completed,
  DateTime? completedAt,
}) =>
    Order(
      id: 'test-${DateTime.now().microsecondsSinceEpoch}',
      status: status,
      orderType: OrderType.pickup,
      wasteTypes: wasteTypes,
      weightKg: weightKg,
      estimatedWeightKg: estimatedWeightKg,
      createdAt: completedAt?.subtract(const Duration(hours: 2)) ??
          DateTime(2026, 1, 6, 10), // Monday
      completedAt: completedAt ?? DateTime(2026, 1, 6, 12),
      supplierName: 'مطعم الوطن',
    );

void main() {
  const service = GreenCreditsService();

  group('GreenCreditsService.creditsForOrder', () {
    test('base order with 10 kg plastic earns base + weight × 1.0 multiplier', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 base + 10 kg × 1.0 perKg) × 1.0 material × 1.0 streak = 20
      expect(service.creditsForOrder(order), equals(20));
    });

    test('uses highest material multiplier when multiple waste types present', () {
      final order = _makeOrder(
        wasteTypes: [WasteType.plastic, WasteType.electronics],
        weightKg: 10.0,
      );
      // electronics = 5×, plastic = 1× → highest is 5×
      // (10 + 10) × 5.0 = 100
      expect(service.creditsForOrder(order), equals(100));
    });

    test('oil pickup earns 3× multiplier', () {
      final order = _makeOrder(wasteTypes: [WasteType.oil], weightKg: 0.0);
      // (10 + 0) × 3.0 × 1.0 = 30
      expect(service.creditsForOrder(order), equals(30));
    });

    test('electronics earns 5× multiplier', () {
      final order = _makeOrder(wasteTypes: [WasteType.electronics], weightKg: 0.0);
      // (10 + 0) × 5.0 × 1.0 = 50
      expect(service.creditsForOrder(order), equals(50));
    });

    test('falls back to estimatedWeightKg when weightKg is null', () {
      final order = _makeOrder(
        wasteTypes: [WasteType.paper],
        weightKg: null,
        estimatedWeightKg: 20.0,
      );
      // (10 + 20) × 1.0 × 1.0 = 30
      expect(service.creditsForOrder(order), equals(30));
    });

    test('2-week streak applies 1.25× streak bonus', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 + 10) × 1.0 material × 1.25 streak = 25
      expect(service.creditsForOrder(order, weekStreak: 2), equals(25));
    });

    test('4-week streak applies 1.5× streak bonus', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 + 10) × 1.0 × 1.5 = 30
      expect(service.creditsForOrder(order, weekStreak: 4), equals(30));
    });

    test('8-week streak applies 2.0× streak bonus', () {
      final order = _makeOrder(wasteTypes: [WasteType.plastic], weightKg: 10.0);
      // (10 + 10) × 1.0 × 2.0 = 40
      expect(service.creditsForOrder(order, weekStreak: 8), equals(40));
    });

    test('zero weight with empty wasteTypes returns base credits (clamped to 1 minimum)', () {
      final order = _makeOrder(
        wasteTypes: [],
        weightKg: 0.0,
        estimatedWeightKg: 0.0,
      );
      // (10 + 0) × 1.0 × 1.0 = 10
      expect(service.creditsForOrder(order), equals(10));
    });

    test('result is always at least 1', () {
      final order = _makeOrder(
        wasteTypes: [WasteType.organic],
        weightKg: 0.0,
        estimatedWeightKg: 0.0,
      );
      expect(service.creditsForOrder(order), greaterThanOrEqualTo(1));
    });
  });

  group('GreenCreditsService.weekStreakFrom', () {
    // Reference date: we use completedAt to determine the week
    // Week 1 = 2026-01-05 (Mon) to 2026-01-11 (Sun)
    // Week 2 = 2026-01-12 (Mon) to 2026-01-18 (Sun)
    // Week 3 = 2026-01-19 (Mon) to 2026-01-25 (Sun)

    test('returns 0 for empty order list', () {
      expect(GreenCreditsService.weekStreakFrom([]), equals(0));
    });

    test('returns 0 when no completed orders', () {
      final orders = [
        _makeOrder(status: OrderStatus.pending, completedAt: null),
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(0));
    });

    test('returns 1 for a single completed order this week', () {
      // "now" is determined by the latest completedAt in the list.
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)), // Week 1
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(1));
    });

    test('returns 2 for orders in two consecutive weeks', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)),  // Week 1
        _makeOrder(completedAt: DateTime(2026, 1, 13, 10)), // Week 2
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(2));
    });

    test('returns 3 for three consecutive weeks', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)),  // Week 1
        _makeOrder(completedAt: DateTime(2026, 1, 13, 10)), // Week 2
        _makeOrder(completedAt: DateTime(2026, 1, 20, 10)), // Week 3
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(3));
    });

    test('resets streak when a week is skipped', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)),  // Week 1
        // Week 2 skipped
        _makeOrder(completedAt: DateTime(2026, 1, 20, 10)), // Week 3
      ];
      // Only week 3 is the "end" — week 2 is missing so streak = 1
      expect(GreenCreditsService.weekStreakFrom(orders), equals(1));
    });

    test('multiple orders in same week count as 1 week', () {
      final orders = [
        _makeOrder(completedAt: DateTime(2026, 1, 6, 10)),  // Week 1, Monday
        _makeOrder(completedAt: DateTime(2026, 1, 8, 14)),  // Week 1, Wednesday
        _makeOrder(completedAt: DateTime(2026, 1, 13, 10)), // Week 2
      ];
      expect(GreenCreditsService.weekStreakFrom(orders), equals(2));
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL with "GreenCreditsService not found"**

```bash
flutter test test/data/services/green_credits_service_test.dart --no-pub
```

Expected: compilation error — `GreenCreditsService` doesn't exist yet.

- [ ] **Step 3: Implement GreenCreditsService**

```dart
// lib/data/services/green_credits_service.dart

import '../../core/constants/green_credits_config.dart';
import '../models/order/order.dart' show Order, OrderStatus, WasteType;

/// Computes خُضَر green credits earned for a completed order.
///
/// Stateless and const-constructible — safe to store as a final field.
class GreenCreditsService {
  const GreenCreditsService();

  /// Returns the number of خُضَر credits earned for [order].
  ///
  /// [weekStreak] — consecutive weeks ending at the current week where the
  /// user had at least one completed order. Computed by [weekStreakFrom].
  int creditsForOrder(Order order, {int weekStreak = 0}) {
    final weight = order.weightKg ?? order.estimatedWeightKg ?? 0.0;

    // 1. Base flat credit per order
    final base = GreenCreditsConfig.baseCreditsPerOrder.toDouble();

    // 2. Weight bonus
    final weightBonus = weight * GreenCreditsConfig.creditsPerKg;

    // 3. Highest material multiplier across all waste types in the order
    final materialMult = _highestMaterialMultiplier(order.wasteTypes);

    // 4. Streak multiplier
    final streakMult = GreenCreditsConfig.streakMultiplier(weekStreak);

    // 5. Formula: (base + weightBonus) × materialMult × streakMult
    final raw = (base + weightBonus) * materialMult * streakMult;

    return raw.round().clamp(1, 9999);
  }

  /// Computes the consecutive-WEEK streak ending at the most recent
  /// completed order in [completedOrders].
  ///
  /// A "week" is defined as Mon–Sun (ISO week). A week "counts" if at least
  /// one order in [completedOrders] has a `completedAt` inside that week.
  /// Streak breaks at the first missing week when counting backwards.
  static int weekStreakFrom(List<Order> completedOrders) {
    final dones = completedOrders
        .where((o) =>
            o.status == OrderStatus.completed && o.completedAt != null)
        .toList();

    if (dones.isEmpty) return 0;

    // Collect the set of (year, isoWeek) tuples that have at least one order.
    final weeks = <(int, int)>{};
    for (final o in dones) {
      final dt = o.completedAt!;
      weeks.add((_isoYear(dt), _isoWeek(dt)));
    }

    // Find the most recent week
    final sorted = weeks.toList()
      ..sort((a, b) {
        final yearCmp = b.$1.compareTo(a.$1);
        return yearCmp != 0 ? yearCmp : b.$2.compareTo(a.$2);
      });

    // Count backwards from the latest week
    var streak = 1;
    var current = sorted.first;
    for (var i = 1; i < sorted.length; i++) {
      final prev = _previousIsoWeek(current);
      if (sorted[i] == prev) {
        streak++;
        current = prev;
      } else {
        break;
      }
    }
    return streak;
  }

  double _highestMaterialMultiplier(List<WasteType> types) {
    if (types.isEmpty) return 1.0;
    return types
        .map((t) => GreenCreditsConfig.materialMultiplier[t] ?? 1.0)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Returns the ISO week number (1–53) for [dt].
  static int _isoWeek(DateTime dt) {
    // ISO week: week containing the first Thursday of the year.
    final dayOfYear = dt.difference(DateTime(dt.year, 1, 1)).inDays + 1;
    // Day-of-week: Mon=1, Sun=7
    final dow = dt.weekday; // Dart: Mon=1, Sun=7
    final weekNumber = ((dayOfYear - dow + 10) / 7).floor();
    if (weekNumber < 1) return _isoWeek(DateTime(dt.year - 1, 12, 28));
    if (weekNumber > 52) {
      // Could be week 53 or week 1 of next year
      final jan1Next = DateTime(dt.year + 1, 1, 1).weekday;
      if (jan1Next <= 4) return 1; // week 1 of next year
    }
    return weekNumber;
  }

  /// Returns the ISO year for [dt] (may differ from calendar year in Jan/Dec).
  static int _isoYear(DateTime dt) {
    final week = _isoWeek(dt);
    if (week >= 52 && dt.month == 1) return dt.year - 1;
    if (week == 1 && dt.month == 12) return dt.year + 1;
    return dt.year;
  }

  /// Returns the (year, week) tuple of the week immediately before [yw].
  static (int, int) _previousIsoWeek((int, int) yw) {
    final (year, week) = yw;
    if (week > 1) return (year, week - 1);
    // Week 1 → last week of previous year (52 or 53)
    final dec28 = DateTime(year - 1, 12, 28);
    return (year - 1, _isoWeek(dec28));
  }
}
```

- [ ] **Step 4: Run tests — expect ALL PASS**

```bash
flutter test test/data/services/green_credits_service_test.dart --no-pub
```

Expected output: `All tests passed!` (15 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/data/services/green_credits_service.dart \
        test/data/services/green_credits_service_test.dart
git commit -m "feat(credits): add GreenCreditsService with material multipliers and week-streak computation"
```

---

## Task 3: GreenLevel Entity

**Files:**
- Create: `lib/domain/entities/green_level.dart`

- [ ] **Step 1: Create the file**

```dart
// lib/domain/entities/green_level.dart

import '../../core/constants/green_credits_config.dart';

/// The four experience levels in the خُضَر reward ladder.
enum GreenLevel {
  seedling,       // 0 – 499 خُضَر
  sapling,        // 500 – 1999 خُضَر
  tree,           // 2000 – 4999 خُضَر
  forestGuardian, // 5000+ خُضَر
}

extension GreenLevelInfo on GreenLevel {
  /// Arabic display name shown in the level badge.
  String get arabicLabel => switch (this) {
        GreenLevel.seedling       => 'شتلة',
        GreenLevel.sapling        => 'غرسة',
        GreenLevel.tree           => 'شجرة',
        GreenLevel.forestGuardian => 'حارس الغابة',
      };

  /// Emoji prefix for the level badge.
  String get emoji => switch (this) {
        GreenLevel.seedling       => '🌱',
        GreenLevel.sapling        => '🌿',
        GreenLevel.tree           => '🌳',
        GreenLevel.forestGuardian => '🌍',
      };

  /// One-line description of the unlock benefit at this level.
  String get unlockDescription => switch (this) {
        GreenLevel.seedling       => 'تطابق معياري',
        GreenLevel.sapling        => 'أولوية المطابقة مع السائقين',
        GreenLevel.tree           => 'الوصول إلى وظائف السوق المتميزة',
        GreenLevel.forestGuardian => 'خصم رسوم المنصة + شهادة CO₂',
      };

  /// Points required to enter the NEXT level.
  /// Returns [GreenCreditsConfig.forestGuardianThreshold] when already at max.
  int get nextThreshold => switch (this) {
        GreenLevel.seedling       => GreenCreditsConfig.saplingThreshold,
        GreenLevel.sapling        => GreenCreditsConfig.treeThreshold,
        GreenLevel.tree           => GreenCreditsConfig.forestGuardianThreshold,
        GreenLevel.forestGuardian => GreenCreditsConfig.forestGuardianThreshold,
      };

  /// Points at which THIS level begins (lower bound, inclusive).
  int get lowerThreshold => switch (this) {
        GreenLevel.seedling       => 0,
        GreenLevel.sapling        => GreenCreditsConfig.saplingThreshold,
        GreenLevel.tree           => GreenCreditsConfig.treeThreshold,
        GreenLevel.forestGuardian => GreenCreditsConfig.forestGuardianThreshold,
      };

  bool get isMaxLevel => this == GreenLevel.forestGuardian;

  /// Derive the level from a raw خُضَر balance.
  static GreenLevel fromPoints(int points) {
    if (points >= GreenCreditsConfig.forestGuardianThreshold) return GreenLevel.forestGuardian;
    if (points >= GreenCreditsConfig.treeThreshold)           return GreenLevel.tree;
    if (points >= GreenCreditsConfig.saplingThreshold)        return GreenLevel.sapling;
    return GreenLevel.seedling;
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/domain/entities/green_level.dart
```

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/entities/green_level.dart
git commit -m "feat(credits): add GreenLevel enum with level thresholds and Arabic labels"
```

---

## Task 4: LocalStore Green Points Persistence

**Files:**
- Modify: `lib/backend_integration_locally/local_store.dart`

The file currently has `_usersKey`, `_ordersKey`, etc. as `static const String` keys and uses `SharedPreferences`. We add two methods at the end of the `// ── Users` section.

- [ ] **Step 1: Add the key constant** — after line 23 (`static const String _firstLaunchKey = 'dwaar_first_launch_done';`), add:

```dart
  static const String _greenPointsKeyPrefix = 'dwaar_green_points_';
```

- [ ] **Step 2: Add the two persistence methods** — add them after the `clearAllUsers()` method (after line ~40):

```dart
  // ── Green Credits ─────────────────────────────────────────────────────────

  /// Reads the cached خُضَر balance for [userId]. Returns 0 if never written.
  int readGreenPoints(String userId) =>
      _prefs.getInt('$_greenPointsKeyPrefix$userId') ?? 0;

  /// Persists [points] as the خُضَر balance for [userId].
  Future<void> writeGreenPoints(String userId, int points) async {
    await _prefs.setInt('$_greenPointsKeyPrefix$userId', points);
  }
```

- [ ] **Step 3: Verify it compiles**

```bash
flutter analyze lib/backend_integration_locally/local_store.dart
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/backend_integration_locally/local_store.dart
git commit -m "feat(credits): add readGreenPoints/writeGreenPoints to LocalStore"
```

---

## Task 5: AppOrderStore Integration

**Files:**
- Modify: `lib/data/services/app_order_store.dart`

This is the core wiring task. Make four changes to the file in order.

**Change 1 — Add imports** at the top of the file (after existing imports):

- [ ] **Step 1: Add imports**

Find the import block (starts at line 1). After the last existing import, add:

```dart
import '../../domain/entities/green_level.dart';
import 'green_credits_service.dart';
```

**Change 2 — Add three new fields** in the class body, after the existing `final bool _skipMockSeed;` field declaration (around line 36):

- [ ] **Step 2: Add fields**

```dart
  // ── Green Credits ─────────────────────────────────────────────────────────
  String? _currentUserId;
  final Map<String, int> _greenPointsMap = {};
  final GreenCreditsService _greenCreditsService = const GreenCreditsService();
```

**Change 3 — Store userId in `configureForUser()`** — the method currently starts at line ~139:

- [ ] **Step 3: Store userId**

Locate the `configureForUser(String userId, UserRole role)` method body. After the line `_remoteSub?.cancel();` and BEFORE `_remoteSub = _remote.watchOrdersForUser(...)`, add:

```dart
    _currentUserId = userId;
    // Load persisted green points for this user
    if (_store != null) {
      _greenPointsMap[userId] = _store!.readGreenPoints(userId);
    }
```

**Change 4 — Expose getter and add award method**. Add these two items after the existing `bool get driverHasActiveOrder` getter (around line ~213):

- [ ] **Step 4: Add greenPointsFor getter and _awardGreenCredits method**

```dart
  // ── Green Credits ─────────────────────────────────────────────────────────

  /// Returns the current خُضَر balance for [userId].
  /// Returns 0 if the user has not earned any credits yet.
  int greenPointsFor(String userId) => _greenPointsMap[userId] ?? 0;

  /// Returns the [GreenLevel] for [userId] based on their current balance.
  GreenLevel greenLevelFor(String userId) =>
      GreenLevelInfo.fromPoints(greenPointsFor(userId));

  Future<void> _awardGreenCredits(Order order) async {
    final uid = _currentUserId;
    if (uid == null) return;

    // Compute week streak from orders the current driver has completed.
    final driverCompleted = _orders
        .where((o) =>
            _driverCompletedIds.contains(o.id) && o.completedAt != null)
        .toList();
    final streak = GreenCreditsService.weekStreakFrom(driverCompleted);

    // Award credits to the driver (current user)
    final driverEarned =
        _greenCreditsService.creditsForOrder(order, weekStreak: streak);
    _greenPointsMap[uid] = (_greenPointsMap[uid] ?? 0) + driverEarned;
    unawaited(_store?.writeGreenPoints(uid, _greenPointsMap[uid]!));

    // Also award credits to the supplier who recycled the waste.
    final supplierId = order.supplierId;
    if (supplierId != null && supplierId.isNotEmpty && supplierId != uid) {
      if (!_greenPointsMap.containsKey(supplierId)) {
        _greenPointsMap[supplierId] =
            _store?.readGreenPoints(supplierId) ?? 0;
      }
      // Supplier earns base credits (no streak bonus — streak is driver-side)
      final supplierEarned = _greenCreditsService.creditsForOrder(order);
      _greenPointsMap[supplierId] =
          _greenPointsMap[supplierId]! + supplierEarned;
      unawaited(
          _store?.writeGreenPoints(supplierId, _greenPointsMap[supplierId]!));
    }

    notifyListeners();
  }
```

**Change 5 — Hook into `completeOrder()`**. The method is around line 444. After the line:

```dart
    unawaited(_recordTransactionFor(completedOrder));
```

Add:

- [ ] **Step 5: Hook _awardGreenCredits into completeOrder**

```dart
    unawaited(_awardGreenCredits(completedOrder));
```

- [ ] **Step 6: Verify the full file compiles**

```bash
flutter analyze lib/data/services/app_order_store.dart
```

Expected: no issues.

- [ ] **Step 7: Run existing AppOrderStore tests to confirm nothing is broken**

```bash
flutter test test/data/app_order_store_test.dart \
             test/data/app_order_store_lifecycle_test.dart \
             test/data/app_order_store_persistence_test.dart --no-pub
```

Expected: all pass.

- [ ] **Step 8: Commit**

```bash
git add lib/data/services/app_order_store.dart
git commit -m "feat(credits): award خُضَر credits in AppOrderStore.completeOrder, expose greenPointsFor getter"
```

---

## Task 6: GreenLevelCard Widget

**Files:**
- Create: `lib/ui/features/analytics/widgets/green_level_card.dart`

- [ ] **Step 1: Create the widget**

```dart
// lib/ui/features/analytics/widgets/green_level_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/green_level.dart';

/// Displays a user's خُضَر balance, level badge (emoji + Arabic name),
/// unlock benefit text, and a progress bar toward the next level.
///
/// Intended to be placed inside the Analytics tab's CustomScrollView.
class GreenLevelCard extends StatelessWidget {
  const GreenLevelCard({
    super.key,
    required this.greenPoints,
  });

  /// The user's current cumulative خُضَر balance.
  final int greenPoints;

  @override
  Widget build(BuildContext context) {
    final level = GreenLevelInfo.fromPoints(greenPoints);
    final progress = level.isMaxLevel
        ? 1.0
        : ((greenPoints - level.lowerThreshold) /
               (level.nextThreshold - level.lowerThreshold))
            .clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Emoji badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  level.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              // Level name + unlock description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.arabicLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.unlockDescription,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // خُضَر balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$greenPoints',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    'خُضَر',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.13),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 6),
          // Progress label
          Text(
            level.isMaxLevel
                ? 'وصلت للمستوى الأعلى 🎉'
                : '$greenPoints / ${level.nextThreshold} للمستوى التالي',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: level.isMaxLevel
                  ? AppColors.primaryGreen
                  : AppColors.mutedText,
              fontWeight: level.isMaxLevel
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/ui/features/analytics/widgets/green_level_card.dart
```

Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/ui/features/analytics/widgets/green_level_card.dart
git commit -m "feat(credits): add GreenLevelCard widget with level badge and progress bar"
```

---

## Task 7: Analytics Tab Integration

**Files:**
- Modify: `lib/ui/features/analytics/analytics_tab.dart`

The `AnalyticsTab` class currently has these constructor params:
`userId`, `allOrders`, `reportRepository`, `heroMetric`, `roleKpi`, `showMilestones`, `showReportCenter`, `showCycleTime`, `showProfitability`, `showEarningsEfficiency`.

We add two new params and a new section.

**Change 1 — Add import** at the top of `analytics_tab.dart`, after the last existing import (`widgets/waste_type_breakdown.dart`):

- [ ] **Step 1: Add import**

```dart
import 'widgets/green_level_card.dart';
```

**Change 2 — Add two new params to `AnalyticsTab`** — in the `AnalyticsTab` class constructor, after `showEarningsEfficiency`:

- [ ] **Step 2: Add params to AnalyticsTab**

```dart
  /// The user's current خُضَر balance. Shown as a GreenLevelCard section.
  final int greenPoints;

  /// Whether to show the green credits section. Set to true for all roles.
  final bool showGreenCredits;
```

And update the constructor default values:

```dart
  const AnalyticsTab({
    super.key,
    required this.userId,
    required this.allOrders,
    required this.reportRepository,
    this.heroMetric = HeroMetric.earnings,
    this.roleKpi,
    this.showMilestones = true,
    this.showReportCenter = false,
    this.showCycleTime = false,
    this.showProfitability = false,
    this.showEarningsEfficiency = false,
    this.greenPoints = 0,             // ← add this
    this.showGreenCredits = false,    // ← add this
  });
```

**Change 3 — Pass new params through to `_AnalyticsTabBody`** — in `AnalyticsTab.build()`, add to the `_AnalyticsTabBody(...)` constructor call:

- [ ] **Step 3: Pass params to body**

```dart
        greenPoints: greenPoints,
        showGreenCredits: showGreenCredits,
```

**Change 4 — Add the same fields to `_AnalyticsTabBody`**:

- [ ] **Step 4: Add fields to _AnalyticsTabBody**

In `_AnalyticsTabBody`, add after `showEarningsEfficiency`:

```dart
  final int greenPoints;
  final bool showGreenCredits;
```

And update its constructor:

```dart
  const _AnalyticsTabBody({
    required this.userId,
    required this.reportRepository,
    required this.heroMetric,
    required this.roleKpi,
    required this.showMilestones,
    required this.showReportCenter,
    required this.showCycleTime,
    required this.showProfitability,
    required this.showEarningsEfficiency,
    required this.greenPoints,          // ← add
    required this.showGreenCredits,     // ← add
  });
```

**Change 5 — Add GreenLevelCard section in `_AnalyticsTabBody.build()`**. In the `Column` inside `SliverToBoxAdapter`, after the `// ── KPI grid` section (after `const SizedBox(height: 28),` that follows `KpiGrid`), add:

- [ ] **Step 5: Insert GreenLevelCard section into the build method**

```dart
              // ── Green Credits Level ────────────────────────────────────
              if (showGreenCredits) ...[
                _SectionHeader(title: 'مستوى خُضَر'),
                GreenLevelCard(greenPoints: greenPoints),
                const SizedBox(height: 28),
              ],
```

- [ ] **Step 6: Verify it compiles**

```bash
flutter analyze lib/ui/features/analytics/analytics_tab.dart
```

Expected: no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/ui/features/analytics/analytics_tab.dart
git commit -m "feat(credits): add greenPoints + showGreenCredits params to AnalyticsTab, render GreenLevelCard section"
```

---

## Task 8: Wire Role Home Views

All three home views already have `AnalyticsTab(...)` calls. We pass `greenPoints` from `AppOrderStore.greenPointsFor(userId)` and set `showGreenCredits: true`.

The `userId` is already available in each home view via `context.read<IAuthRepository>().currentSession?.userId ?? ''`.

**Files:**
- Modify: `lib/ui/features/home/driver/driver_home_view.dart`
- Modify: `lib/ui/features/home/supplier/individual_supplier_home_view.dart`
- Modify: `lib/ui/features/home/recycling/recycling_home_view.dart`

### 8A — Driver home view

- [ ] **Step 1: Update the AnalyticsTab call in driver_home_view.dart**

Locate the existing `AnalyticsTab(...)` block (currently lines ~166–175 in the `tabs` list):

```dart
      AnalyticsTab(
        userId: context.read<IAuthRepository>().currentSession?.userId ?? '',
        allOrders: vm.history,
        reportRepository: context.read<IReportRequestRepository>(),
        showMilestones: true,
        showReportCenter: false,
        showCycleTime: true,
        showEarningsEfficiency: true,
      ),
```

Replace with:

```dart
      AnalyticsTab(
        userId: context.read<IAuthRepository>().currentSession?.userId ?? '',
        allOrders: vm.history,
        reportRepository: context.read<IReportRequestRepository>(),
        showMilestones: true,
        showReportCenter: false,
        showCycleTime: true,
        showEarningsEfficiency: true,
        showGreenCredits: true,
        greenPoints: context.read<AppOrderStore>().greenPointsFor(
              context.read<IAuthRepository>().currentSession?.userId ?? '',
            ),
      ),
```

- [ ] **Step 2: Verify driver home compiles**

```bash
flutter analyze lib/ui/features/home/driver/driver_home_view.dart
```

### 8B — Supplier home view

- [ ] **Step 3: Update the AnalyticsTab call in individual_supplier_home_view.dart**

Locate the existing block:

```dart
      AnalyticsTab(
        userId: context.read<IAuthRepository>().currentSession?.userId ?? '',
        allOrders: context.read<AppOrderStore>().supplierCompletedOrdersFor(vm.user.name),
        reportRepository: context.read<IReportRequestRepository>(),
```

Add after the last existing named param:

```dart
        showGreenCredits: true,
        greenPoints: context.read<AppOrderStore>().greenPointsFor(
              context.read<IAuthRepository>().currentSession?.userId ?? '',
            ),
```

- [ ] **Step 4: Verify supplier home compiles**

```bash
flutter analyze lib/ui/features/home/supplier/individual_supplier_home_view.dart
```

### 8C — RecyclingCo home view

- [ ] **Step 5: Update the AnalyticsTab call in recycling_home_view.dart**

Locate the existing block:

```dart
      AnalyticsTab(
        userId: context.read<IAuthRepository>().currentSession?.userId ?? '',
        allOrders: [...vm.incoming, ...vm.jobs],
        reportRepository: context.read<IReportRequestRepository>(),
```

Add after the last existing named param:

```dart
        showGreenCredits: true,
        greenPoints: context.read<AppOrderStore>().greenPointsFor(
              context.read<IAuthRepository>().currentSession?.userId ?? '',
            ),
```

- [ ] **Step 6: Verify recycling home compiles**

```bash
flutter analyze lib/ui/features/home/recycling/recycling_home_view.dart
```

- [ ] **Step 7: Run the full test suite**

```bash
flutter test --no-pub
```

Expected: all existing tests pass + 15 new GreenCreditsService tests pass.

- [ ] **Step 8: Run the app and manually test**

```bash
flutter run
```

Manual checks:
1. Log in as a driver.
2. Complete an order (or use the DevTestingPanel to trigger `completeOrder`).
3. Navigate to the Analytics tab (tab index 3).
4. Scroll down past the KPI grid — you should see "مستوى خُضَر" section header and the `GreenLevelCard`.
5. Confirm the خُضَر balance is > 0.
6. Kill and restart the app — confirm the balance persisted.

- [ ] **Step 9: Commit**

```bash
git add lib/ui/features/home/driver/driver_home_view.dart \
        lib/ui/features/home/supplier/individual_supplier_home_view.dart \
        lib/ui/features/home/recycling/recycling_home_view.dart
git commit -m "feat(credits): wire greenPoints from AppOrderStore into AnalyticsTab for all three roles"
```

---

## Self-Review

### Spec coverage

| Requirement | Covered by |
|---|---|
| Material multiplier (oil×3, electronics×5) | Task 1 config + Task 2 service |
| Weekly streak bonus | Task 2 `weekStreakFrom()` + Task 5 `_awardGreenCredits()` |
| Both driver AND supplier earn credits | Task 5 `_awardGreenCredits()` — awards to `uid` + `order.supplierId` |
| Credits persist across app restarts | Task 4 LocalStore + Task 5 `writeGreenPoints()` |
| Level badge visible in Analytics tab | Tasks 3, 6, 7 |
| All 3 roles show green credits | Task 8 (driver + supplier + recycling) |
| No new Providers needed | Confirmed — reads direct from `AppOrderStore` via `context.read<>()` |

### Type consistency

- `GreenLevelInfo.fromPoints()` is a static method — used correctly in `GreenLevelCard` as `GreenLevelInfo.fromPoints(greenPoints)` ✓
- `GreenCreditsService.weekStreakFrom()` is a static method — called as `GreenCreditsService.weekStreakFrom(driverCompleted)` ✓
- `LocalStore.writeGreenPoints(userId, int)` — called as `_store?.writeGreenPoints(uid, _greenPointsMap[uid]!)` ✓
- `AppOrderStore.greenPointsFor(String)` — called as `context.read<AppOrderStore>().greenPointsFor(userId)` ✓

---

## Dashboard Changes (Minimal — Tell Don't Implement)

The `green_points` column already exists in the `users` Supabase table (deployed in Phase 1). The dashboard's `useClients.ts` hook already fetches partner data. The **only change needed** in the React admin dashboard is:

**File:** `src/features/partners/PartnersTable.tsx` (or wherever the partner table is rendered)

**What to add:** A "المستوى" (Level) column showing the tier badge based on `green_points`:

```tsx
// Inside the partners table columns definition:
{
  header: 'المستوى',
  cell: ({ row }) => {
    const pts = row.original.greenPoints ?? 0;
    const { emoji, label } = greenLevelFrom(pts); // pure function — see below
    return (
      <span style={{ fontFamily: 'var(--font-arabic)', display: 'flex', gap: '4px', alignItems: 'center' }}>
        {emoji} <span>{label}</span>
      </span>
    );
  },
}

// Pure helper (add to src/lib/greenLevel.ts):
export function greenLevelFrom(points: number) {
  if (points >= 5000) return { emoji: '🌍', label: 'حارس الغابة' };
  if (points >= 2000) return { emoji: '🌳', label: 'شجرة' };
  if (points >= 500)  return { emoji: '🌿', label: 'غرسة' };
  return { emoji: '🌱', label: 'شتلة' };
}
```

**That's the only dashboard change.** The `awardPoints()` function already exists in `useClients.ts` and already updates `green_points` in Supabase — no changes needed there. The Realtime subscription on `users` already invalidates the partners query when points change.

---

## Execution Options

Plan saved to `devPlans/2026-06-29-green-credits-reward-system.md`.

**Option 1 — Subagent-Driven (recommended):** Dispatch a fresh subagent per task. Fast iteration, each task reviewed before the next starts.

**Option 2 — Inline Execution:** Execute all tasks in this session with checkpoints after Tasks 2, 5, and 8.

Which approach?
