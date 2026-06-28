# 2. Architecture

## High-level structure

The Flutter project is organized into a layered / clean-ish architecture. Feature folders are not used at the top level; instead, code is split by architectural layer, with feature sub-folders inside `ui/`.

```
lib/
├── core/                        # Cross-cutting concerns
│   ├── config/                  # AI config, env helpers
│   ├── constants/               # App-wide constants
│   ├── result/                  # Result<T,E> monad
│   ├── services/                # AppThemeNotifier, AppLangNotifier, SupabaseService
│   ├── state/                   # ViewState<T> sealed class
│   ├── theme/                   # Light/dark themes
│   └── utils/                   # Shared helpers
├── data/                        # Data layer
│   ├── chat/                    # Chat repositories
│   ├── mock/                    # Mock data seeds
│   ├── models/                  # Freezed models, enums
│   ├── repositories/            # Repository implementations (Supabase + Mock)
│   ├── services/                # Services (location, AI, notifications, wallet)
│   └── utils/                   # Data utilities
├── domain/                      # Domain layer
│   ├── chat/                    # Chat entities/repos
│   ├── entities/                # Domain entities (earnings, etc.)
│   ├── failures/                # AppFailure hierarchy
│   ├── repositories/            # Repository interfaces
│   ├── requests/                # Request DTOs (CreatePickupRequest)
│   └── services/                # Service interfaces (ILocationPublisher, etc.)
├── l10n/                        # Generated localizations
├── ui/                          # Presentation layer
│   ├── common/                  # Shared widgets
│   ├── core/components/         # Reusable UI components
│   └── features/                # Feature-scoped screens + viewmodels
│       ├── auth/
│       ├── chat/
│       ├── chatbot/
│       ├── driver/
│       ├── earnings/
│       ├── home/
│       ├── marketplace/
│       ├── recycling/
│       ├── splash/
│       └── supplier/
└── main.dart                    # Bootstrap + dependency injection
```

## Layer responsibilities

### `core/`

Contains code that is not business-specific:

- `result/result.dart` — `Result<S,F>` and `AppResult<T>` typedef.
- `state/view_state.dart` — `ViewState<T>`: `Idle`, `Loading`, `Loaded`, `Failed`.
- `services/supabase_service.dart` — thin wrapper around `Supabase.initialize()`.
- `theme/app_theme.dart` — light and dark `ThemeData`.
- `config/ai_config.dart` — reads the Gemini API key from `.env.local`.

### `domain/`

Pure business logic with no Flutter or Supabase imports (ideally):

- `repositories/` — abstract contracts: `IAuthRepository`, `IOrderRepository`, `IWalletRepository`, `IFileStorageRepository`, `IChatRepository`.
- `failures/app_failure.dart` — sealed `AppFailure` hierarchy: `NetworkFailure`, `AuthFailure`, `ValidationFailure`, `NotFoundFailure`, `PermissionFailure`, `StorageFailure`, `UnknownFailure`.
- `entities/` — domain objects like `EarningsSummary`, `TripEarning`, `RiderProximityState`.
- `services/` — interfaces for external capabilities: `ILocationPublisher`, `INotificationService`, `IProximityService`, AI service interfaces.
- `requests/` — plain objects describing intent, e.g. `CreatePickupRequest`.

### `data/`

Implements the domain contracts and holds models:

- `repositories/` — `SupabaseOrderRepository`, `SupabaseWalletRepository`, `SupabaseFileStorageRepository`, `SupabaseAuthRepository`, `MockAuthRepository`, `MockEarningsRepository`, `MockChatRepository`.
- `services/` — concrete services: `AppOrderStore`, `LocationPublisher`, `ProximityService`, `RewardService`, `FcmNotificationService`, `GeminiVehicleRegistrationService`, `MarketAiService`, etc.
- `models/` — Freezed models (`Order`, `OrderProof`, `InvoiceItem`, `RewardBreakdown`, `User`, etc.) and enums.
- `mock/` — `OrderMockData`, static seed data for dev/demo.

### `ui/`

Everything user-facing:

- `features/<feature>/views/` — screens and tabs.
- `features/<feature>/viewmodels/` — `ChangeNotifier` viewmodels.
- `features/<feature>/widgets/` — feature-private widgets.
- `common/` — cross-feature widgets.
- `core/components/` — design-system components (buttons, cards, inputs).

## State management

The app uses **Provider + ChangeNotifier** as its primary state-management solution.

### Global providers in `main.dart`

