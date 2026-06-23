# Dwaar (دوّر) — Design System

> Arabic-first waste-recycling logistics app. Jordan market. Three roles: Driver, Supplier, Recycling Company.
> Forced portrait. Cairo font everywhere. RTL layout. Green brand.

---

## Brand

| Token | Value | Use |
|-------|-------|-----|
| Primary green | `#0F5A34` | CTAs, active states, brand |
| Primary dark | `#06331C` | High-contrast headers, pressed states |
| Accent amber | `#D97706` | Warnings, secondary actions |
| Background | `#F3F7F5` | App scaffold background |
| Surface | `#FFFFFF` | Cards, sheets, inputs |
| Border subtle | `#E2E8E5` | Card borders, dividers |
| Muted text | `#6A7973` | Labels, placeholders, hints |
| Text main | `#14241C` | Body copy, headings |

**Gradient (CTA button):** `#0A4D2A → #127B45` (linear, 135°)

---

## Typography

Font: **Google Fonts Cairo** (Arabic). Numeric fields and amounts use **DM Sans** (LTR-forced inside RTL context).

| Role | Size | Weight | Token |
|------|------|--------|-------|
| Screen title | 22 sp | Bold (700) | `titleLarge` |
| Section header | 16 sp | Bold (700) | — |
| Body | 14 sp | Regular (400) | `bodyMedium` |
| Label / hint | 13 sp | SemiBold (600) | `labelLarge` |
| Caption | 11–12 sp | SemiBold (600) | `labelSmall` |
| Button | 16–17 sp | Bold (700) | — |
| Numeric display | DM Sans 16 sp | Bold | LTR context |

---

## Signup Flow — Screen Map

```
[1] SignupPhoneScreen     Phone entry + country code
       ↓ OTP sent
[2] VerificationView      6-digit OTP input
       ↓ verified (new user)
[3] SignupIdentityScreen  Profile photo + full name + role selection
       ↓ profiles row created
[4] SignupRoleDetailsScreen  Role-specific details (vehicle / categories / address)
       ↓ (skippable)
    HomeRouter
```

---

## Signup Component Specs

### Screen Shell

```
backgroundColor: Colors.white   (signup screens)
AppBar: transparent, no elevation
AppBar back icon: Icons.arrow_forward_ios_rounded  (RTL convention)
AppBar foreground: #191C1B
Body padding: EdgeInsets.all(24)
ScrollView: SingleChildScrollView
```

### Progress Indicator (Screens 3–4)

Three-dot step indicator. Filled = primaryGreen, inactive = #E2E8E5.

```dart
// Dot size: 8×8, spacing: 8, active dot: 12×12 (scale up)
// Show above screen title on Screens 3–4
```

### Input Fields

```dart
InputDecorationTheme(
  filled: true,
  fillColor: Color(0xFFE6E9E7),          // Gray-green tint
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: primaryGreen, width: 2),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  hintStyle: Cairo, 13sp, mutedText,
)
// Minimum height: 56 dp
// Error text: Cairo 13sp, red.shade700
```

### Phone Input (LTR-forced, all screens)

```dart
Directionality(textDirection: TextDirection.ltr, child: Row([
  // Country prefix pill
  Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: BoxDecoration(color: #E6E9E7, borderRadius: BorderRadius.circular(12)),
    child: Text('🇯🇴 +962', style: DM Sans 16sp Bold),
  ),
  SizedBox(width: 8),
  // 9-digit input (after stripping leading 0)
  Expanded(TextField(keyboardType: phone, maxLength: 9, style: DM Sans 16sp))
]))
// Helper text below: 'سنتحقق من رقمك عبر رسالة نصية', Cairo 12sp, mutedText
```

### OTP Input

6 separate boxes OR a single 6-char field. Current implementation: single field.

```
fontSize: 24sp, DM Sans Bold, textAlign: center, LTR-forced
Border: 2dp primaryGreen when focused
Box size: 48×56 dp minimum
```

### Primary CTA Button (GreenButton)

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,     // #0F5A34
    foregroundColor: Colors.white,
    elevation: 0,
    minimumSize: Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),
  // Loading state: CircularProgressIndicator(color: white, strokeWidth: 2.5), 20×20
  child: Text(label, style: Cairo 16sp Bold),
)
```

### Role Selection Cards (Screen 3)

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: selected ? Color(0xFFD1FAE5) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: selected ? primaryGreen : borderSubtle,
      width: selected ? 2 : 1,
    ),
  ),
  // Icon container: 48×48, color primaryGreen/10, circle
  // Title: Cairo 15sp Bold, textMain
  // Subtitle: Cairo 12sp, mutedText
)
// Min height: 80 dp. Tap anywhere selects.
```

