---
name: user-roles
description: Three user roles (Driver, Supplier, Recycling Company), SupplierType variants, mock test accounts, and HomeRouter dispatch logic
metadata:
  type: concept
---

# User Roles

Source: `lib/data/models/user_role.dart`, `lib/ui/features/home/home_router.dart`

## Three Roles (`UserRole`)

| Role | DB Value | Home Shell | Description |
|---|---|---|---|
| `driver` | `"driver"` | `DriverHomeView` | Accepts pickup orders, earns delivery fees |
| `supplier` | `"supplier"` | `IndividualSupplierHomeView` or `RestaurantHomeView` | Posts waste for collection |
| `recyclingCo` | `"recycling_co"` | `RecyclingHomeView` | Posts collection jobs, receives waste |

## Supplier Sub-Types (`SupplierType`)

| Type | DB Value | Home Shell |
|---|---|---|
| `individual` | `"individual"` | `IndividualSupplierHomeView` |
| `storeBusiness` | `"store_business"` | `RestaurantHomeView` |

`RestaurantHomeView` serves store/business suppliers (restaurants, shops). Despite the name it handles all `storeBusiness` types.

**Note:** `lib/ui/features/home/restaurant/` exists with a separate `RestaurantHomeView` that is NOT wired into `HomeRouter` for the `restaurant` role — the `UserRole` enum has no `restaurant` value. This path is only reached via `SupplierType.storeBusiness`.

## HomeRouter Dispatch

```dart
switch (role) {
  driver       → DriverHomeView
  supplier     → switch(supplierType) {
    individual    → IndividualSupplierHomeView
    storeBusiness → RestaurantHomeView
  }
  recyclingCo  → RecyclingHomeView
}
```

`HomeRouter` also calls `AppOrderStore.configureForUser(userId, role)` once mounted to set the role-scoped Supabase stream filter.

## Mock Test Accounts (MockAuthRepository)

| Phone | Role | Name |
|---|---|---|
| `+962790000001` | Driver | أحمد السائق |
| `+962790000002` | Supplier (individual) | خالد المورد |
| `+962790000003` | Supplier (storeBusiness) | مطعم أبو علي |
| `+962790000004` | Recycling Co | شركة تدويركم |

OTP validation is currently **disabled** — any OTP code works. The selected role on the login screen always overrides the mock account's stored role.

## User Model (`lib/data/models/user.dart`)

```dart
class User {
  final String id, name, role, phone;
  final double rating;
  final String? vehicleModel, vehicleColor, licensePlate, vehiclePhotoPath, address;
  final int points, totalOrders;
  final bool isVerified, hasChemicalPermit;
  final List<String> categories;
  final VehicleType? vehicleType;
}
```

## Related Pages

- [[concepts/app-architecture]]
- [[patterns/mock-to-real-swap]]
- [[patterns/auth-flow]]
