# CLAUDE.md

File guides Claude Code when working in this repo.

## Commands

```bash
# Run on connected device/emulator
flutter run

# Build APK
flutter build apk

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

## Architecture

**Dwaar (دوّر)** — Arabic waste-recycling logistics app (RTL, Jordan). Three roles, each own home shell: **Driver**, **Supplier**, **Recycling Company**.

### Pattern: Feature-Scoped MVVM with Provider

Each role lives under `lib/ui/features/home/<role>/`, same structure:
- `<role>_home_view.dart` — root scaffold + bottom nav
- `viewmodels/<role>_home_viewmodel.dart` — `ChangeNotifier`, owns state + logic
- `tabs/` — tab screens (home, orders, profile)
- `widgets/` — role-specific UI

VMs provided at home-view via `ChangeNotifierProvider`. Tabs read state with `context.watch<VM>()`, call methods on VM directly.

### Data Layer

```
lib/data/
  models/     — plain Dart classes (Order, User) with copyWith
  mock/       — OrderMockData, used by all three VMs
  repositories/ — AuthRepository (thin wrapper over AuthService)
  services/   — local backend-facing services (auth/signup/rewards)
```

Data flow is local-first (no cloud backend dependency in runtime flow).

### Shared Order UI

`lib/ui/features/home/shared/` — role-agnostic order UI:
- `order_details_view.dart` + `order_details/` — full order detail screen
- `marketplace_tab.dart` + `viewmodels/marketplace_viewmodel.dart` — shared marketplace
- `order_card.dart`, `order_tracking_card.dart` — reusable list items

### Auth & Routing

`SplashView` → `LoginView` (role picker + phone/email) → `VerificationView` → `HomeRouter`.

`HomeRouter` takes `UserRole` (enum: `driver`, `supplier`, `recyclingCo`) + `SupplierType` (enum: `individual`, `storeBusiness`), renders correct home shell. No named routes — imperative nav (`Navigator.push`/`pushReplacement`).

### Key Enums (in `lib/data/models/order.dart`)

`OrderType`, `OrderStatus`, `WasteType`, `WasteForm`, `WeightCategory`, `PickupTarget` — each has Arabic-label extension. Always use `.label` / `.shortLabel` for display.

### Theme & Assets

- Colors: `AppColors` in `lib/core/constants/app_colors.dart` — use token names (`primaryGreen`, `accentAmber`, status colors), not raw hex.
- Images: `lib/core/constants/app_assets.dart`; files in `assets/images/`.
- Font: Google Fonts (runtime). Theme in `lib/core/theme/app_theme.dart`.
- Forced portrait (`DeviceOrientation.portraitUp`), globally RTL (`TextDirection.rtl`).