### Photo Picker Card (Screen 3)

```dart
// Circle avatar, 96 dp diameter
// Empty state: Icon(Icons.add_a_photo_rounded), mutedText, 32sp
// Filled state: CircleAvatar with selected image
// Overlay on filled: small edit icon, bottom-right
// Tap anywhere to trigger image picker (camera + gallery sheet)
```

### Error Banner

```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.red.shade300),
  ),
  child: Text(error, style: Cairo 13sp Bold, color: red.shade700, textAlign: center),
)
// Always above the CTA button, never inline in the input
```

### Helper / Caption Text

```dart
Text(hint, style: Cairo 12sp, color: mutedText)
// 8 dp below the field it annotates
```

---

## Supabase: profiles table

The canonical user table. Keyed by `auth.users.id` (FK = `auth_id`).

```sql
public.profiles (
  auth_id           UUID PK → auth.users(id)  -- canonical user id
  name              TEXT NOT NULL
  phone             TEXT UNIQUE NOT NULL        -- +962XXXXXXXXX format
  email             TEXT
  role              user_role                   -- 'driver' | 'supplier' | 'recyclingCo'
  supplier_type     supplier_type               -- 'individual' | 'storeBusiness' (suppliers only)
  rating            NUMERIC(3,2) DEFAULT 5.00
  total_orders      INTEGER DEFAULT 0
  is_verified       BOOLEAN DEFAULT false
  is_available      BOOLEAN DEFAULT true
  points            INTEGER DEFAULT 0
  location          GEOGRAPHY(POINT, 4326)
  vehicle_model     TEXT                        -- drivers only
  vehicle_color     TEXT
  vehicle_plate     TEXT
  vehicle_photo_url TEXT
  address           TEXT
  fcm_token         TEXT
  profile_photo_url TEXT
  identity_doc_path TEXT
  categories        TEXT[] DEFAULT '{}'
  created_at        TIMESTAMPTZ DEFAULT now()
)
```

**Migration file:** `supabase/migrations/00001_initial_schema.sql`

**Seed file:** `supabase/migrations/00010_seed_test_profiles.sql` — 4 test accounts (service role required)

---

## Test Accounts (Mock Auth)

| Phone | OTP | Name | Role | UUID |
|-------|-----|------|------|------|
| `0791234567` | `123456` | محمد عمر خليل | Driver | `11111111-...1` |
| `0792345678` | `123456` | ليلى ناصر أبو حمد | Supplier – Individual | `22222222-...2` |
| `0793456789` | `123456` | مطعم الزيتونة | Supplier – Store | `33333333-...3` |
| `0794567890` | `123456` | شركة الخضراء للتدوير | Recycling Co | `44444444-...4` |

Quick login available via DEV panel on login screen.

---

## Spacing Scale

| Token | Value | Use |
|-------|-------|-----|
| xs | 4 dp | Icon gaps, tight labels |
| sm | 8 dp | Field-to-hint, icon-to-text |
| md | 16 dp | Section padding, card inner |
| lg | 24 dp | Screen horizontal padding |
| xl | 32 dp | Between form sections |
| 2xl | 40–48 dp | Screen top breathing room |

---

## Border Radius

| Context | Radius |
|---------|--------|
| Input field | 12 dp |
| Button | 14 dp |
| Card / sheet | 16 dp |
| Bottom sheet | 20 dp (top corners only) |
| Chip / pill | 100 dp (fully rounded) |
| Avatar | circle |

---

## Iconography

Library: **Lucide Icons** (`lucide_icons_flutter`) + Material Icons fallback.

- Navigation icons: Lucide
- Status icons: Material (`Icons.*_rounded` variants)
- Role icons in cards: Material
- Always use `_rounded` suffix on Material icons where available

---

## RTL Rules

1. All text is RTL (Arabic). Exception: phone numbers, numeric amounts, OTP codes → `TextDirection.ltr` wrapper.
2. `textAlign: TextAlign.right` is the default for Arabic strings.
3. Back arrow in AppBar uses `Icons.arrow_forward_ios_rounded` (points right = back in RTL).
4. Horizontal padding is symmetric — no directional padding.
5. Row children follow Arabic reading order (right to left on screen).
