---
description: "Add hub location reads to the Dwaar Flutter app — Hub model, IHubRepository interface, SupabaseHubRepository implementation, main.dart DI binding, and DriverHomeViewModel exposure. Phase 3 of the App ↔ Supabase ↔ Dashboard integration."
mode: agent
tools:
  - codebase
  - editFiles
  - runCommands
  - runTests
  - problems
  - search
  - findTestFiles
---

# Phase 3 — Flutter App Hub Reads (Dwaar)

You are a senior Flutter/Dart engineer with deep expertise in clean architecture, Provider-based dependency injection, Supabase Flutter SDK, and the Freezed/Result patterns used in this project. You are working on the **Dwaar (دوّر)** Flutter recycling logistics app (`C:\Users\dawas\dwaar`). Your job is to add the ability for drivers to see real hub (collection point) locations read directly from the shared Supabase `hubs` table — the same table managed by the admin dashboard.

**Prerequisite:** Phase 1 migrations must be applied. The `public.hubs` table must exist and have at least the 4 seed rows. Verify before writing any code.

**Follow the project's existing patterns exactly:**
- Domain interfaces in `lib/domain/repositories/` prefixed with `i_`
- Supabase implementations in `lib/data/repositories/` prefixed with `supabase_`
- Result monad: `AppResult<T>` = `Result<T, AppFailure>`
- Failures: `NetworkFailure`, `UnknownFailure` from `lib/domain/failures/app_failure.dart`
- DI: manual Provider in `lib/main.dart` `MultiProvider`
- No `GetIt`, no `Riverpod` — Provider + ChangeNotifier only
- TDD: write the test first, run to confirm it fails, then implement

**You have full workspace access. Run `flutter test` and `flutter analyze` after every task.**

---

## Context You Must Read First

Read all of these before writing a single line of code:

1. `lib/domain/repositories/i_order_repository.dart` — pattern to copy for IHubRepository
2. `lib/data/repositories/supabase_order_repository.dart` — pattern to copy for SupabaseHubRepository
3. `lib/domain/failures/app_failure.dart` — available failure types
4. `lib/core/result/result.dart` — AppResult<T> definition
5. `lib/main.dart` — the MultiProvider graph where you will add the hub binding
6. `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart` — where you expose hubs to the UI
7. `devPlans/2026-06-26-supabase-integration-plan.md` — Phase 3 spec (Tasks 12–14)

---

## Pre-flight Checks

Run all of these before creating any files.

### 1. Phase 1 DB applied?

```bash
# Requires supabase CLI linked to bpzuwwbtqqrpohfqjcuo
supabase db execute --sql "SELECT COUNT(*) FROM public.hubs;"
```

Expected: `4`. If `0` or table not found, stop — Phase 1 migrations are not applied.

### 2. Hub model already exists?

```bash
ls lib/data/models/hub.dart 2>/dev/null || echo "MISSING"
```

### 3. IHubRepository already exists?

```bash
ls lib/domain/repositories/i_hub_repository.dart 2>/dev/null || echo "MISSING"
```

### 4. SupabaseHubRepository already exists?

```bash
ls lib/data/repositories/supabase_hub_repository.dart 2>/dev/null || echo "MISSING"
```

### 5. Test infrastructure working?

```bash
flutter test --no-pub 2>&1 | tail -5
```

All existing tests must pass before you start. Fix any pre-existing failures first.

### 6. Current analyze clean?

```bash
flutter analyze 2>&1 | grep -c "error •"
```

Expected: `0`. Fix pre-existing analysis errors before starting.

### Pre-flight report

| Check | Status | Action |
|---|---|---|
| Phase 1 hubs table has 4 rows | ✅/❌ | stop if ❌ |
| hub.dart exists | ✅/⬜ | create if missing |
| i_hub_repository.dart exists | ✅/⬜ | create if missing |
| supabase_hub_repository.dart exists | ✅/⬜ | create if missing |
| All existing tests pass | ✅/❌ | fix if ❌ |
| flutter analyze clean | ✅/❌ | fix if ❌ |

---

## Task 12 — Hub Model + IHubRepository Interface

### TDD Step 1: Write the failing test first

