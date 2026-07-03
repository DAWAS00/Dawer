# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                      # Install dependencies
flutter run                          # Run on connected device/emulator
flutter run -d windows               # Or use launch_app.bat
flutter analyze                      # Lint
flutter test                         # All tests
flutter test test/path/to/file.dart  # Single test file
flutter build apk                    # Build APK

# Code generation (freezed/json_serializable models in lib/data/models/order/)
dart run build_runner build --delete-conflicting-outputs

# Localization (regenerates lib/l10n/generated/ from .arb files; also runs on `flutter pub get`)
flutter gen-l10n
```

App startup requires `.env.local` in repo root (declared as an asset) with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `GEMINI_API_KEY`. Missing Supabase vars fall back to hardcoded defaults in `main.dart`; missing Gemini key is asserted by `AiConfig.assertConfigured()`. Never commit `.env.local` — also gitignored: `lib/core/constants/map_tokens.dart`, `android/local.properties`, `.vscode/launch.json`.

If a test run fails with a `shaders/ink_sparkle.frag` version exception, it's stale build cache after a Flutter SDK update — run `flutter clean` first.

## Architecture

**Dwaar (دوّر)** — Arabic-first waste-recycling logistics app (Jordan). Three roles, each with its own home shell: **Driver**, **Supplier**, **Recycling Company**. (`lib/ui/features/home/restaurant/` exists but is not wired into `HomeRouter`; store-business suppliers route to it under a different path.)

**Backend strategy**: Supabase (Postgres + RLS + Realtime + Storage + Edge Functions) is the primary, locked backend. A parallel Python/FastAPI GCP re-platform exists under `backend/` but is **reference-only, not wired into the app** — don't treat it as live infrastructure. See `docs/architecture-decisions/backend-strategy.md`.

### Layering

```
lib/domain/        — interfaces only: i_*_repository.dart, i_*_service.dart, entities, AppFailure
lib/data/          — implementations: mock_* and supabase_* repositories, services, models
lib/core/          — config, constants, theme, Result type (core/result/), ViewState (core/state/)
lib/ui/            — feature-scoped MVVM (Provider)
lib/backend_integration_locally/local_store.dart — local JSON persistence (survives restarts)
```

Cross-layer results use `AppResult<T>` (= `Result<T, AppFailure>`, `lib/core/result/result.dart`) rather than thrown exceptions; repository implementations catch and map exceptions to `AppFailure` subtypes (`NetworkFailure`, `AuthFailure`, `ValidationFailure`, `NotFoundFailure`, `PermissionFailure`, `StorageFailure`, `UnknownFailure`).

### Dependency injection — `lib/app/app_providers.dart`

All repository bindings are wired in `buildProviders()`, keyed off two flags passed from `main.dart`: `useSupabase` (true when `.env.local` loaded and Supabase initialized) and `mockAuth`. Pattern: `useSupabase ? Supabase*Repository(...) : NoOp*Repository()` for most repos, but auth and chat fall back to hand-written `Mock*` fakes instead of `NoOp`:

| Interface | Live binding (`useSupabase`) | Fallback |
| --- | --- | --- |
| `IOrderRepository` | `SupabaseOrderRepository` | `NoOpOrderRepository` |
| `IWalletRepository` | `SupabaseWalletRepository` | `NoOpWalletRepository` |
| `IHubRepository` | `SupabaseHubRepository` | `NoOpHubRepository` |
| `IReservationRepository` | `SupabaseReservationRepository` | `NoOpReservationRepository` |
| `IFileStorageRepository` | `SupabaseFileStorageRepository` | `NoOpFileStorageRepository` |
| `IChatRepository` | `SupabaseChatRepository` | `MockChatRepository` |
| `IAuthRepository` | `SupabaseAuthRepository` (only if `!mockAuth`) | `MockAuthRepository` |

**`main.dart` hardcodes `const mockAuth = true`** — so `IAuthRepository` always resolves to `MockAuthRepository` regardless of `useSupabase`, even though `SupabaseAuthRepository` is fully wired and ready. Flip that constant (and remove any other auth gating) to switch to real phone-OTP auth. When swapping any other mock → real implementation, bind through the `lib/domain/` interface in `app_providers.dart`, not by editing call sites.

Data flow is otherwise **hybrid**: `AppOrderStore` (the central `ChangeNotifier` for all order state, provided app-wide) writes to `LocalStore` locally and mirrors to `IOrderRepository`.

### Pattern: Feature-Scoped MVVM with Provider

Each role lives under `lib/ui/features/home/<role>/` with the same structure:
- `<role>_home_view.dart` — root scaffold + bottom nav, provides the role's VM
- `viewmodels/` — `ChangeNotifier` VMs owning state + logic
- `tabs/`, `widgets/`, `controllers/` — UI; tabs read state via `context.watch<VM>()`

`lib/ui/features/home/shared/` holds role-agnostic order UI (order details, marketplace tab + VM, order cards). Multi-step forms are "wizards": supplier pickup-request wizard in `supplier/widgets/wizard/` (style tokens in `wizard_style_tokens.dart`), signup wizard in `auth/views/signup_wizard/`.

### Routing

`SplashView` → `LoginView` → `VerificationView` → `HomeRouter` (`lib/ui/features/home/home_router.dart`). `HomeRouter` switches on `UserRole` + `SupplierType` enums. Navigation is imperative (`Navigator.push`) — no named routes (`go_router` is in pubspec but unused in live code).

### Models

`Order` is a **freezed** model: `lib/data/models/order/order.dart` (re-exports `order_enums.dart`, `order_proof.dart`). Edit the `.dart` source then run build_runner — never edit `.freezed.dart`/`.g.dart`. Enums (`OrderType`, `OrderStatus`, `WasteType`, `WasteForm`, `WeightCategory`, `PickupTarget`, `VehicleType`, …) live in `order_enums.dart`; Arabic/English label extensions in `order_labels.dart`. Always display via `.label` / `.shortLabel`, never raw enum names.

### Localization & Theme

- Bilingual ar/en via `.arb` files in `lib/l10n/` (Arabic is the template). Use `context.l10n.<key>` (`lib/l10n/l10n.dart`); direction follows locale via `AppLangNotifier`. New UI code still contains some hardcoded Arabic strings — prefer adding `.arb` keys.
- Light/dark themes in `lib/core/theme/app_theme.dart`, toggled by `AppThemeNotifier`. Colors: token names from `AppColors` (`lib/core/constants/app_colors.dart`), not raw hex. Font: Google Fonts Cairo for Arabic text.
- Forced portrait orientation.

### Testing

Tests mirror `lib/` structure under `test/`. `AppOrderStore` lifecycle/persistence tests are the core safety net — run them after touching order state logic. No `integration_test/` suite exists yet — unit/widget tests only.

### Security notes

- `SUPABASE_SERVICE_ROLE_KEY` must never ship in the Flutter app — it's for Edge Functions / server-side tooling only.
- Google Maps API key is read from `android/local.properties` into `AndroidManifest.xml` via a `MAPS_API_KEY` placeholder (gitignored).
- `MockAuthRepository` disables OTP validation and trusts the UI-selected role — fine for development, not safe if ever shipped as the live binding.

### Supabase backend

Migrations live in `supabase/migrations/`, applied in filename order. Edge Functions (`supabase/functions/`) deploy via `supabase functions deploy <name> --project-ref <ref>`; current functions are `verify_arrival` and `daily_payout` (docs referencing `match_driver`/`send_push` predate their actual implementation — verify against `supabase/functions/` before assuming a function exists).

### Other docs

`AGENTS.md` and `docs/codebase-guide/` contain more detail but can drift from the live code faster than this file — when in doubt, verify against `lib/app/app_providers.dart` and `main.dart` directly rather than trusting narrative docs about "current state."
