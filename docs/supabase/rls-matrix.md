# RLS Access Matrix

Definitive reference for which role can read/write each table. Every policy
below is enforced at the database layer; the Flutter client uses the `anon`
key exclusively, so bypasses are impossible without `service_role`.

## `users`

| Operation | Who | Condition |
|---|---|---|
| SELECT | Any authenticated | Own row (`auth.uid() = auth_id`) |
| SELECT | Driver | Basic fields of order participants (via `user_public_view`) |
| INSERT | Any authenticated | Own row only |
| UPDATE | Any authenticated | Own row only |
| DELETE | None | — |

PII protection: `phone` and `fcm_token` are excluded from `user_public_view`. Flutter code reading other users' profiles must use the view.

## `orders`

| Operation | Who | Condition |
|---|---|---|
| SELECT | Supplier | `supplier_id = me` |
| SELECT | Driver | `driver_id = me` OR (`status = pending` AND driver is available) |
| SELECT | RecyclingCo | `company_id = me` |
| INSERT | Supplier / RecyclingCo | Row's `supplier_id` or `company_id` = me |
| UPDATE | Driver | `driver_id = me` OR (pending accept via `orders_update_driver_accept`) |
| UPDATE | Supplier | Own order AND `status IN ('pending', 'accepted')` |
| DELETE | None | — |

Status transitions enforced by `trg_order_status` trigger (independent of who is calling).

## `notifications`

| Operation | Who | Condition |
|---|---|---|
| SELECT | Any authenticated | `recipient_id = me` |
| UPDATE | Any authenticated | `recipient_id = me` (used to mark read) |
| INSERT | Edge Function | service_role only |
| DELETE | None | — |

## `transactions`

| Operation | Who | Condition |
|---|---|---|
| SELECT | Driver | `driver_id = me` |
| SELECT | RecyclingCo | Linked order's `company_id = me` |
| INSERT / UPDATE | Edge Function | service_role only |
| DELETE | None | — |

## Storage buckets

### `proof-photos` (private)

- Path: `{user_id}/{order_id}/{filename}`
- INSERT: drivers only, under their own `{user_id}` prefix
- SELECT: the order's driver + supplier + company

### `user-documents` (private)

- Path: `{user_id}/{filename}`
- Full owner-only access (ALL operations)

## Testing RLS

```sql
-- Impersonate a user inside the SQL editor
SELECT set_config('request.jwt.claim.sub', 'd1111111-1111-1111-1111-111111111111', true);
SELECT set_config('request.jwt.claim.role', 'authenticated', true);
SELECT set_config('role', 'authenticated', true);

-- Then run queries and confirm only allowed rows appear:
SELECT id, status FROM orders;
```

Each policy should have at least one positive test (authorized read succeeds) and one negative test (unauthorized read returns zero rows).