```dart
// lib/main.dart
MultiProvider(
  providers: [
    Provider<LocalStore>.value(value: localStore),
    Provider<IFileStorageRepository>.value(value: fileStorage),
    Provider<INotificationService>.value(value: notificationService),
    Provider<IOrderRepository>(
      create: (_) => SupabaseOrderRepository(Supabase.instance.client),
    ),
    ChangeNotifierProvider(
      create: (ctx) => AppOrderStore(
        store: localStore,
        remote: ctx.read<IOrderRepository>(),
        seedDriverOrderId: 'ORD-S01',
      ),
    ),
    ChangeNotifierProvider(create: (_) => AppThemeNotifier(prefs)),
    ChangeNotifierProvider(create: (_) => AppLangNotifier(prefs)),
    Provider<IAuthRepository>(
      create: (_) => MockAuthRepository(), // <-- currently mock
    ),
    Provider<IChatRepository>(
      create: (_) => MockChatRepository(),
    ),
    ChangeNotifierProvider<LoginViewModel>(
      create: (ctx) => LoginViewModel(
        authRepository: ctx.read<IAuthRepository>(),
      ),
    ),
  ],
  child: Consumer2<AppThemeNotifier, AppLangNotifier>(
    builder: (context, themeNotifier, langNotifier, child) => MaterialApp(...),
  ),
)
```

### Shared store pattern

`AppOrderStore` is the **single source of truth** for orders. It is provided once at the root. Every home-view viewmodel receives it and adds itself as a listener:

```dart
class DriverHomeViewModel extends ChangeNotifier {
  DriverHomeViewModel(this._store) {
    _store.addListener(_onStoreChanged);
  }
  final AppOrderStore _store;

  void _onStoreChanged() => notifyListeners();

  List<Order> get feed => _store.driverFeedFor(vehicleType: ...);
  Order? get activeOrder => _store.driverActiveOrder;
}
```

### ViewState pattern

Some screens use `ViewState<T>`:

```dart
sealed class ViewState<T> {
  const factory ViewState.idle() = Idle<T>;
  const factory ViewState.loading() = Loading<T>;
  const factory ViewState.loaded(T data) = Loaded<T>;
  const factory ViewState.failed(AppFailure failure) = Failed<T>;
}
```

Example: `EarningsViewModel` exposes `ViewState<EarningsSummary>`.

## Dependency injection

Dependency injection is manual via Provider. There is no `GetIt` or `injectable` in use, despite the Flutter skill preference.

### Repository swapping

Because repositories implement interfaces, the app can swap backends without touching viewmodels:

| Interface | Current binding | Alternative implementation |
|---|---|---|
| `IAuthRepository` | `MockAuthRepository` | `SupabaseAuthRepository` |
| `IOrderRepository` | `SupabaseOrderRepository` | `NoOpOrderRepository` (for tests) |
| `IWalletRepository` | `NoOpWalletRepository` (default) | `SupabaseWalletRepository` |
| `IChatRepository` | `MockChatRepository` | (not yet implemented) |

## Result / failure pattern

The codebase avoids throwing exceptions across layer boundaries. Instead it returns `AppResult<T>`:

```dart
typedef AppResult<T> = Result<T, AppFailure>;
```

Usage:

```dart
final result = await _repository.doSomething();
result.fold(
  onSuccess: (data) { ... },
  onFailure: (failure) { ... },
);
```

Repository implementations catch exceptions and map them to `AppFailure` subtypes.

## Navigation

The app mostly uses **imperative navigation** (`Navigator.push`, `pushReplacement`, `pushAndRemoveUntil`).

- `SplashView` → `LoginView` → `VerificationView` → `HomeRouter`
- `HomeRouter` switches on `UserRole` + `SupplierType` and returns the correct home shell.

`go_router` is listed in `pubspec.yaml` but is largely unused. Routing is inconsistent across the codebase.

## Local persistence

`LocalStore` (`lib/backend_integration_locally/local_store.dart`) wraps `SharedPreferences`. It persists:

- Users, orders, market listings, drafts
- Current session (role, supplier type, categories)
- First-launch flag

On first launch it seeds `OrderMockData.seedOrders()` and `seedMarketItems()` into local storage.

## Code generation

Freezed and json_serializable are used for immutable data classes. Generated files are:

- `*.freezed.dart`
- `*.g.dart`

Run code generation with:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Important architectural notes

1. **No Riverpod, Bloc, or Redux.** Despite some dependencies, the real runtime pattern is Provider + ChangeNotifier.
2. **`signals_flutter`** is in `pubspec.yaml` but largely unused.
3. **`go_router`** is imported but the app uses `Navigator` directly.
4. **`flutter_hooks`** is present but not widely adopted.
5. **`User` model is mostly hard-coded** in viewmodels; real profile loading from auth session is incomplete.

## Files referenced

- `lib/main.dart` — bootstrap and provider graph
- `lib/core/result/result.dart` — `Result` monad
- `lib/core/state/view_state.dart` — `ViewState<T>`
- `lib/domain/failures/app_failure.dart` — failure hierarchy
- `lib/domain/repositories/` — repository interfaces
- `lib/data/services/app_order_store.dart` — central order store
- `lib/backend_integration_locally/local_store.dart` — SharedPreferences wrapper
