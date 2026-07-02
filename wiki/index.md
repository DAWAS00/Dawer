# Dwaar Wiki — Table of Contents

Arabic-first waste-recycling logistics app for Jordan. Flutter + Supabase + Gemini AI.

---

## Concepts

- [App Architecture](concepts/app-architecture.md) — Layered structure (domain/data/ui), Provider setup, hybrid data flow, what's NOT wired
- [Order Lifecycle](concepts/order-lifecycle.md) — Order model, 3 types, status state machine, vehicle constraints, 16 waste types
- [AppOrderStore](concepts/app-order-store.md) — Central ChangeNotifier, all role-scoped views, all order mutations
- [User Roles](concepts/user-roles.md) — Driver/Supplier/RecyclingCo, SupplierType, mock test accounts, HomeRouter dispatch
- [Reward Service](concepts/reward-service.md) — Driver payout formula, vehicle fees, material rates, FeeCalculator (supplier-facing)
- [Features — Done vs Next](concepts/features-done-vs-next.md) ⭐ — Complete checklist of what works vs what needs wiring

## Patterns

- [MVVM with Provider](patterns/mvvm-provider.md) — VM lifecycle, tab consumption pattern, ViewState, Result type
- [Auth Flow](patterns/auth-flow.md) — Splash→Login→OTP→HomeRouter, signup wizard steps, mock vs real Supabase paths
- [Mock-to-Real Swap](patterns/mock-to-real-swap.md) — Full interface→mock→real table, swap instructions for each service
- [Localization & Theme](patterns/localization-theme.md) — ARB files, context.l10n, AppColors tokens, dark/light, Cairo font

## Products

- [Supabase](products/supabase.md) — Tables, RPC functions, Realtime streams, storage, auth wiring
- [Gemini AI](products/gemini-ai.md) — Vehicle scan, license validation, marketplace AI, Dawa chatbot
- [Flutter Packages](products/flutter-packages.md) — All dependencies with purpose, version, and usage notes

---

## Quick Navigation for "What's Next"

See [[concepts/features-done-vs-next]] for the full list. Top priorities:

1. **Wire real auth** — swap `MockAuthRepository` → `SupabaseAuthRepository` in `main.dart`
2. **Wire wallet** — pass `SupabaseWalletRepository` to `AppOrderStore` constructor
3. **Driver Supabase stream** — implement proper pending-order filter for drivers
4. **PDF reports** — implement `pdf_report_service.dart` concrete class
5. **Earnings real data** — bind Supabase earnings source once table confirmed
6. **go_router migration** — optional but needed for deep linking / auth guards
