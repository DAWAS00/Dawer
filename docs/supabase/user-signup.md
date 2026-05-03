# User Sign-Up Flow

End-to-end creation of a `public.users` row bound to a Supabase Auth account,
with client-side validation that mirrors the DB check constraints.

## Roles

Defined in `supabase/migrations/20260422000002_enums.sql` and typed in
`lib/data/models/user_role.dart`:

| `UserRole` | DB label | Extra required fields |
|---|---|---|
| `driver` | `driver` | `vehicle_plate` (check `chk_driver_fields`) |
| `supplier` | `supplier` | `supplier_type` ∈ `individual \| storeBusiness` (check `chk_supplier_type`) |
| `recyclingCo` | `recyclingCo` | none |

## Data flow

```
Flutter UI
   ↓ SignUpRequest (DTO)
UserSignUpService.signUp(request)
   ├─ 1. request.validate()                  ← pure, no network
   ├─ 2. supabase.auth.signUp(...)           ← creates auth.users row
   └─ 3. supabase.from('users').insert(...)  ← RLS: auth.uid() = auth_id
         └─ on failure → auth.signOut() rollback
```

## API surface

`lib/data/services/user_signup_service.dart`:

- **`SignUpRequest`** — immutable DTO. `validate()` returns
  `Map<String, String>` keyed by field; empty map == valid.
- **`UserSignUpService.signUp(request)`** — `Future<Map<String, dynamic>>`
  returning the inserted `public.users` row. Throws `SignUpException`
  on validation, auth, or DB errors.
- **`SignUpException`** — `message`, `fieldErrors`, `cause`, plus
  `isValidation` helper.

## Validation rules

| Field | Rule |
|---|---|
| `name` | 2–120 chars after trim |
| `phone` | `^\+?\d{9,15}$` — E.164 or local digits |
| `email` *(optional)* | RFC-style regex if provided |
| `password` | 8–72 chars (bcrypt limit) |
| `supplierType` | required iff `role == supplier`; forbidden otherwise |
| `vehiclePlate` | required iff `role == driver` |

These mirror `chk_supplier_type` and `chk_driver_fields` in
`supabase/migrations/20260422000003_tables.sql` so a request passing
`validate()` should also pass the DB (barring uniqueness on `phone` / `email`).

## Error mapping

Postgres errors surfaced via `PostgrestException` are translated in
`UserSignUpService._friendlyDbMessage`:

| SQLSTATE | Meaning | User-facing (AR) |
|---|---|---|
| `23505` | unique violation on `phone` / `email` / `auth_id` | «رقم الهاتف مُسجّل مسبقاً» etc. |
| `23514` | check constraint failed | role-specific message |
| `42501` | RLS denied insert (likely pending email confirmation) | «لا يُسمح بإنشاء الحساب قبل تأكيد البريد الإلكتروني» |

## Usage

```dart
final service = UserSignUpService();

final request = SignUpRequest(
  name: 'أحمد المحمد',
  phone: '+962791234567',
  password: 'Sup3rSafe!',
  role: UserRole.driver,
  vehiclePlate: '12-34567',
);

try {
  final row = await service.signUp(request);
  // row['id'], row['role'], etc.
} on SignUpException catch (e) {
  if (e.isValidation) {
    // surface e.fieldErrors[field] next to inputs
  } else {
    // surface e.message as a snackbar
  }
}
```

## Rollback semantics

If the `public.users` insert fails after `auth.signUp` succeeded, the service
calls `auth.signOut()` to avoid leaving the session authenticated with a
missing profile. The orphan `auth.users` row is **not** deletable from the
client — a nightly cleanup job should sweep `auth.users` rows without a
`public.users` counterpart older than ~1h.

## Tests

- `test/data/user_role_test.dart` — enum ↔ DB label mapping (6 tests)
- `test/data/user_signup_request_test.dart` — validation + `toInsertRow` (22 tests)

Integration tests against a live Supabase dev project are out of scope here;
add them under `test/integration/` once a dev project ref is configured.

## Schema notes

No migration was needed for this feature — the schema already covers it
via `user_role` / `supplier_type` enums, `auth_id` FK, RLS policy
`users_insert_own`, and the two check constraints listed above.
