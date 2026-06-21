# Dwaar (دوّر) — Agent Guide

> AI-coding-agent reference for the Dwaar Flutter project. Read this first before modifying code.

## 1. Project Overview

**Dwaar (دوّر)** is an Arabic-first, RTL Flutter mobile marketplace for recycling logistics in Jordan. It connects three roles around recyclable waste:

- **Supplier** — households, shops, restaurants, and businesses that list sorted recyclable waste.
- **Driver** — gig-economy transporters who accept pickup and delivery jobs.
- **Recycling Company** — buyers that post collection jobs and purchase marketplace listings.

The codebase is a cross-platform Flutter app (iOS, Android, Web, Desktop targets exist) backed primarily by **Supabase** (Postgres + Realtime + Edge Functions + Storage). AI features use **Google Gemini** (`google_generative_ai`) and on-device **ML Kit** image labeling.

> **Backend strategy (locked 2026-06-20):** see [`docs/architecture-decisions/backend-strategy.md`](docs/architecture-decisions/backend-strategy.md). **Primary backend = Supabase** (auth via phone OTP, Postgres + PostGIS + RLS, Realtime, Storage), structured for a future GCP-native swap. A complete Python/FastAPI **GCP re-platform exists under `backend/` but is NOT wired** into the app — it is the reference blueprint for the future swap. An AWS design doc (`docs/system-design/Dwaar_System_Design.docx`) is the North Star for the heavy realtime tier only, deferred behind a scale gate. FCM push is **not configured** (no `google-services.json`); `flutter_local_notifications` is declared but not initialized.

> **Important runtime reality:** as of the `mohammad` branch the app boots into a **hybrid/mock mode** — `MockAuthRepository` is wired, OTP validation is disabled, and several AI/signup paths fall back to mock services, while order persistence runs against `SharedPreferences` via `LocalStore`. The Supabase schema and Edge Functions are production-grade in design. Treat any path through `main.dart` as the source of truth for what is actually running. The approved plan is to restore the Supabase wiring; see the ADR.

## 2. Technology Stack

| Layer | Technology |
| --- | --- |
| Mobile framework | Flutter 3.x (Dart SDK `^3.8.0` in `pubspec.yaml`) |
| State management | `provider` + `ChangeNotifier` |
| Navigation | Imperative `Navigator.push` / `pushReplacement` (no named routes; `go_router` is in `pubspec.yaml` but unused) |
| Backend | Supabase (Postgres, Auth, Realtime, Storage, Edge Functions). A GCP-native Python backend (`backend/`) exists as **reference only**. |
| Maps | `google_maps_flutter` |
| Location | `geolocator` + foreground service |
| AI | `google_generative_ai` (Gemini 1.5 Flash) + `google_mlkit_image_labeling` |
| Local persistence | `SharedPreferences` via `LocalStore` (`lib/backend_integration_locally/local_store.dart`) |
| Code generation | `freezed` + `json_serializable` |
| Localization | ARB files (`lib/l10n/app_ar.arb`, `app_en.arb`), Arabic is the template |
| Linting | `flutter_lints` via `analysis_options.yaml` |

## 3. Project Structure