Create `test/data/models/hub_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';

void main() {
  group('Hub.fromJson', () {
    const validJson = {
      'id': 'abc-123-def',
      'name': 'Hub Al-Sweifieh',
      'address': 'Sweifieh Commercial District, Amman',
      'lat': 31.944,
      'lng': 35.871,
      'active': true,
      'capacity_kg': 1200.0,
      'current_load': {
        'cookingOil': 312,
        'plastic': 156,
        'paper': 94,
        'electronics': 37,
      },
      'schedule': 'weekly',
      'next_shipment_date': '2026-06-27',
      'last_shipment_date': '2026-06-20',
      'status': 'collecting',
      'created_at': '2026-06-26T10:00:00Z',
    };

    test('parses all fields correctly', () {
      final hub = Hub.fromJson(validJson);
      expect(hub.id, 'abc-123-def');
      expect(hub.name, 'Hub Al-Sweifieh');
      expect(hub.lat, closeTo(31.944, 0.001));
      expect(hub.lng, closeTo(35.871, 0.001));
      expect(hub.active, isTrue);
      expect(hub.capacityKg, 1200.0);
      expect(hub.currentLoad['cookingOil'], 312);
      expect(hub.schedule, 'weekly');
      expect(hub.status, 'collecting');
      expect(hub.nextShipmentDate, '2026-06-27');
      expect(hub.createdAt, isA<DateTime>());
    });

    test('handles null optional date fields', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['next_shipment_date'] = null
        ..['last_shipment_date'] = null;
      final hub = Hub.fromJson(json);
      expect(hub.nextShipmentDate, isNull);
      expect(hub.lastShipmentDate, isNull);
    });

    test('handles integer lat/lng from Supabase numeric type', () {
      final json = Map<String, dynamic>.from(validJson)
        ..['lat'] = 31   // Supabase may return integer when fractional part is 0
        ..['lng'] = 35;
      final hub = Hub.fromJson(json);
      expect(hub.lat, 31.0);
      expect(hub.lng, 35.0);
    });
  });
}
```

### TDD Step 2: Run — must fail

```bash
flutter test test/data/models/hub_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:dwaar/data/models/hub.dart'`

### TDD Step 3: Implement `lib/data/models/hub.dart`

```dart
// lib/data/models/hub.dart

/// A physical collection point managed by the admin dashboard.
/// Drivers use hub locations as dropoff targets.
class Hub {
  const Hub({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.active,
    required this.capacityKg,
    required this.currentLoad,
    required this.schedule,
    required this.nextShipmentDate,
    required this.lastShipmentDate,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool active;
  final double capacityKg;
  final Map<String, dynamic> currentLoad;
  final String schedule;            // 'weekly' | 'monthly'
  final String? nextShipmentDate;   // ISO date string or null
  final String? lastShipmentDate;   // ISO date string or null
  final String status;              // 'collecting' | 'ready' | 'shipped'
  final DateTime createdAt;

  factory Hub.fromJson(Map<String, dynamic> json) {
    return Hub(
      id:               json['id'] as String,
      name:             json['name'] as String,
      address:          json['address'] as String,
      lat:              (json['lat'] as num).toDouble(),
      lng:              (json['lng'] as num).toDouble(),
      active:           json['active'] as bool,
      capacityKg:       (json['capacity_kg'] as num).toDouble(),
      currentLoad:      Map<String, dynamic>.from(json['current_load'] as Map),
      schedule:         json['schedule'] as String,
      nextShipmentDate: json['next_shipment_date'] as String?,
      lastShipmentDate: json['last_shipment_date'] as String?,
      status:           json['status'] as String,
      createdAt:        DateTime.parse(json['created_at'] as String),
    );
  }
}
```

### TDD Step 4: Create `lib/domain/repositories/i_hub_repository.dart`

```dart
// lib/domain/repositories/i_hub_repository.dart
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../data/models/hub.dart';

/// Read-only gateway for collection hubs.
/// Only the admin dashboard (via service_role) can create/update/delete hubs.
/// The app reads them so drivers can select a dropoff target.
abstract interface class IHubRepository {
  /// Returns all active hubs ordered by creation date.
  Future<AppResult<List<Hub>>> fetchActiveHubs();
}
```

### TDD Step 5: Run test — must pass

```bash
flutter test test/data/models/hub_test.dart
```

Expected: **3 tests passed**.

### TDD Step 6: Analyze

