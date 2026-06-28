# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter run                          # Run on connected device/emulator
flutter analyze                      # Lint
flutter test                         # All tests
flutter test test/path/to/file.dart  # Single test file
flutter build apk                    # Build APK

# Code generation (freezed/json_serializable models in lib/data/models/order/)
dart run build_runner build --delete-conflicting-outputs

# Localization (regenerates lib/l10n/generated/ from .arb files; also runs on `flutter pub get`)
flutter gen-l10n
```

App startup requires `.env.local` in repo root (declared as an asset) with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `GEMINI_API_KEY`. Missing Supabase vars fall back to hardcoded defaults in `main.dart`; missing Gemini key is asserted by `AiConfig.assertConfigured()`.

If a test run fails with a `shaders/ink_sparkle.frag` version exception, it's stale build cache after a Flutter SDK update — run `flutter clean` first.

## Architecture

**Dwaar (دوّر)** — Arabic-first waste-recycling logistics app (Jordan). Three roles, each with its own home shell: **Driver**, **Supplier**, **Recycling Company**. (`lib/ui/features/home/restaurant/` exists but is not wired into `HomeRouter`.)

### Layering

```
lib/domain/        — interfaces only: i_*_repository.dart, i_*_service.dart, entities, AppFailure
lib/data/          — implementations: mock_* and supabase_* repositories, services, models
lib/core/          — config, constants, theme, Result type (core/result/), ViewState (core/state/)
lib/ui/            — feature-scoped MVVM (Provider)
lib/backend_integration_locally/local_store.dart — local JSON persistence (survives restarts)
```

Data flow is **hybrid**: `AppOrderStore` (the central `ChangeNotifier` for all order state, provided app-wide in `main.dart`) writes to `LocalStore` locally and mirrors to `SupabaseOrderRepository`. Auth is still `MockAuthRepository`; Supabase auth/file-storage services exist and are partially wired (`UserSignUpService.setGlobalAuthService` in `main.dart`). When swapping mock → real implementations, bind through the `lib/domain/` interface in `main.dart`'s `MultiProvider`.

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

Tests mirror `lib/` structure under `test/`. `AppOrderStore` lifecycle/persistence tests are the core safety net — run them after touching order state logic.
