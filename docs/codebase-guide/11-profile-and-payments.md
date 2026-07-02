# 11. Profile & Payments

## Overview

The profile UI was recently redesigned into a **unified cross-role component** shared across Driver, Supplier, and Recycling Company. Before this redesign each role had its own profile tab duplicating ~70% of the code. The new system extracts six reusable widgets and adds a payment section with eFawateercom integration.

---

## Profile Architecture

### Shared widgets (lib/ui/features/home/shared/profile/widgets/)

| Widget | Purpose |
|---|---|
| `profile_header.dart` | Gradient hero with avatar, name, role badge, and edit button |
| `profile_stat_card.dart` | Floating card with 2–3 numeric stats (orders, rating, points) |
| `profile_section_header.dart` | Section title with optional trailing action |
| `profile_tile.dart` | Reusable info row (icon + label + value) |
| `profile_action_tile.dart` | Tappable row for settings/actions (theme, language, logout) |
| `payment_wallet_card.dart` | Role-aware payment section (see below) |

### Per-role profile tabs

Each role assembles the shared widgets in a `Column` inside its own profile tab:

- `lib/ui/features/home/driver/tabs/driver_profile_tab.dart`
- `lib/ui/features/home/supplier/tabs/supplier_profile_tab.dart`
- `lib/ui/features/home/recycling/tabs/recycling_profile_tab.dart`

The tabs are thin — they pass role-specific data into the shared widgets.

---

## Profile Header

```dart
// lib/ui/features/home/shared/profile/widgets/profile_header.dart
ProfileHeader(
  name: session.userName,
  role: session.role,
  supplierType: session.supplierType,
  avatarUrl: profile?.profilePhotoUrl,
  onEdit: () { /* push edit screen */ },
)
```

Renders a `LinearGradient` hero from `AppColors.ctaGradientStart` → `AppColors.ctaGradientEnd` with a circular avatar, user name, and a role chip.

---

## PaymentWalletCard (role-aware)

`PaymentWalletCard` switches its content based on `UserRole`:

### Driver view
- **Available balance** — cleared funds ready to withdraw
- **Held amount** — escrow reserved for the active order
- **Withdraw button** — navigates to withdrawal flow (not yet implemented)

### Supplier view
- **Points balance** with animated progress bar to the next reward tier
- Tapping opens `RewardsView` (reward history + tier progress)

### Recycling Company view
- **Billing-period summary** (total volume, total paid) — currently placeholder data

### eFawateercom row
All roles see an eFawateercom (فواتيركم) row at the bottom of the payment section:

```dart
// lib/ui/features/home/shared/profile/widgets/payment_wallet_card.dart
// Teal row with منصة فواتيركم logo placeholder + "Pay bills" label
// Color: AppColors.efawateerTeal (#00796B) / AppColors.efawateerTealBg (#E0F2F1)
```

**What is eFawateercom?** Jordan's national electronic payment gateway operated by the Central Bank of Jordan (CBJ). It is the standard rail for paying government-adjacent services. The integration row links to the platform so users can pay recycling-related government fees. Full biller registration with CBJ is a pending task (see production readiness).

---

## Profile Actions Section

Below the payment card, each profile tab renders:

1. **App settings** — theme toggle (light/dark), language toggle (ar/en)
2. **Help** — static help row (future: in-app FAQ or support chat)
3. **Account** — logout (with confirmation dialog)

Theme and language toggles use `AppThemeNotifier` and `AppLangNotifier` respectively, both provided globally from `main.dart`.

---

## Dark Mode Fixes

The profile redesign fixed several dark-mode rendering bugs:

- `ProfileHeader` gradient was using hardcoded `Color(0xFF...)` values; replaced with `AppColors` tokens so dark theme overrides work.
- Stat card surface was white-only; now uses `Theme.of(context).cardColor`.
- Duplicate "Edit profile" action buttons were removed (appeared in both the header and the action section before the redesign).

---

## Order Tracking Card

`lib/ui/features/home/shared/order_tracking_card.dart` was also improved as part of this work:

- `OrderProgressStepper` now shows three visual states per step: **completed** (filled green), **current** ("you are here" animated halo), **upcoming** (grey).
- A live status banner sits above the stepper with a plain-language description and an ETA pill (for active orders).
- A `Track order (تتبع الطلب)` CTA button is visible while an order is `accepted`, `arrivedAtPickup`, `inTransit`, or `arrivedAtDropoff`. It pushes the live tracking map view.

---

## How to Add a New Profile Section

1. Add a new `ProfileSectionHeader` + content inside the role's `_profile_tab.dart`.
2. If the content is role-specific, use a `switch (role)` inside a single shared widget.
3. If it needs data from the auth session, read it from `context.read<IAuthRepository>().currentSession`.
4. Register new navigation targets imperatively (`Navigator.push`) from `ProfileActionTile.onTap`.

---

## Pending Work

| Item | Status |
|---|---|
| Edit profile screen | Not implemented — the edit button is wired but pushes a placeholder |
| Driver withdrawal flow | `PaymentWalletCard` shows the button; the actual screen is not built |
| eFawateercom deep-link / biller registration | Row exists; biller ID not registered with CBJ yet |
| Company billing data | Placeholder stats; real query against `transactions` table not wired |