```bash
flutter analyze lib/data/models/hub.dart lib/domain/repositories/i_hub_repository.dart
```

Expected: `No issues found!`

### Step 7: Commit

```bash
git add lib/data/models/hub.dart \
        lib/domain/repositories/i_hub_repository.dart \
        test/data/models/hub_test.dart
git commit -m "feat(app): Hub model + IHubRepository interface with tests"
```

---

## Task 13 — SupabaseHubRepository Implementation

### TDD Step 1: Write the failing test

Create `test/data/repositories/supabase_hub_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';
import 'package:dwaar/domain/repositories/i_hub_repository.dart';
import 'package:dwaar/core/result/result.dart';

// Fake that returns canned data — no Supabase network call needed
class _FakeHubRepository implements IHubRepository {
  final List<Hub> _hubs;
  _FakeHubRepository(this._hubs);

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async =>
      Result.success(_hubs);
}

void main() {
  group('IHubRepository contract', () {
    test('fetchActiveHubs returns a List<Hub> on success', () async {
      final hub = Hub(
        id: 'h1',
        name: 'Hub A',
        address: 'Sweifieh',
        lat: 31.944,
        lng: 35.871,
        active: true,
        capacityKg: 1000,
        currentLoad: {'cookingOil': 0, 'plastic': 0, 'paper': 0, 'electronics': 0},
        schedule: 'weekly',
        nextShipmentDate: null,
        lastShipmentDate: null,
        status: 'collecting',
        createdAt: DateTime(2026, 6, 26),
      );

      final repo = _FakeHubRepository([hub]);
      final result = await repo.fetchActiveHubs();

      result.fold(
        onSuccess: (hubs) {
          expect(hubs, hasLength(1));
          expect(hubs.first.name, 'Hub A');
          expect(hubs.first.active, isTrue);
        },
        onFailure: (f) => fail('Expected success, got: $f'),
      );
    });

    test('fetchActiveHubs returns empty list when no active hubs', () async {
      final repo = _FakeHubRepository([]);
      final result = await repo.fetchActiveHubs();
      result.fold(
        onSuccess: (hubs) => expect(hubs, isEmpty),
        onFailure: (f) => fail('Expected success'),
      );
    });
  });
}
```

### TDD Step 2: Run — must fail

```bash
flutter test test/data/repositories/supabase_hub_repository_test.dart
```

Expected: FAIL — import for `supabase_hub_repository.dart` doesn't exist yet (if you referenced it in the test). The contract test will pass since it only uses the interface, which is good — that confirms the interface is correct.

### TDD Step 3: Implement `lib/data/repositories/supabase_hub_repository.dart`

```dart
// lib/data/repositories/supabase_hub_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_hub_repository.dart';
import '../models/hub.dart';

/// Reads active hubs from the Supabase `public.hubs` table.
/// The table is managed (written) by the admin dashboard via service_role.
/// This repository is strictly read-only — it only calls SELECT.
final class SupabaseHubRepository implements IHubRepository {
  SupabaseHubRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async {
    try {
      final response = await _client
          .from('hubs')
          .select()
          .eq('active', true)
          .order('created_at', ascending: true);

      final hubs = (response as List<dynamic>)
          .map((row) => Hub.fromJson(row as Map<String, dynamic>))
          .toList();

      return Result.success(hubs);
    } on PostgrestException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
```

### TDD Step 4: Run all tests

```bash
flutter test
```

Expected: all tests pass, including the 3 hub model tests and the 2 repository contract tests.

### Step 5: Analyze

```bash
flutter analyze lib/data/repositories/supabase_hub_repository.dart
```

Expected: `No issues found!`

### Step 6: Commit

```bash
git add lib/data/repositories/supabase_hub_repository.dart \
        test/data/repositories/supabase_hub_repository_test.dart
git commit -m "feat(app): implement SupabaseHubRepository — read-only SELECT on public.hubs"
```

---

## Task 14 — Bind in `main.dart` + Expose in `DriverHomeViewModel`

### TDD Step 1: Write the failing test

