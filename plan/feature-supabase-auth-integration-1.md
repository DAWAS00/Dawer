---
goal: Replace mock auth with live Supabase OTP-based sign-up + login, with persisted session and role-aware home routing
version: 1.0
date_created: 2026-04-22
last_updated: 2026-04-22
owner: Dawer Team
status: 'Not started'
tags: [feature, auth, supabase, otp, signup, login]
---

# Introduction

![Status: Not started](https://img.shields.io/badge/status-Not%20started-lightgrey)

Wire the existing sign-up + login UI to Supabase Auth using phone OTP (primary)
and email OTP (fallback). On successful OTP verification, create or read the
matching `public.users` row and route the user to the correct home screen
for their role. The DB schema, RLS policies, and client-side validation
(`SignUpRequest.validate()`) are already in place — this plan wires them into
the live UI and replaces the 1.2 s mock delays.

## 1. Requirements & Constraints

- **REQ-001**: Sign-up collects name + phone (+ optional email) and sends an
  OTP via `auth.signInWithOtp(phone: ...)`.
- **REQ-002**: Verification screen calls `auth.verifyOTP(...)` and inserts a
  `public.users` row on first success.
- **REQ-003**: Login collects phone (or email) and reuses the same OTP flow;
  if a `public.users` row already exists, skip the insert and proceed to home.
- **REQ-004**: Session survives app restart — `supabase_flutter` handles this
  via `persistSession: true` (default), but the Flutter app needs a splash
  screen that reads `Supabase.instance.client.auth.currentSession` and routes.
- **REQ-005**: Role comes from the `public.users` row, not from UI state — so
  a user who signed up as `driver` cannot be upgraded to `recyclingCo` by
  tweaking local state.
- **REQ-006**: Driver sign-up must collect `vehicle_plate` (required by
  `chk_driver_fields`). A new input appears on the signup form when
  `role == driver`.
- **REQ-007**: `UserSignUpService` gains two OTP methods and the existing
  password-based `signUp()` is retained for admin/service flows.
- **REQ-008**: All network failures surface via `SignUpException` /
  `AuthException` with Arabic user-facing messages.
- **CON-001**: `supabase/config.toml` currently has `[auth.sms] enable_signup = false`
  and `[auth.email] enable_confirmations = false`. SMS OTP requires a Twilio
  project; until that lands, email OTP is the only live path.
- **CON-002**: No new columns on `public.users` — the existing schema is
  sufficient. Any schema change must land in a new migration file.
- **CON-003**: RLS policy `users_insert_own` requires `auth.uid() = auth_id`.
  OTP `verifyOTP` sets the session, so the insert that follows runs as the
  new user — policy passes.
- **PAT-001**: Service errors thrown as `SignUpException` (validation) or
  wrapped `AuthException` (network). VMs catch and translate to `errors` map.
- **PAT-002**: Pending sign-up state (the `SignUpRequest` being verified) is
  forwarded via widget constructor props, **not** a global singleton — same
  pattern as today.
- **GUD-001**: Keep the existing mock path runnable behind a build-time flag
  so demos without a live Supabase project still work.
- **GUD-002**: No breaking changes to existing widget APIs — extend, don't
  replace.

## 2. Implementation Steps

### Phase 1 — Supabase config + secrets (MVP: email OTP only)

- GOAL-001: Confirm email OTP works end-to-end on the live project; defer phone until Twilio is verified. See `docs/supabase/auth-configuration.md` for dashboard details.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Update `supabase/config.toml` — `[auth.email] enable_confirmations = true`, keep `[auth.sms]` disabled, add inline rationale | ✅ | 2026-04-22 |
| TASK-001a | Create `docs/supabase/auth-configuration.md` documenting dashboard steps + deliverability smoke-test commands | ✅ | 2026-04-22 |
| TASK-001b | Replace the Magic Link email template with the Arabic OTP body (dashboard task) | | |
| TASK-002 | Phone/Twilio **deferred**; checklist + flip instructions captured in `docs/supabase/auth-configuration.md §2` | ✅ (documented) | 2026-04-22 |
| TASK-003 | Run the deliverability smoke test from `docs/supabase/auth-configuration.md §1` with a real inbox; confirm 6-digit code arrives | | |

### Phase 2 — Service layer (OTP path)

- GOAL-002: Extend `UserSignUpService` + add `AuthService`, backed by the spec in `docs/auth/login-signup-design.md`

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-004 | Make `SignUpRequest.password` nullable; adjust `validate()` to skip password checks when null | | |
| TASK-005 | Add `Future<void> requestOtp(SignUpRequest r)` — calls `auth.signInWithOtp(phone/email, shouldCreateUser: true)` | | |
| TASK-006 | Add `Future<Map<String, dynamic>> verifyOtpAndCreateProfile(SignUpRequest r, String otp)` — verifyOTP + upsert profile (idempotent on retry) | | |
| TASK-007 | Add `Future<Map<String, dynamic>?> getOrCreateProfile(User authUser)` helper used by both signup and login paths | | |
| TASK-008 | Add new exception subclasses: `OtpRequestException`, `OtpVerifyException` (with typed sub-cases: unregistered / rateLimited / badIdentifier / invalid / network) | | |
| TASK-008a | New migration `20260422000012_identifier_exists_rpc.sql` (see spec §6.2) + apply via MCP | | |
| TASK-008b | Add `lib/data/services/auth_service.dart` — thin wrapper: `identifierExists`, `requestLoginOtp`, `verifyLoginOtp`, `signOut`, `authStream` | | |

### Phase 3 — Sign-up UI wiring

- GOAL-003: Replace mock submit with real OTP request

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-009 | `SignUpViewModel` accepts `UserSignUpService?` (default `UserSignUpService()`); add `buildRequest()` + `submit()` calls service | | |
| TASK-010 | Add a driver-only vehicle plate input to `signup_view.dart` (shown iff `role == driver`); wire `vehiclePlate` error | | |
| TASK-011 | `SignUpView` forwards the built `SignUpRequest` into `VerificationView` via constructor | | |
| TASK-012 | Enforce phone-required at submit (drop the "phone OR email" fallback) and update l10n strings | | |

### Phase 4 — Verification UI wiring

- GOAL-004: Replace mock verify with real verifyOTP + profile insert

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | `VerificationView` accepts optional `SignUpRequest pendingRequest` | | |
| TASK-014 | `VerificationViewModel` accepts the request + a `UserSignUpService`; `verify()` calls `service.verifyOtpAndCreateProfile(...)` when a pending request is present, otherwise calls `service.getOrCreateProfile(session.user)` for the login path | | |
| TASK-015 | Surface `SignUpException.message` and `fieldErrors` in the verification error UI | | |
| TASK-016 | On success, push `HomeRouter(role: profile.role, ...)` using the DB-returned role, not the UI-passed one | | |

### Phase 5 — Login wiring

- GOAL-005: Replace `MockAuthService` with live OTP-based login

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-017 | `LoginViewModel.continueWithIdentifier()` — parses identifier, calls `AuthService.identifierExists`, then either `requestLoginOtp` or emits `AuthRedirect.signupPrefill` per spec §4.2 | | |
| TASK-018 | Navigate to `VerificationView` with `pendingRequest: null` (login branch) | | |
| TASK-019 | Remove `MockAuthService` wiring; keep class for tests | | |
| TASK-020 | Add guard: if `getOrCreateProfile` returns null (no profile + no pending request), navigate to sign-up with contact pre-filled | | |
| TASK-020a | Sign-up view accepts `prefillPhone` / `prefillEmail` constructor args and pre-populates the form | | |

### Phase 6 — Session bootstrap + route guard

- GOAL-006: Restore session on cold start and gate routes on auth state

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-021 | `main.dart` awaits `SupabaseService.init()` before `runApp` (already partly done — verify) | | |
| TASK-022 | New `AuthGate` widget that reads `auth.currentSession` on build and chooses splash → home router → login | | |
| TASK-023 | Subscribe to `auth.onAuthStateChange` to react to sign-out / token refresh | | |
| TASK-024 | Add a "log out" action in each home view that calls `auth.signOut()` | | |

### Phase 7 — Tests

- GOAL-007: Unit + service tests covering both flows

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-025 | Extend `user_signup_request_test.dart` with nullable-password cases | | |
| TASK-026 | Add `user_signup_service_otp_test.dart` — happy path + error mapping with a fake `SupabaseClient` | | |
| TASK-027 | `signup_viewmodel_test.dart` — inject a fake service and assert `requestOtp` is called with the right shape | | |
| TASK-028 | `verification_viewmodel_test.dart` — fake service, assert `verifyOtpAndCreateProfile` is called and profile is forwarded | | |
| TASK-029 | `auth_gate_test.dart` — widget test with a fake auth stream | | |
| TASK-030 | `flutter analyze` clean + `flutter test` all pass | | |

## 3. Alternatives

- **ALT-001**: Password-only signup using existing `auth.signUp(password: ...)` — rejected because the UI never collects passwords and adding that field is a larger UX change than the OTP rewiring.
- **ALT-002**: Magic-link emails instead of OTP — rejected because the current UI has 6 OTP inputs already; reusing that surface is cheaper.
- **ALT-003**: Global `AuthCubit` / `AuthBloc` — rejected for consistency with the current Provider/ChangeNotifier pattern.

## 4. Dependencies

- **DEP-001**: `supabase_flutter ^2.8.0` (already installed)
- **DEP-002**: Supabase dev project with email OTP template configured
- **DEP-003** *(optional)*: Twilio credentials for SMS OTP

## 5. Files

- **FILE-001**: `supabase/config.toml` — email OTP enabled
- **FILE-002**: `lib/data/services/user_signup_service.dart` — OTP methods + nullable password
- **FILE-003**: `lib/ui/features/auth/viewmodels/signup_viewmodel.dart` — service injection + real submit
- **FILE-004**: `lib/ui/features/auth/views/signup_view.dart` — vehicle plate input + forward request
- **FILE-005**: `lib/ui/features/auth/views/verification_view.dart` — accept pendingRequest prop
- **FILE-006**: `lib/ui/features/auth/viewmodels/verification_viewmodel.dart` — service injection + real verify
- **FILE-007**: `lib/ui/features/auth/viewmodels/login_viewmodel.dart` — swap MockAuthService for UserSignUpService
- **FILE-008**: `lib/ui/features/auth/views/auth_gate.dart` — new splash/router widget
- **FILE-009**: `lib/main.dart` — mount AuthGate as home
- **FILE-010**: `test/data/user_signup_service_otp_test.dart` — new
- **FILE-011**: `test/ui/auth/verification_viewmodel_test.dart` — new
- **FILE-012**: `test/ui/auth/auth_gate_test.dart` — new

## 6. Testing

- **TEST-001**: `requestOtp` validates before calling `auth.signInWithOtp`
- **TEST-002**: `requestOtp` maps `AuthException` to `OtpRequestException`
- **TEST-003**: `verifyOtpAndCreateProfile` inserts when no row exists
- **TEST-004**: `verifyOtpAndCreateProfile` skips insert when row already exists
- **TEST-005**: Uniqueness violation on `phone` surfaces a friendly message
- **TEST-006**: RLS 42501 surfaces as "email confirmation required"
- **TEST-007**: `SignUpViewModel.submit` calls `requestOtp` only when validation passes
- **TEST-008**: `VerificationViewModel.verify` passes role from DB row, not UI prop
- **TEST-009**: `AuthGate` routes to login when no session, to home router when session
- **TEST-010**: `AuthGate` reacts to `auth.signOut()` by routing back to login

## 7. Risks & Assumptions

- **RISK-001**: Twilio is not budgeted — SMS OTP may need to stay mocked in dev until that's resolved. Email OTP unblocks the flow in the meantime.
- **RISK-002**: `public.users` insert fails if RLS evaluates before `currentSession` is set (race). Mitigate with an `await` between `verifyOTP` and `insert`, and surface 42501 as "retry" rather than "failed".
- **RISK-003**: Changing sign-up navigation can break deep links from the role-selection grid if a user taps "log in" from a half-completed state.
- **ASSUMPTION-001**: `auth_id` on `public.users` matches `auth.users.id` exactly — already enforced by the FK.
- **ASSUMPTION-002**: Every new user lands on a supported home view (`driver`, `supplier`, `recyclingCo`) — enum exhaustiveness is guaranteed by Dart.

## 8. Related Specifications / Further Reading

- `docs/supabase/user-signup.md` — current sign-up service contract
- `docs/supabase/edge-functions.md` — downstream edge functions that assume a `public.users` row
- `supabase/migrations/20260422000005_rls_and_views.sql` — RLS policies this plan relies on
- `CLAUDE.md` — project principles (RLS as security boundary, side effects via edge functions)
