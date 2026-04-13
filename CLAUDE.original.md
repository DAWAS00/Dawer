# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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

**Dwaar (دوّر)** — Arabic-language waste-recycling logistics app (RTL, Jordan market). Three user roles each get their own home shell: **Driver**, **Supplier**, **Recycling Company**.

### Pattern: Feature-Scoped MVVM with Provider

Each role lives under `lib/ui/features/home/<role>/` and follows the same structure:
- `<role>_home_view.dart` — root scaffold + bottom nav
- `viewmodels/<role>_home_viewmodel.dart` — `ChangeNotifier`, owns state and business logic
- `tabs/` — tab screens (home, orders, profile)
- `widgets/` — role-specific UI components

ViewModels are provided at the home-view level via `ChangeNotifierProvider`. Tabs read state with `context.watch<VM>()` and call methods directly on the VM.

### Data Layer

```
lib/data/
  models/     — plain Dart classes (Order, User) with copyWith
  mock/       — OrderMockData, used by all three VMs (no backend yet)
  repositories/ — AuthRepository (thin wrapper over AuthService)
  services/   — AuthService (stub; returns raw maps)
```

All data is currently **mock only** — no HTTP calls, no local DB. `AuthRepository`/`AuthService` are stubs that simulate a network delay.

### Shared Order UI

`lib/ui/features/home/shared/` holds order-related UI that is role-agnostic:
- `order_details_view.dart` + `order_details/` sub-widgets — full order detail screen
- `marketplace_tab.dart` + `viewmodels/marketplace_viewmodel.dart` — shared marketplace
- `order_card.dart`, `order_tracking_card.dart` — reusable list items

### Auth & Routing

`SplashView` → `LoginView` (role picker + phone/email) → `VerificationView` → `HomeRouter`.

`HomeRouter` receives `UserRole` (enum: `driver`, `supplier`, `recyclingCo`) and `SupplierType` (enum: `individual`, `storeBusiness`) and renders the correct home shell. No named routes — navigation is imperative (`Navigator.push`/`pushReplacement`).

### Key Enums (in `lib/data/models/order.dart`)

`OrderType`, `OrderStatus`, `WasteType`, `WasteForm`, `WeightCategory`, `PickupTarget` — each has an Arabic-label extension. Always use the extension `.label` / `.shortLabel` for display strings.

### Theme & Assets

- Colors: `AppColors` in `lib/core/constants/app_colors.dart` — use token names (`primaryGreen`, `accentAmber`, status colors), not raw hex.
- Images: `lib/core/constants/app_assets.dart`; asset files live in `assets/images/`.
- Font: Google Fonts (loaded at runtime). Theme defined in `lib/core/theme/app_theme.dart`.
- App is forced portrait (`DeviceOrientation.portraitUp`) and globally RTL (`TextDirection.rtl`).
