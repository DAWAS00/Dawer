-- ─────────────────────────────────────────────────────────────────────────────
-- 00010_seed_test_profiles.sql
--
-- Seeds the 4 development test accounts into auth.users + public.profiles.
-- IDs match MockAuthRepository in the Flutter app (UUID format).
--
-- ⚠️  Run with service_role access — auth.users requires elevated privileges.
-- Supabase Dashboard → SQL Editor → paste + Run.
-- Safe to run multiple times (ON CONFLICT DO NOTHING).
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. auth.users rows ────────────────────────────────────────────────────────
-- Phone-based accounts: no email, no password, phone confirmed at creation.

INSERT INTO auth.users (
  id,
  aud,
  role,
  phone,
  phone_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_sso_user,
  is_anonymous
)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'authenticated',
    'authenticated',
    '+962791234567',
    now(),
    now(),
    now(),
    '{"provider":"phone","providers":["phone"]}'::jsonb,
    '{"name":"محمد عمر خليل"}'::jsonb,
    false,
    false
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'authenticated',
    'authenticated',
    '+962792345678',
    now(),
    now(),
    now(),
    '{"provider":"phone","providers":["phone"]}'::jsonb,
    '{"name":"ليلى ناصر أبو حمد"}'::jsonb,
    false,
    false
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'authenticated',
    'authenticated',
    '+962793456789',
    now(),
    now(),
    now(),
    '{"provider":"phone","providers":["phone"]}'::jsonb,
    '{"name":"مطعم الزيتونة"}'::jsonb,
    false,
    false
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'authenticated',
    'authenticated',
    '+962794567890',
    now(),
    now(),
    now(),
    '{"provider":"phone","providers":["phone"]}'::jsonb,
    '{"name":"شركة الخضراء للتدوير"}'::jsonb,
    false,
    false
  )
ON CONFLICT (id) DO NOTHING;

-- ── 2. public.profiles rows ───────────────────────────────────────────────────

INSERT INTO public.profiles (
  auth_id,
  name,
  phone,
  role,
  supplier_type,
  address,
  is_verified,
  is_available,
  rating,
  total_orders,
  points,
  vehicle_model,
  vehicle_color,
  vehicle_plate,
  created_at
)
VALUES
  -- Driver: محمد عمر خليل
  (
    '11111111-1111-1111-1111-111111111111',
    'محمد عمر خليل',
    '+962791234567',
    'driver',
    null,
    'عمّان، حي الرابية',
    true,
    true,
    4.85,
    127,
    2540,
    'تويوتا هايلوكس',
    'أبيض',
    'أ ب ج 1234',
    now()
  ),
  -- Individual Supplier: ليلى ناصر أبو حمد
  (
    '22222222-2222-2222-2222-222222222222',
    'ليلى ناصر أبو حمد',
    '+962792345678',
    'supplier',
    'individual',
    'عمّان، الجبيهة',
    true,
    true,
    4.70,
    43,
    860,
    null,
    null,
    null,
    now()
  ),
  -- Store Supplier: مطعم الزيتونة
  (
    '33333333-3333-3333-3333-333333333333',
    'مطعم الزيتونة',
    '+962793456789',
    'supplier',
    'storeBusiness',
    'عمّان، شارع الوحدات',
    true,
    true,
    4.60,
    89,
    1780,
    null,
    null,
    null,
    now()
  ),
  -- Recycling Company: شركة الخضراء للتدوير
  (
    '44444444-4444-4444-4444-444444444444',
    'شركة الخضراء للتدوير',
    '+962794567890',
    'recyclingCo',
    null,
    'الزرقاء، المنطقة الصناعية',
    true,
    true,
    4.90,
    234,
    0,
    null,
    null,
    null,
    now()
  )
ON CONFLICT (auth_id) DO NOTHING;