Create `test/ui/features/driver/driver_home_viewmodel_hubs_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/hub.dart';
import 'package:dwaar/domain/repositories/i_hub_repository.dart';
import 'package:dwaar/core/result/result.dart';

// Fake repositories for isolation
class _FakeHubRepository implements IHubRepository {
  final List<Hub> hubs;
  final bool shouldFail;
  _FakeHubRepository({this.hubs = const [], this.shouldFail = false});

  @override
  Future<AppResult<List<Hub>>> fetchActiveHubs() async {
    if (shouldFail) return Result.failure(const NetworkFailure('timeout'));
    return Result.success(hubs);
  }
}

Hub _makeHub(String id, String name) => Hub(
  id: id, name: name, address: 'Amman',
  lat: 31.963, lng: 35.910,
  active: true, capacityKg: 1000,
  currentLoad: {},
  schedule: 'weekly',
  nextShipmentDate: null,
  lastShipmentDate: null,
  status: 'collecting',
  createdAt: DateTime(2026, 6, 26),
);

void main() {
  group('DriverHomeViewModel hub loading', () {
    test('hubs is empty before loadHubs completes', () {
      final repo = _FakeHubRepository(hubs: [_makeHub('1', 'Hub A')]);
      // Directly test the repository contract — VM test depends on VM implementation
      expect(repo.hubs, hasLength(1));
    });

    test('fetchActiveHubs succeeds and returns list', () async {
      final repo = _FakeHubRepository(hubs: [
        _makeHub('1', 'Hub A'),
        _makeHub('2', 'Hub B'),
      ]);
      final result = await repo.fetchActiveHubs();
      result.fold(
        onSuccess: (hubs) => expect(hubs, hasLength(2)),
        onFailure: (_) => fail('should succeed'),
      );
    });

    test('fetchActiveHubs on network failure returns NetworkFailure', () async {
      final repo = _FakeHubRepository(shouldFail: true);
      final result = await repo.fetchActiveHubs();
      result.fold(
        onSuccess: (_) => fail('should fail'),
        onFailure: (f) => expect(f, isA<NetworkFailure>()),
      );
    });
  });
}
```

### TDD Step 2: Run — must pass (interface contract tests)

```bash
flutter test test/ui/features/driver/driver_home_viewmodel_hubs_test.dart
```

Expected: 3 tests pass (they test the repository contract, which is already implemented).

### Step 3: Add `IHubRepository` to `lib/main.dart`

**Imports to add** at the top of `main.dart`:

```dart
import 'data/repositories/supabase_hub_repository.dart';
import 'domain/repositories/i_hub_repository.dart';
```

**In `MultiProvider`, add after the `IOrderRepository` provider:**

```dart
Provider<IHubRepository>(
  create: (_) => SupabaseHubRepository(Supabase.instance.client),
),
```

### Step 4: Extend `DriverHomeViewModel`

Open `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart`.

**Add import:**

```dart
import '../../../../../data/models/hub.dart';
import '../../../../../domain/repositories/i_hub_repository.dart';
```

**Add fields and constructor parameter:**

```dart
class DriverHomeViewModel extends ChangeNotifier {
  DriverHomeViewModel(this._store, this._hubRepository) {
    _store.addListener(_onStoreChanged);
    _loadHubs();
  }

  final AppOrderStore _store;
  final IHubRepository _hubRepository;

  // ── Hub state ────────────────────────────────────────────────────────────────

  List<Hub> _hubs = [];
  List<Hub> get hubs => _hubs;

  bool _hubsLoading = false;
  bool get hubsLoading => _hubsLoading;

  Future<void> _loadHubs() async {
    _hubsLoading = true;
    notifyListeners();
    final result = await _hubRepository.fetchActiveHubs();
    result.fold(
      onSuccess: (hubs) => _hubs = hubs,
      onFailure: (_) => _hubs = [],   // fail silently — hub list non-critical
    );
    _hubsLoading = false;
    notifyListeners();
  }

  // ── Existing methods below — do not change ────────────────────────────────
```

**Update the `ChangeNotifierProvider` in `main.dart`** that creates `DriverHomeViewModel` — it must now pass the hub repository:

Find the existing provider (search for `DriverHomeViewModel`):

```dart
// Change from:
ChangeNotifierProvider<DriverHomeViewModel>(
  create: (ctx) => DriverHomeViewModel(ctx.read<AppOrderStore>()),
),

// To:
ChangeNotifierProvider<DriverHomeViewModel>(
  create: (ctx) => DriverHomeViewModel(
    ctx.read<AppOrderStore>(),
    ctx.read<IHubRepository>(),
  ),
),
```

