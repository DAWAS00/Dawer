# Dev Accounts — Dawer (دوّر)

Default accounts for all three user roles. Use these to sign in without going
through the registration flow. All accounts are pre-verified (`is_verified = true`).

---

## Credentials

| Role | Name (AR) | Email | Phone | Password |
|---|---|---|---|---|
| Driver (`driver`) | أحمد الراشد | `driver@dawer.dev` | `+962791000001` | `Dawer@1234` |
| Supplier — Individual (`supplier / individual`) | سارة حسن | `supplier.individual@dawer.dev` | `+962791000002` | `Dawer@1234` |
| Supplier — Business (`supplier / storeBusiness`) | سوق الأردن الطازج | `supplier.business@dawer.dev` | `+962791000003` | `Dawer@1234` |
| Recycling Co (`recyclingCo`) | شركة عمان للتدوير | `recycling@dawer.dev` | `+962791000004` | `Dawer@1234` |

---

## How to sign in (app)

The app login screen asks for a **phone number**. On submit the app calls the
`get_email_by_phone` RPC to resolve the email, then calls
`signInWithPassword(email, password)`.

1. Open the app.
2. Enter the phone number from the table above (e.g. `+962791000001`).
3. Enter password `Dawer@1234`.
4. Tap **تسجيل الدخول**. You land on the home screen for that role.

> OTP is **not** triggered for password-based login. These accounts bypass the
> email-confirmation flow because the seed sets `email_confirmed_at` directly.

---

## How to create the accounts (first-time setup)

### Option A — SQL Editor (recommended)

1. Open [Supabase Dashboard](https://supabase.com/dashboard) → project
   `qexwkjwqnbowsrrthxva`.
2. Go to **SQL Editor**.
3. Paste and run the contents of `supabase/seed.sql`.
4. Verify: **Authentication → Users** should show 4 new rows.
5. Verify: **Table Editor → users** should show 4 matching rows with correct roles.

The script is **idempotent** — running it twice is safe (`ON CONFLICT DO NOTHING`).

### Option B — Supabase CLI

```bash
supabase db reset   # applies all migrations + seed.sql
```

Or seed only (without resetting):

```bash
supabase db push
psql "$DATABASE_URL" -f supabase/seed.sql
```

### Option C — Dashboard (manual, no SQL)

1. **Authentication → Users → Add user** (for each account):
   - Email: as in the table above.
   - Password: `Dawer@1234`.
   - Check **Auto Confirm User**.
2. Copy the generated `uid` from the Users list.
3. **Table Editor → users → Insert row** (for each account):

   | Column | Driver | Supplier (Ind.) | Supplier (Biz.) | Recycling Co |
   |---|---|---|---|---|
   | `auth_id` | _(uid from step 2)_ | _(uid)_ | _(uid)_ | _(uid)_ |
   | `name` | أحمد الراشد | سارة حسن | سوق الأردن الطازج | شركة عمان للتدوير |
   | `phone` | +962791000001 | +962791000002 | +962791000003 | +962791000004 |
   | `email` | driver@dawer.dev | supplier.individual@dawer.dev | supplier.business@dawer.dev | recycling@dawer.dev |
   | `role` | driver | supplier | supplier | recyclingCo |
   | `supplier_type` | _(leave empty)_ | individual | storeBusiness | _(leave empty)_ |
   | `vehicle_plate` | 12-D-1001 | _(empty)_ | _(empty)_ | _(empty)_ |
   | `is_verified` | true | true | true | true |

---

## Supabase IDs (fixed UUIDs from seed)

| Role | `auth.users.id` / `public.users.auth_id` |
|---|---|
| Driver | `a0000000-0000-0000-0000-000000000001` |
| Supplier (Individual) | `a0000000-0000-0000-0000-000000000002` |
| Supplier (Business) | `a0000000-0000-0000-0000-000000000003` |
| Recycling Co | `a0000000-0000-0000-0000-000000000004` |

Fixed UUIDs make it easy to hard-code them in integration tests or reference
data without querying first.

---

## Resetting a password

From the SQL Editor (service-role context):

```sql
UPDATE auth.users
SET encrypted_password = crypt('NewPass@1234', gen_salt('bf', 10))
WHERE email = 'driver@dawer.dev';
```

---

## Removing the seed accounts

```sql
DELETE FROM auth.users
WHERE id IN (
  'a0000000-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000002',
  'a0000000-0000-0000-0000-000000000003',
  'a0000000-0000-0000-0000-000000000004'
);
-- Cascades to public.users via ON DELETE CASCADE on auth_id FK.
```
