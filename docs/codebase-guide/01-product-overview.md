# 1. Product Overview

## What is Dwaar?

**Dwaar (دوّر)** is an Arabic-first, Flutter-based mobile marketplace for recycling logistics in Jordan. It digitizes the circular economy by connecting three parties around recyclable waste:

1. **Suppliers** — households, small shops, restaurants, and businesses that list sorted recyclable waste they want to sell or dispose of responsibly.
2. **Drivers** — gig-economy transporters who accept pickup and delivery jobs.
3. **Recycling Companies** — buyers that post collection jobs and purchase marketplace listings.

## Core value propositions

- **For suppliers:** turn sorted waste into money or reward points instead of throwing it away.
- **For drivers:** earn per-trip income by moving materials from suppliers to recyclers.
- **For recycling companies:** receive a steady, categorized stream of raw recyclable material.
- **For the ecosystem:** reduce landfill waste, improve sorting rates, and create traceable recycling flows.

## User roles

The app has one primary enum and one sub-type enum:

```dart
// lib/data/models/user_role.dart
enum UserRole { driver, supplier, recyclingCo }
enum SupplierType { individual, storeBusiness }
```

In the database these are mapped to PostgreSQL enums `user_role` and `supplier_type`.

### Driver

- Views a feed of available pickup/collection orders filtered by vehicle capacity and chemical-permit status.
- Accepts one active order at a time.
- Publishes live GPS while an order is in transit.
- Must pass a 200 m server-verified geofence to mark arrival.
- Earns a payout per trip, held in escrow until completion.

### Supplier

Three real-world personas share the `supplier` role:

- **Individual** — a household or person selling small quantities.
- **Store / Business** — a shop or restaurant with recurring, larger waste output.
- **Restaurant** — special onboarding flow but same underlying role.

Supplier actions:
- Create pickup requests (waste type, weight, location, photos).
- Choose the pickup target: send to a recycling company or sell to a driver in the marketplace.
- Cancel pending orders.
- Track the driver on a live map.
- Earn points on completed orders.

### Recycling Company

- Posts **collection jobs** describing desired waste types, quantities, payment model, and area.
- Views incoming shipments from accepted pickups.
- Accepts **collection sale** commitments from drivers or suppliers who want to sell material to the company.
- Manages admin approval for chemical-laden orders.

## Order modes

The app supports two high-level modes that reuse the same `Order` model:

```dart
// lib/data/models/order/order_enums.dart
enum OrderType { pickup, collection, collectionSale }
```

| Type | Created by | Purpose |
|---|---|---|
| `pickup` | Supplier | "Come collect my waste." |
| `collection` | Recycling company | "I want to buy X material in Y area." |
| `collectionSale` | Driver / supplier | "I will bring X material to your facility." |

A fourth concept, the **marketplace**, is implemented by setting `isMarketplaceShared = true` on a `pickup` order so other parties can buy it.

## Key user flows

### Supplier creates a pickup request

1. Supplier selects waste types, form, and weight category.
2. Optionally takes photos for AI classification.
3. Chooses pickup target: recycling company or marketplace/driver-buy.
4. System estimates a reward/delivery fee via `RewardService`.
5. Order enters `pending` status and is visible to matching drivers.

### Driver accepts and fulfills an order

1. Driver browses feed filtered by vehicle type and capacity.
2. Driver accepts an order; wallet hold is placed for the expected payout.
3. Driver location publisher starts; supplier sees live map.
4. Driver reaches pickup geofence; `verify_arrival` Edge Function confirms.
5. Supplier confirms availability; order moves to `inTransit`.
6. Driver reaches dropoff geofence; marks arrived; completes delivery.
7. Wallet release fires; transaction row is recorded; supplier earns points.

### Recycling company posts a collection job

1. Company creates a `collection` order with waste type, quantity, payment model.
2. Drivers or suppliers browse the job and create a linked `collectionSale` commitment.
3. Committing party delivers the material (self-delivery or assigned rider).
4. Order moves through `accepted → inTransit → completed`.

## Localization and UX

- **Language:** Arabic-first. English is supported but Arabic is the template language.
- **Direction:** RTL layouts by default.
- **Fonts:** `Cairo` for Arabic, `DM Sans` for Latin/numbers.
- **Colors:** Primary green palette (`#1E5C35`, `#14401F`, `#06402B`).
- **Files:** `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`.

## Tech stack summary

| Layer | Technology |
|---|---|
| Mobile framework | Flutter 3.8 |
| State management | Provider + ChangeNotifier |
| Backend | Supabase (Postgres, Auth, Realtime, Storage, Edge Functions) |
| Push notifications | Firebase Cloud Messaging (FCM) |
| Maps | `google_maps_flutter` |
| Location | `geolocator` + foreground service |
| AI | `google_generative_ai` (Gemini 1.5 Flash) + `google_mlkit_image_labeling` |
| Local persistence | `SharedPreferences` via `LocalStore` |
| Code generation | Freezed + json_serializable |

## Files referenced

- `lib/main.dart` — app bootstrap, dependency graph, localization, theming
- `lib/data/models/user_role.dart` — role and supplier type enums
- `lib/data/models/order/order_enums.dart` — order type/status enums and Arabic labels
- `lib/l10n/` — ARB localization files
- `lib/core/theme/app_theme.dart` — color tokens and typography