```text
lib/
├── backend_integration_locally/   # Local persistence layer
│   └── local_store.dart           # SharedPreferences wrapper for users, orders, drafts, session
├── core/                          # Cross-cutting concerns
│   ├── config/                    # AiConfig, env helpers
│   ├── constants/                 # AppColors, tokens, icons
│   ├── layout/                    # Layout helpers
│   ├── result/                    # Result<S,F> monad
│   ├── services/                  # AppThemeNotifier, AppLangNotifier, SupabaseService
│   ├── state/                     # ViewState<T> sealed class
│   ├── theme/                     # AppTheme (light/dark)
│   └── utils/                     # Shared helpers
├── data/                          # Data layer
│   ├── chat/                      # Chat repository implementations
│   ├── mock/                      # Seed data (OrderMockData)
│   ├── models/                    # Freezed models, enums, labels
│   ├── repositories/              # Repository implementations (Supabase + Mock)
│   ├── services/                  # Concrete services (AppOrderStore, RewardService, FCM, AI, etc.)
│   └── utils/                     # Data utilities
├── domain/                        # Domain layer
│   ├── chat/                      # Chat entities/repos
│   ├── entities/                  # Domain entities (earnings, etc.)
│   ├── failures/                  # AppFailure hierarchy
│   ├── repositories/              # Repository interfaces (IAuthRepository, IOrderRepository, ...)
│   ├── requests/                  # Request DTOs (CreatePickupRequest, SignUpRequest)
│   └── services/                  # Service interfaces (ILocationPublisher, INotificationService, AI, ...)
├── l10n/                          # ARB files + generated localizations
├── ui/                            # Presentation layer
│   ├── common/                    # Shared widgets (map, wizard)
│   ├── core/components/           # Reusable UI components
│   └── features/                  # Feature-scoped screens + viewmodels
│       ├── auth/                  # Login, OTP, signup wizards
│       ├── chat/                  # Chat screens
│       ├── chatbot/               # AI support chatbot
│       ├── earnings/              # Earnings/wallet UI
│       ├── home/                  # Role-specific home shells
│       │   ├── driver/
│       │   ├── recycling/
│       │   ├── restaurant/        # Exists but not wired into HomeRouter
│       │   ├── shared/            # Order cards, marketplace, order details
│       │   └── supplier/
│       └── splash/
└── main.dart                      # App bootstrap + provider graph

supabase/
├── functions/                     # Deno/TypeScript Edge Functions
│   ├── _shared/fcm.ts
│   ├── daily_payout/
│   ├── match_driver/
│   ├── send_push/
│   └── verify_arrival/
└── migrations/                    # Postgres schema migrations (apply in order)

test/                              # Tests mirror lib/ structure
```

## 4. Build, Run, and Test Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device / emulator / windows
flutter run
flutter run -d windows      # convenience script: launch_app.bat

# Lint
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/file.dart

# Build APK
flutter build apk
flutter build apk --debug

# Code generation (freezed/json_serializable models in lib/data/models/order/)
dart run build_runner build --delete-conflicting-outputs

