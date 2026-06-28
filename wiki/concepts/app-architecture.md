---
name: app-architecture
description: Dwaar Flutter app layered architecture — domain/data/ui layers, Provider MVVM pattern, hybrid local+Supabase data flow
metadata:
  type: concept
---

# App Architecture

**Dwaar (دوّر)** is an Arabic-first waste-recycling logistics app for Jordan. Three user roles share one codebase.

## Layer Structure

```
lib/
├── domain/          — Interfaces only: i_*_repository.dart, i_*_service.dart, AppFailure, entities
├── data/            — Implementations: mock_* + supabase_* repos, services, models
├── core/            — Config, constants, theme, Result type, ViewState
├── ui/              — Feature-scoped MVVM (Provider)
└── backend_integration_locally/local_store.dart  — Local JSON persistence
```

## Data Flow (Hybrid)

`AppOrderStore` is the **single source of truth** for all order state. It is a `ChangeNotifier` provided at the app root in `main.dart`.

1. On first launch: seeds from `OrderMockData` → writes to `LocalStore`
2. On subsequent launches: reads from `LocalStore`
3. After `HomeRouter` mounts: subscribes to `SupabaseOrderRepository.watchOrdersForUser()` and merges remote updates
4. Every `notifyListeners()` auto-persists to `LocalStore` (fire-and-forget)

## Provider Setup (`main.dart`)

| Provider | Type | Current Implementation |
|---|---|---|
| `IAuthRepository` | `Provider` | **`MockAuthRepository`** ← NOT real yet |
| `IOrderRepository` | `Provider` | `SupabaseOrderRepository` ✅ |
| `AppOrderStore` | `ChangeNotifierProvider` | Hybrid (LocalStore + Supabase stream) ✅ |
| `AppThemeNotifier` | `ChangeNotifierProvider` | SharedPreferences-backed ✅ |
| `AppLangNotifier` | `ChangeNotifierProvider` | SharedPreferences-backed ✅ |
| `IFileStorageRepository` | `Provider` | `SupabaseFileStorageRepository` ✅ |
| `INotificationService` | `Provider` | `FcmNotificationService` ✅ |
| `IChatRepository` | `Provider` | `MockChatRepository` |
| `LoginViewModel` | `ChangeNotifierProvider` | App-root (so splash can read it) |

## What's NOT Wired Yet

- `IAuthRepository` in `main.dart` is still `MockAuthRepository`. `SupabaseAuthRepository` is written and complete — just needs to be swapped in.
- `IWalletRepository` in `AppOrderStore` is `NoOpWalletRepository` — `SupabaseWalletRepository` exists but is not connected.

## Related Pages

- [[concepts/order-lifecycle]]
- [[concepts/app-order-store]]
- [[concepts/user-roles]]
- [[patterns/mvvm-provider]]
- [[patterns/mock-to-real-swap]]
