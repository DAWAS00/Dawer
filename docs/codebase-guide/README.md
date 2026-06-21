# Dwaar (دوّر) Codebase Guide

This directory contains a comprehensive, engineer-facing guide to the Dwaar Flutter application and its Supabase/Firebase/Gemini backend. It was written to give any developer a fast, accurate understanding of how the project is organized, how the major features work, and what remains to be done before production.

## Audience

- New engineers joining the project
- Reviewers auditing architecture or security
- AI agents or contractors asked to modify the codebase

## How to use this guide

Read the sections in order if you are new. Jump to a specific section if you are fixing or extending a feature.

## Sections

| # | File | What it covers |
|---|---|---|
| 1 | [`01-product-overview.md`](01-product-overview.md) | What Dwaar is, the three-sided marketplace, user roles, and core value propositions |
| 2 | [`02-architecture.md`](02-architecture.md) | Flutter layer architecture, state management, dependency injection, navigation, and folder conventions |
| 3 | [`03-authentication.md`](03-authentication.md) | Login, OTP, signup wizards, and the current Mock-vs-Supabase split |
| 4 | [`04-order-lifecycle.md`](04-order-lifecycle.md) | Order types, statuses, state machine, and role-specific actions |
| 5 | [`05-tracking-and-proximity.md`](05-tracking-and-proximity.md) | Real-time driver tracking, 200 m geofences, fraud signals, and `verify_arrival` |
| 6 | [`06-wallet-and-pricing.md`](06-wallet-and-pricing.md) | `RewardService`, escrow holds/releases, wallet RPCs, and daily payout |
| 7 | [`07-ai-services.md`](07-ai-services.md) | Gemini integrations for vehicle docs, waste classification, and license validation; on-device ML Kit |
| 8 | [`08-supabase-backend.md`](08-supabase-backend.md) | Postgres schema, migrations, functions, triggers, RLS policies, and storage |
| 9 | [`09-push-notifications.md`](09-push-notifications.md) | FCM, `send_push`, `match_driver`, status-change webhooks, and client binding |
| 10 | [`10-production-readiness.md`](10-production-readiness.md) | Documented gaps, known inconsistencies, and recommended production roadmap |

## Quick orientation

- **Flutter entry point:** `lib/main.dart`
- **State management:** Provider + ChangeNotifier
- **Backend:** Supabase (Postgres + Realtime + Edge Functions + Storage)
- **Push:** Firebase Cloud Messaging (FCM)
- **AI:** Google Gemini (`google_generative_ai`) + on-device ML Kit
- **Localization:** Arabic-first, RTL, ARB files in `lib/l10n/`

## Important caveat

As of the latest codebase review, the runtime path is optimized for **development and demos**: mock authentication is wired by default, OTP validation is disabled, and several AI flows still fall back to mock services. The backend schema and edge functions are production-grade in design, but the Flutter wiring is incomplete. See [`10-production-readiness.md`](10-production-readiness.md) for the full list and prioritization.
