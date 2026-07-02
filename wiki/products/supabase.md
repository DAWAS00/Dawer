---
name: supabase
description: Supabase integration in Dwaar — tables, RPC functions, Realtime streams, storage, and auth wiring
metadata:
  type: product
---

# Supabase

Project URL: stored in `.env.local` as `SUPABASE_URL` (fallback hardcoded in `main.dart`).

Package: `supabase_flutter: ^2.8.4`

## Tables Used

| Table | Repository | Notes |
|---|---|---|
| `orders` | `SupabaseOrderRepository` | All order types; primary key `id` (UUID from Supabase, string IDs for local) |
| `profiles` | `SupabaseAuthService` | User profiles with role, supplier_type, vehicle info, location |
| `wallet_*` (inferred) | `SupabaseWalletRepository` | Wallet holds/releases per order — not yet wired |

## RPC Functions

| Function | Called By | Purpose |
|---|---|---|
| `record_order_transaction` | `SupabaseOrderRepository.recordTransaction()` | Records driver earnings breakdown after completion |
| `daily_payout` (edge function) | — | Admin-triggered daily payout (deployed as edge function) |

## Realtime / Streams

`SupabaseOrderRepository.watchOrders()` uses `.stream(primaryKey: ['id'])` — Supabase Realtime.

`watchOrdersForUser()` scopes by:
- `supplier_id` for suppliers
- `company_id` for recycling companies
- Full stream for drivers (RLS enforces visibility client-side filtered in AppOrderStore)

## Storage

`SupabaseFileStorageRepository` — uploads profile photos and identity documents.
Called from `UserSignUpService.signUp()` with `File? profilePhoto` and `File? identityDocument`.

Bucket naming: check `supabase_file_storage_repository.dart` for bucket names.

## Auth

Supabase Auth is **initialized** at startup via `SupabaseService.initialize()`.
`SupabaseAuthService` uses **password-based** auth (`signInWithPassword`).
`SupabaseAuthRepository` also supports OTP via `auth.signInWithOtp(phone:)` + `auth.verifyOTP()`.

Current status: `IAuthRepository` in `main.dart` is `MockAuthRepository`. Real auth repo is written but not injected.

## Supabase Map Serialization

`lib/data/models/order_supabase_ext.dart` — `Order.toSupabaseMap()` / `orderFromSupabaseJson()`. Handles snake_case ↔ camelCase conversion and enum serialization.

## Related Pages

- [[patterns/mock-to-real-swap]]
- [[concepts/app-architecture]]
- [[patterns/auth-flow]]