# Localization (regenerates lib/l10n/generated/ from .arb files)
flutter gen-l10n
```

### Current verification status (as of last check)

- `flutter analyze` — **passes** (`No issues found!`).
- `flutter test` — **8 tests failing**. Known failures include:
  - `test/data/repositories/mock_auth_repository_test.dart` — `verifyOtp` behavior changed in source.
  - `test/ui/features/chat/chat_view_test.dart` — empty state and message-list rendering failures.
  - Additional failures in the same widget test suite.

If a test run fails with a `shaders/ink_sparkle.frag` version exception, run `flutter clean` first (stale build cache after Flutter SDK update).

## 5. Configuration and Secrets

The app requires an `.env.local` file in the repo root. It is declared as an asset in `pubspec.yaml` and loaded at startup by `flutter_dotenv`.

Required variables:

```text
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY=your-gemini-key
```

Behavior when missing:

- Missing Supabase vars fall back to hardcoded defaults in `main.dart` (dev project).
- Missing Gemini key is warned by `AiConfig.assertConfigured()`; AI services fall back to mock mode.

> **Never commit `.env.local`.** It is listed in `.gitignore` along with `lib/core/constants/map_tokens.dart`, Android `local.properties`, and `.vscode/launch.json`.

For VS Code debugging, copy `.vscode/launch.example.json` to `.vscode/launch.json` and set `GEMINI_API_KEY` via `--dart-define`.

## 6. Architecture and Conventions

### Layered architecture

- `lib/domain/` — interfaces, entities, failures, request DTOs. No Flutter/Supabase imports ideally.
- `lib/data/` — repository implementations (Supabase + Mock), services, models.
- `lib/core/` — config, constants, theme, `Result`, `ViewState`.
- `lib/ui/` — feature-scoped MVVM using `provider`.

### State management

- **Provider + ChangeNotifier** is the real runtime pattern.
- `AppOrderStore` (`lib/data/services/app_order_store.dart`) is the **single source of truth** for all order state. It is provided at the root in `main.dart`.
- Role-specific home viewmodels receive `AppOrderStore` and `addListener` to it.
- `ViewState<T>` (`lib/core/state/view_state.dart`) is used by some screens: `Idle`, `Loading`, `Loaded`, `Failed`.

### Dependency injection

Manual via `MultiProvider` in `main.dart`. Repository swapping is the intended pattern:

| Interface | Current binding | Alternative |
| --- | --- | --- |
| `IAuthRepository` | `MockAuthRepository` | `SupabaseAuthRepository` |
| `IOrderRepository` | `SupabaseOrderRepository` | `NoOpOrderRepository` (tests) |
| `IWalletRepository` | `NoOpWalletRepository` (default) | `SupabaseWalletRepository` |
| `IChatRepository` | `MockChatRepository` | (not yet implemented) |
| `INotificationService` | `FcmNotificationService` | mock (deleted from repo) |

### Result / failure pattern

Use `AppResult<T>` = `Result<T, AppFailure>` across layer boundaries. Repository implementations catch exceptions and map them to `AppFailure` subtypes (`NetworkFailure`, `AuthFailure`, `ValidationFailure`, `NotFoundFailure`, `PermissionFailure`, `StorageFailure`, `UnknownFailure`).

### Navigation flow

```text
SplashView → LoginView → VerificationView → HomeRouter
```

`HomeRouter` switches on `UserRole` + `SupplierType` and mounts the correct home shell. Navigation is imperative; `go_router` is not used.

### Models

- `Order` is a **freezed** model in `lib/data/models/order/order.dart`.
- Enums live in `lib/data/models/order/order_enums.dart`; Arabic/English label extensions are in `lib/data/models/order/order_labels.dart` and similar extension files.
- **Always** display enum values via `.label` / `.shortLabel`, never raw enum names.
- Edit the `.dart` source, then run `build_runner`. Never hand-edit `*.freezed.dart` / `*.g.dart`.

### Localization and theme

- Bilingual ar/en via ARB files in `lib/l10n/`. Use `context.l10n.<key>` (`lib/l10n/l10n.dart`).
- Direction follows locale via `AppLangNotifier`.
- New UI code still contains some hardcoded Arabic strings — prefer adding ARB keys.
- Light/dark themes in `lib/core/theme/app_theme.dart`; colors from `AppColors` (`lib/core/constants/app_colors.dart`).
- Font: Google Fonts `Cairo` for Arabic text.
- Portrait orientation is forced in `main.dart`.

## 7. Code Style Guidelines

- Dart style is enforced by `flutter_lints` (`analysis_options.yaml`).
- Run `flutter analyze` before committing.
- Prefer **semantic color names** from `AppColors` over raw hex in UI code.
- Use **ARB keys** for user-visible strings; avoid hardcoded Arabic/English text in new widgets.
- Follow the existing **feature-scoped MVVM** folder layout: `views/`, `viewmodels/`, `widgets/`, `controllers/`.
- Keep domain interfaces free of Flutter/Supabase imports.
- Use `AppResult<T>` for cross-layer results; avoid throwing exceptions across boundaries.
- When adding freezed models, regenerate via `build_runner` and commit generated files.

## 8. Testing Instructions

- Tests mirror `lib/` under `test/`.
- Unit and widget tests use `flutter_test`.
- Core safety-net tests are `AppOrderStore` lifecycle/persistence tests (`test/data/app_order_store_*_test.dart`). Run these after touching order state logic.
- Run the full suite with `flutter test`.
- Some widget tests currently fail; fix regressions when they are directly related to your changes. Do not ignore new failures introduced by edits.

## 9. Security Considerations

- **Service-role key (`SUPABASE_SERVICE_ROLE_KEY`)** must never ship in the Flutter app. It is only for Edge Functions and server-side tooling.
- **Anon key and Gemini key** live in `.env.local` / `--dart-define`; do not commit them.
- **Google Maps API key** is read from `android/local.properties` into `AndroidManifest.xml` via `MAPS_API_KEY` placeholder. `local.properties` is gitignored.
- RLS is enabled on all business tables. Edge Functions use `service_role` where necessary (e.g., `verify_arrival`, `send_push`).
- `MockAuthRepository` disables OTP validation and respects the UI-selected role — this is intentional for development but **not safe for production**.
- Location permissions are declared in `AndroidManifest.xml` (`FINE`, `COARSE`, `BACKGROUND`, foreground service). Location is published only while an order is active and is deleted on completion/cancellation.

## 10. Backend and Deployment

### Supabase migrations

Apply migrations in `supabase/migrations/` in filename order:

```text
00001_initial_schema.sql
00002_add_user_categories.sql
20260519_security_tables.sql
20260522_driver_locations.sql
20260522_marketplace_limits.sql
20260522_transaction_commission.sql
20260522_vehicle_type.sql
20260522_wallet_functions.sql
20260612_push_and_matching.sql
```

### Edge Functions

Deploy via the Supabase CLI:

```bash
supabase functions deploy verify_arrival --project-ref <ref>
supabase functions deploy match_driver --project-ref <ref>
supabase functions deploy send_push --project-ref <ref>
supabase functions deploy daily_payout --project-ref <ref>
```

Required secrets:

```bash
supabase secrets set FCM_SERVICE_ACCOUNT="$(cat service-account.json)" --project-ref <ref>
# service_role_key is stored via vault for the status-change webhook
```

### Android release build

- The release signing config currently uses debug keys (`android/app/build.gradle.kts`). Replace with a real signing config for production.
- `applicationId` is currently `com.example.dwaar`; update for production.
- Firebase project setup is required for FCM: add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

## 11. Known Gaps and Inconsistencies

Read `devPlans/production_gaps_analysis.md`, `docs/codebase-guide/`, and [`docs/architecture-decisions/backend-strategy.md`](docs/architecture-decisions/backend-strategy.md) for full detail. Highlights:

- **Backend reconciliation (resolved 2026-06-20):** three backend visions existed on this branch — (A) deleted Supabase code, (B) uncommitted GCP-native Python `backend/`, (C) an AWS design doc. Decision: **restore (A) Supabase as primary**, keep (B) as **reference only**, and treat (C) as a North Star for the realtime tier only, deferred behind a scale gate. See the ADR. FCM `firebase_core` / `firebase_messaging` are **not** in `pubspec.yaml` despite earlier docs implying they were.
- **`match_driver` / `send_push` / `_shared/fcm.ts` Edge Functions never existed** in the repo despite earlier docs listing them — `git ls-tree HEAD -- supabase/` shows only `verify_arrival` and `daily_payout`. Dispatch/matching and FCM push are new work whenever tackled.
- **Auth wiring split (being resolved):** `MockAuthRepository` is active by default; the deleted `SupabaseAuthRepository` matches `IAuthRepository` (phone OTP) and is being restored as the primary binding; the deleted `SupabaseAuthService` (email/password) caused the documented mismatch and is **not** restored as an `IAuthRepository` binding.
- **Local backend integration incomplete**: `lib/backend_integration_locally/` only contains `local_store.dart`. Missing: `local_user.dart`, `otp_record.dart`, `local_auth_service.dart`, `local_notification_service.dart`.
- **FCM not configured**: no `google-services.json` in repo; `flutter_local_notifications` is declared in `pubspec.yaml` but never initialized; push features soft-fail at runtime.
- **AI signup verification prototype**: planned in `plan/feature-ai-signup-verification-1.md`; partially implemented but still demo-grade. AI features are otherwise working via Gemini.
- **`daily_payout` Edge Function** has a latent bug: it inserts notifications with column `user_id`, but the `notifications` table FK is `recipient_id` — will fail at runtime until fixed.
- **Restaurant home** exists under `lib/ui/features/home/restaurant/` but is not wired into `HomeRouter`; store-business suppliers route to `RestaurantHomeView`.
- **Schema gaps not covered by the restored Supabase schema or the design doc:** marketplace/collection-sale listing flow and detailed wallet/commission ledger. (Chat is now covered: `00003_chat.sql` migration + `SupabaseChatRepository` with Realtime.) These remaining gaps are tracked as Phase 4 follow-up.

## 12. Documentation Index

- `CLAUDE.md` — concise command + architecture cheat sheet.
- `GEMINI.md` — knowledge-management workflow for Obsidian vault integration.
- `GAMMA_PROMPT.md` — presentation prompt for the app.
- `docs/codebase-guide/*.md` — detailed guides for architecture, auth, order lifecycle, tracking, wallet/pricing, AI, Supabase backend, and push notifications.
- `docs/supabase/auth-configuration.md` — live Supabase auth checklist and rate limits.
- `docs/supabase/edge-functions.md` — Edge Function catalogue.
- `devPlans/*.md` — implementation reports and production gap analysis.
- `plan/*.md` — feature implementation plans.
