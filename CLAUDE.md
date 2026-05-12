# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on connected device/emulator — credentials loaded from .env.local automatically
flutter run

# CI/CD (no .env.local): pass via --dart-define instead
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# Build APK (split per ABI for distribution)
flutter build apk --split-per-abi \
  --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# Analyze
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/data/app_order_store_test.dart

# Generate localization files (after editing lib/l10n/*.arb)
flutter gen-l10n
```

**No hardcoded credentials anywhere.** The app shows an Arabic error screen if `--dart-define` flags are absent — this is intentional.

---

## Architecture

**Dawer (دوّر)** — Arabic-first (RTL) waste-recycling logistics app for Jordan. Three roles share one codebase: **Driver**, **Supplier**, **Recycling Company**. The app is currently on a Supabase backend with a planned migration to Firebase/GCP (`MIGRATION_GCP.md`). The active execution plan is `PHASES.md`.

### Layer Boundaries

```
lib/domain/   — interfaces + entities + failures. Zero Flutter or backend imports.
lib/data/     — implementations of domain interfaces + AppOrderStore + LocalStore.
lib/ui/       — views + viewmodels. Reads from stores/repos; never imports Supabase.
lib/core/     — shared infrastructure (result type, state, logger, theme, routing).
```

**The rule**: domain interfaces (`IAuthRepository`, `IOrderRepository`, `IFileStorageRepository`) never change when the backend changes. Only `main.dart` DI wiring changes.

### Error propagation

All repository and service methods return `AppResult<T>` (`= Result<T, AppFailure>`). Never throw across layer boundaries.

```dart
// Result<T,E> lives in lib/core/result/result.dart
result.fold(onSuccess: (v) { ... }, onFailure: (f) { ... });
```

`AppFailure` is a sealed class: `NetworkFailure | AuthFailure | NotFoundFailure | PermissionFailure | StorageFailure | ValidationFailure | UnknownFailure`. All have an Arabic `message` field for direct display.

### ViewModel state

`ViewState<T>` (`lib/core/state/view_state.dart`) is the standard VM state type. Import it with `import '../../core/state/view_state.dart'` — it re-exports `AppFailure` and `AppResult`.

```dart
sealed class ViewState<T> { ... }
// Idle | Loading | Loaded(data) | Failed(failure)

// Standard ViewModel action pattern:
_state = const Loading(); notifyListeners();
final result = await _repo.doSomething();
_state = result.fold(onSuccess: Loaded.new, onFailure: Failed.new);
notifyListeners();
```

In views, switch on `vm.state` — avoid ad-hoc `isLoading` booleans in new code.

### Order store composition

`AppOrderStore` is the **single source of truth** for all orders. It's a `ChangeNotifier` split across five `part` files by domain:

```
app_order_store.dart              — bootstrap, persistence, remote write helper
app_order_store/driver_actions    — driverFeed, acceptOrder, markInTransit, completeOrder
app_order_store/supplier_actions  — supplierOrdersFor, createPickupRequest, cancelOrder
app_order_store/collection_job_actions
app_order_store/collection_sale_actions
app_order_store/marketplace_actions
```

**Role proxy stores** (`DriverOrderStore`, `SupplierOrderStore`, `RecyclingOrderStore`) are thin `ChangeNotifier` wrappers that subscribe to `AppOrderStore` and expose only the relevant slice of its API. They never hold their own state. Add logic to `AppOrderStore` part files; expose it through the appropriate proxy.

**Mutations are optimistic**: update `_orders` in-memory first, then call `_pushRemote(...)` fire-and-forget. `_lastError` surfaces the failure if it occurs.

### Order model

`Order` is a single immutable class covering all four order types. `OrderType` enum (`pickupRequest | collectionJob | collectionSale | marketplaceListing`) discriminates behavior. `copyWith` is in `order_copy_with.dart`; `toJson`/`orderFromJson` in `order_json.dart`; Supabase mapping in `order_supabase_ext.dart`.

When reading `import 'data/models/order.dart'` you also get `order_enums.dart`, `order_arabic_labels.dart`, `order_copy_with.dart`, and `invoice_item.dart` via re-exports.

### Auth flow

```
SplashView → checks SupabaseService.initError → if set, shows _BackendErrorScreen
           → checks LocalStore session → HomeRouter (role dispatch)
           → else → LoginView → VerificationView → HomeRouter
```

`HomeRouter` is a plain widget switch on `UserRole` + `SupplierType` (not a router). Navigation is currently imperative (`Navigator.push`/`pushReplacement`). A `go_router` migration is planned in Phase 5.

`AppOrderStore.configureForUser(userId, role)` must be called from `HomeRouter` after the session is established to switch the remote stream to the role-scoped filter.

### Logging

Use `AppLogger` (`lib/core/utils/app_logger.dart`) — never `debugPrint`. Methods: `info`, `warn`, `error`. Debug-only in current build; Crashlytics hook left as a TODO for Phase 3.

### LocalStore

`SharedPreferences` wrapper — **the only place** that reads/writes persistent app state. All keys are private constants prefixed `dwaar_`. Never read `SharedPreferences` directly outside `LocalStore`.

### Localisation

All user-visible strings go through `AppLocalizations` (generated from `lib/l10n/*.arb`). Access via `context.l10n.keyName` (the `l10n.dart` extension). Never hardcode Arabic or English strings in widget code.

### Theme

- Colors: `AppColors` tokens only — never raw hex values.
- Font: Google Fonts (Cairo for Arabic, DM Sans for Latin) loaded at runtime.
- Portrait-only, globally RTL. `AppTheme.lightTheme` / `AppTheme.darkTheme`.

### File size rule

Every `.dart` file must stay ≤ 200 lines. Use `part`/`part of` for same-class extensions (as seen in `AppOrderStore`), separate files for separate concepts.
