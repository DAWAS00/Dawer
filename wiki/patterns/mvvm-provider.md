---
name: mvvm-provider
description: Feature-scoped MVVM pattern with Provider used in all Dwaar home shells — how VMs are structured, provided, and consumed
metadata:
  type: pattern
---

# MVVM with Provider

Every role home shell follows the same structure:

```
lib/ui/features/home/<role>/
├── <role>_home_view.dart    — Root scaffold + bottom nav; provides the VM
├── viewmodels/              — ChangeNotifier VMs owning state + logic
├── tabs/                    — Tab content widgets; read state via context.watch<VM>()
└── widgets/                 — Presentational widgets; no business logic
```

## VM Lifecycle

The home view wraps the scaffold with `ChangeNotifierProxyProvider` (or `ChangeNotifierProvider`) so the VM is scoped to the home shell lifetime. All three home VMs accept `AppOrderStore` as a dependency — they `addListener` to it so their own `notifyListeners()` fires whenever the store changes.

```dart
// Pattern used in home views:
ChangeNotifierProvider<DriverHomeViewModel>(
  create: (ctx) => DriverHomeViewModel(store: ctx.read<AppOrderStore>()),
  child: DriverHomeView(...),
)
```

## Consuming State in Tabs

```dart
// Read without rebuilding (action call):
context.read<DriverHomeViewModel>().acceptOrder(orderId);

// Watch and rebuild on change:
final vm = context.watch<DriverHomeViewModel>();
```

## ViewState Pattern

`lib/core/state/view_state.dart` — used for loading/error/success states in VMs that do async work (e.g., earnings fetch, marketplace load).

## Result Type

`lib/core/result/result.dart` — `AppResult<T>` = `Success<T> | Failure`. All repository and service methods return `AppResult`. Use `.fold(onSuccess:, onFailure:)` at the call site — no try/catch in UI.

## Shared Marketplace VM

`MarketplaceViewModel` in `lib/ui/features/home/shared/viewmodels/` is reused across all three role home shells via the `MarketplaceTab` widget. It reads from `AppOrderStore.marketItems` and `pendingCollectionJobs`.

## Related Pages

- [[concepts/app-architecture]]
- [[concepts/app-order-store]]
