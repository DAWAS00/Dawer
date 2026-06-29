# Dwaar — Test Accounts

All accounts use **phone OTP** login.  
OTP for every number is **`123456`** (configured in Supabase Dashboard → Auth → Phone → Test OTP numbers).

---

## Driver

| Field | Value |
|-------|-------|
| **Name** | محمد عمر خليل |
| **Phone** | `+962791234567` |
| **OTP** | `123456` |
| **Role** | Driver |
| **Address** | عمّان، حي الرابية |
| **Vehicle** | تويوتا هايلوكس — أبيض — أ ب ج 1234 |
| **Rating** | 4.85 ⭐ |
| **Orders** | 127 |
| **Points** | 2,540 |
| **UUID** | `11111111-1111-1111-1111-111111111111` |

---

## Individual Supplier

| Field | Value |
|-------|-------|
| **Name** | ليلى ناصر أبو حمد |
| **Phone** | `+962792345678` |
| **OTP** | `123456` |
| **Role** | Supplier — Individual |
| **Address** | عمّان، الجبيهة |
| **Rating** | 4.70 ⭐ |
| **Orders** | 43 |
| **Points** | 860 |
| **UUID** | `22222222-2222-2222-2222-222222222222` |

---

## Store / Business Supplier

| Field | Value |
|-------|-------|
| **Name** | مطعم الزيتونة |
| **Phone** | `+962793456789` |
| **OTP** | `123456` |
| **Role** | Supplier — Store Business |
| **Address** | عمّان، شارع الوحدات |
| **Rating** | 4.60 ⭐ |
| **Orders** | 89 |
| **Points** | 1,780 |
| **UUID** | `33333333-3333-3333-3333-333333333333` |

---

## Recycling Company

| Field | Value |
|-------|-------|
| **Name** | شركة الخضراء للتدوير |
| **Phone** | `+962794567890` |
| **OTP** | `123456` |
| **Role** | Recycling Company |
| **Address** | الزرقاء، المنطقة الصناعية |
| **Rating** | 4.90 ⭐ |
| **Orders** | 234 |
| **UUID** | `44444444-4444-4444-4444-444444444444` |

---

## Supabase Setup (one-time)

If test OTP isn't configured yet, go to:

> **Supabase Dashboard → Authentication → Phone → Test OTP numbers**

Add all four numbers with OTP `123456`:

```
+962791234567  →  123456
+962792345678  →  123456
+962793456789  →  123456
+962794567890  →  123456
```

This bypasses real SMS during development.
