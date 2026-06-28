---
name: mock-to-real-swap
description: Pattern for swapping mock implementations to real Supabase ones — all interface pairs, their wiring point, and swap instructions
metadata:
  type: pattern
---

# Mock-to-Real Swap Pattern

Every service has a mock and a real implementation behind a domain interface. Swap happens in `main.dart`'s `MultiProvider` — never in UI code.

## Interface → Mock → Real Map

| Interface | Mock | Real | Wired? |
|---|---|---|---|
| `IAuthRepository` | `MockAuthRepository` | `SupabaseAuthRepository` | ❌ Mock still active |
| `IOrderRepository` | `NoOpOrderRepository` (inline) | `SupabaseOrderRepository` | ✅ Real wired |
| `IWalletRepository` | `NoOpWalletRepository` (inline) | `SupabaseWalletRepository` | ❌ No-op still active |
| `IFileStorageRepository` | — | `SupabaseFileStorageRepository` | ✅ Real wired |
| `INotificationService` | `MockNotificationService` | `FcmNotificationService` | ✅ Real wired |
| `IChatRepository` | `MockChatRepository` | — (no Supabase impl) | ❌ Mock only |
| `IEarningsRepository` | `MockEarningsRepository` | — (no Supabase impl) | ❌ Mock only |
| `IAiVehicleRegistrationService` | `MockAiVehicleRegistrationService` | `GeminiVehicleRegistrationService` | Swappable by config |
| `IAiLicenseValidationService` | `MockAiLicenseValidationService` | `GeminiLicenseValidationService` | Swappable by config |
| `IAiMarketplaceService` | `MockAiMarketplaceService` | `MarketAiService` | Swappable by config |

## Swapping Pattern

1. Find the interface binding in `main.dart`'s `MultiProvider`
2. Replace `MockXxx` with `SupabaseXxx(Supabase.instance.client, ...)`
3. Pass any required dependencies via `ctx.read<Dep>()`
4. Run the app — no other files need to change (domain interfaces are stable)

## AI Services Config

`lib/core/config/ai_config.dart` → `AiConfig.assertConfigured()` is called at startup. If `GEMINI_API_KEY` is absent in `.env.local`, the app crashes intentionally. The mock AI services are wired per-viewmodel, not via the root provider — look at the VM constructor for the specific view (e.g., `VehicleRegistrationViewModel`).

## NoOp Implementations

`NoOpOrderRepository` and `NoOpWalletRepository` are inline classes inside their respective files that return `Success(null)` on every method and emit empty streams. They exist so tests and pure-mock builds compile without Supabase.

## Related Pages

- [[concepts/app-architecture]]
- [[patterns/auth-flow]]
- [[products/supabase]]