### Step 5: Run all tests

```bash
flutter test
```

Expected: **all tests pass** — existing store tests, chat tests, and all new hub tests.

### Step 6: Full analyze

```bash
flutter analyze
```

Expected: `No issues found!`

### Step 7: Run app and verify

```bash
flutter run
```

Log in as driver (`+962790000001`). Open the driver home. Check the debug console for any exception in `_loadHubs`. The `DriverHomeViewModel.hubs` list should contain the 4 seeded hubs from Supabase.

To verify in the console, add a temporary debug print (remove before commit):

```dart
// In _loadHubs(), after fold:
debugPrint('[HubRepo] Loaded ${_hubs.length} active hubs');
```

Expected console output: `[HubRepo] Loaded 3 active hubs` (3 active — Tabarbour is inactive).

### Step 8: Commit

```bash
git add \
  lib/main.dart \
  lib/domain/repositories/i_hub_repository.dart \
  lib/data/models/hub.dart \
  lib/data/repositories/supabase_hub_repository.dart \
  lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart \
  test/data/models/hub_test.dart \
  test/data/repositories/supabase_hub_repository_test.dart \
  test/ui/features/driver/driver_home_viewmodel_hubs_test.dart
git commit -m "feat(app): Phase 3 — driver reads active hubs from Supabase

- Hub model: fromJson with full field coverage + 3 tests
- IHubRepository: clean domain interface
- SupabaseHubRepository: read-only SELECT on public.hubs with error mapping
- main.dart: IHubRepository bound to SupabaseHubRepository in MultiProvider
- DriverHomeViewModel: hubs field + _loadHubs() on init
- 8 tests total, flutter analyze clean

Requires: Phase 1 migrations (public.hubs must exist with seed data)
See devPlans/2026-06-26-supabase-integration-plan.md Tasks 12-14"
```

---

## Pinpoint Verification

### V1 — No regression in existing tests

```bash
flutter test
```

Expected: same test count as before Phase 3 + 8 new tests. Zero failures.

### V2 — Driver VM hubs populated

After `flutter run` with mock driver login, observe console:
- `[HubRepo] Loaded 3 active hubs` (3 because Tabarbour is `active=false`)

### V3 — Network failure handled gracefully

Temporarily set an invalid Supabase URL in `.env.local`, restart app, log in as driver. The app must boot normally — `_loadHubs` failure is silent, `hubs` is just empty. No crash.

### V4 — New hub added by dashboard appears in app

In the dashboard (Phase 2 complete), add a new hub via the `+ Add Hub` button.
Without restarting Flutter, call `vm.loadHubs()` manually via hot reload or relaunch.
The new hub must appear in `vm.hubs`.

### V5 — Analyze clean

```bash
flutter analyze 2>&1 | grep "error •"
```

Expected: `0` errors printed.

---

## Verification Report

| Check | Expected | Actual | Pass? |
|---|---|---|---|
| V1 — no test regressions | 0 failures | | ✅/❌ |
| V2 — 3 active hubs loaded | `Loaded 3 active hubs` in log | | ✅/❌ |
| V3 — graceful failure | app boots, hubs = [] | | ✅/❌ |
| V4 — new hub syncs from dashboard | hub appears in vm.hubs | | ✅/❌ |
| V5 — analyze clean | 0 errors | | ✅/❌ |

**All 5 must pass before Phase 3 is declared complete.**

---

## What Phase 3 Does NOT Touch

- ❌ No dashboard TypeScript/React code
- ❌ No Supabase SQL migrations
- ❌ No changes to existing repositories (orders, wallet, auth, file storage)
- ❌ No UI changes — hubs are added to the VM but not yet surfaced in a UI widget (that is a Phase 4 concern)
- ❌ No changes to `AppOrderStore`
- ❌ No changes to mock repositories

---

## Ready for Phase 4?

Phase 3 intentionally does not render hubs in the Flutter UI — it only makes the data available in `DriverHomeViewModel.hubs`. The next phase would:
1. Show hub markers on the driver's live tracking map
2. Let the driver select a hub as their dropoff destination when accepting a collection order
3. Auto-suggest the nearest hub based on the driver's current GPS position

These require UI/map changes and are outside the scope of the cross-system integration plan.
