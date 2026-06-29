# Localization Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate every hardcoded user-visible Arabic/English string in `lib/ui/` by extracting them to the ARB localization files (`app_ar.arb` source + `app_en.arb` mirror), so the app fully localizes when the user switches locale — with no behavior change to existing screens.

**Architecture:** The app already has a working ARB pipeline (`l10n.yaml`, `context.l10n.<key>`, `flutter gen-l10n`, ~717 keys in sync). This plan only *fills the gaps* — it does not build new infrastructure. Work proceeds feature-by-feature (auth → home tabs → shared → chat UI → earnings → misc), each task self-contained and independently committable. A final parity test + ARB sort locks the result in.

**Tech Stack:** Flutter 3.x, `flutter_localizations`, ARB files, `flutter gen-l10n`, `flutter_test`, `Provider`.

**Conventions (from `dwaar-build` skill — non-negotiable):**
- Arabic (`app_ar.arb`) is the template; English (`app_en.arb`) mirrors. Every new key is added to **both** in the same edit.
- Key naming: `camelCase`, feature-prefixed where a screen has many keys (e.g. `recyclingWithdrawAdConfirm`). Reuse existing keys when the meaning matches (check `app_ar.arb` first).
- Access via `context.l10n.<key>` (the extension in `lib/l10n/l10n.dart`).
- Numbers in interpolated strings use ARB placeholders, not string concat.
- No hardcoded English either — `Text('...')` with an English literal is the same bug.

**Scope decisions (IMPORTANT — read before starting):**

| Category | Treatment | Why |
| --- | --- | --- |
| Strings in `build()` / `Text()` / `title:` / `label:` / `hintText:` / `content:` etc. | **In scope — localize** | User-visible |
| `lib/ui/features/chatbot/dawa_chatbot_service.dart` (528 Arabic hits) | **OUT of scope — do NOT edit** | This is the keyword knowledge-base *data* + Arabic stop-word list + normalization rules. It is content, not UI. The chatbot is also now backed by Gemini (`gemini_chat_service.dart`); this file is the legacy fallback. Localizing its data would break the keyword-matching algorithm. |
| `lib/ui/features/chatbot/gemini_chat_service.dart` (16 Arabic hits) | **OUT of scope** | This is the LLM `systemPrompt` — an Arabic instruction to Gemini. It must stay Arabic; it is not user-facing UI. |
| `lib/ui/features/chatbot/dawa_chat_view_model.dart` demo scan content (`'زيت مستعمل'`, `'خشب بناء'`, response templates) | **OUT of scope** | Demo/sample content for the bundled asset scans, not translatable UI. |
| `lib/ui/features/auth/views/login_view.dart` dev-panel labels (`'Driver — محمد…'`) | **OUT of scope** | Test-account list shown only in the dev testing panel; behind debug gating. Not production UI. |
| Arabic in code comments (`//`, `///`, doc strings) | **OUT of scope** | Comments are not user-visible. |

If during execution you find an Arabic string that doesn't clearly fit "user-visible UI in build()", default to leaving it and noting it in the final report rather than blindly extracting.

---

## File Structure

**ARB files (the source of truth — edited in every task):**
- `lib/l10n/app_ar.arb` — Arabic template (add keys here first).
- `lib/l10n/app_en.arb` — English mirror (same keys, English values).
- `lib/l10n/generated/*` — regenerated, never hand-edited.

**A shared widget (DRY consolidation, Task 1):**
- `lib/ui/features/auth/views/widgets/photo_source_picker.dart` — **Create.** Replaces the duplicated camera/gallery source-picker in 3 files. One widget, fed localized labels by its caller.

**A parity safety net (Task 9):**
- `test/l10n/arb_parity_test.dart` — **Create.** Asserts every key in `app_ar.arb` exists in `app_en.arb` and vice versa, and that no key is empty. Prevents future drift.

**Touched feature files (in dependency order):**
- Auth widgets: `license_scan_section.dart`, `vehicle_registration_scan_section.dart`, `photo_picker_card.dart`, `signup_role_details_screen.dart`, `signup_identity_screen.dart`, `signup_phone_screen.dart`
- Home tabs: `recycling_home_tab.dart`, `recycling_orders_tab.dart`, `individual_supplier_home_tab.dart`, `restaurant_home_tab.dart`, `driver_home_tab.dart`, `driver_profile_tab.dart`, `recycling_profile_tab.dart`, `supplier_profile_tab.dart`
- Shared: `order_arrival_section.dart`, `order_tracking_card.dart`, `collection_sale_detail_view.dart`, `accept_collection_job_sheet.dart`, `market_item_delivery_address_sheet.dart`, `market_item_purchase_choice_sheet.dart`, `payment_wallet_card.dart`, `dev_testing_panel.dart`
- Supplier wizard: `step_1_material_photo.dart`, `step_2_quantity_price.dart`, `step_3_location_review.dart`, `new_pickup_request_view.dart`
- Driver: `driver_active_order_card.dart`, `pickup_proof_view.dart`, `driver_earnings_*` (header/fee_row/best_day_card), `driver_home_viewmodel.dart`
- Recycling: `post_job_form.dart`, `recycling_home_view.dart`
- Chat UI (NOT the service): `chat_view.dart`
- Earnings: `earnings_dashboard_view.dart`
- Supplier cards: `supplier_order_card.dart`

Each task is self-contained: it can be committed on its own and the app stays in a working, localized state.

---

## Task 1: DRY — extract the camera/gallery source picker

**Files:**
- Create: `lib/ui/features/auth/views/widgets/photo_source_picker.dart`
- Modify: `lib/ui/features/auth/views/widgets/license_scan_section.dart`
- Modify: `lib/ui/features/auth/views/widgets/vehicle_registration_scan_section.dart`
- Modify: `lib/ui/features/auth/views/widgets/photo_picker_card.dart`
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

Three files currently each hand-write the same "Camera / Gallery" source sheet with the hardcoded literals `'الكاميرا'` and `'معرض الصور'`. Extract one shared widget that takes already-localized labels from the caller, then have all three use it.

- [ ] **Step 1: Add the two keys to both ARB files**

In `lib/l10n/app_ar.arb` (add near the existing `cancel`/`confirm` block):
```jsonc
  "photoSourceCamera": "الكاميرا",
  "@photoSourceCamera": { "description": "Camera option in the photo source picker" },
  "photoSourceGallery": "معرض الصور",
  "@photoSourceGallery": { "description": "Gallery option in the photo source picker" },
```
In `lib/l10n/app_en.arb` (same keys):
```jsonc
  "photoSourceCamera": "Camera",
  "photoSourceGallery": "Gallery",
```

- [ ] **Step 2: Regenerate**

Run: `flutter gen-l10n`
Expected: no warnings; `lib/l10n/generated/app_localizations*.dart` updated.

- [ ] **Step 3: Create the shared widget**

`lib/ui/features/auth/views/widgets/photo_source_picker.dart`:
```dart
import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

/// Shows a bottom sheet to pick an [ImageSource] for photo capture/import.
/// Labels are localized by the caller via [cameraLabel] / [galleryLabel].
Future<T?> showPhotoSourcePicker<T>({
  required BuildContext context,
  required String cameraLabel,
  required String galleryLabel,
  required T cameraValue,
  required T galleryValue,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(cameraLabel),
            onTap: () => Navigator.pop(sheet, cameraValue),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(galleryLabel),
            onTap: () => Navigator.pop(sheet, galleryValue),
          ),
        ],
      ),
    ),
  );
}
```
(Adjust the import for `ImageSource` per what the three callers actually pass — if they all pass `ImageSource`, type `T` as `ImageSource` directly and drop the generic. Read each caller first and match the real signature.)

- [ ] **Step 4: Refactor `license_scan_section.dart`**

Replace its inline source sheet with a call to `showPhotoSourcePicker`, passing `context.l10n.photoSourceCamera` / `context.l10n.photoSourceGallery`. Delete the now-unused local literals `'الكاميرا'`, `'معرض الصور'`.

- [ ] **Step 5: Refactor `vehicle_registration_scan_section.dart`** — same change as Step 4.

- [ ] **Step 6: Refactor `photo_picker_card.dart`** — same change as Step 4.

- [ ] **Step 7: Verify**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter gen-l10n` (confirm stable).

- [ ] **Step 8: Commit**

```bash
git add lib/ui/features/auth/views/widgets/photo_source_picker.dart \
        lib/ui/features/auth/views/widgets/license_scan_section.dart \
        lib/ui/features/auth/views/widgets/vehicle_registration_scan_section.dart \
        lib/ui/features/auth/views/widgets/photo_picker_card.dart \
        lib/l10n/app_ar.arb lib/l10n/app_en.arb lib/l10n/generated/
git commit -m "refactor(l10n): extract shared photo source picker, localize camera/gallery"
```

---

## Task 2: Localize the auth signup flow

**Files:**
- Modify: `lib/ui/features/auth/views/signup_role_details_screen.dart` (24 strings)
- Modify: `lib/ui/features/auth/views/signup_identity_screen.dart` (13 strings)
- Modify: `lib/ui/features/auth/views/signup_phone_screen.dart`
- Modify: `lib/ui/features/auth/views/login_view.dart` — **only the production strings** (password field, etc.), NOT the dev-panel test-account labels.
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

- [ ] **Step 1: Inventory the strings**

For each file, run `grep -nP "[\x{0600}-\x{06FF}]" <file>` and collect every literal that appears in a `Text`, `title`, `label`, `hintText`, `helperText`, `content`, or `tooltip` argument. Skip anything inside the dev testing panel of `login_view.dart`.

- [ ] **Step 2: Add ARB keys (ar + en) for the inventory**

Group keys with an `auth` prefix: `authRoleTitle`, `authIdentityHint`, `authPhoneInvalid`, etc. Add to **both** ARB files in one edit. For interpolated values use placeholders:
```jsonc
// app_ar.arb
"authPhoneHint": "ادخل رقم هاتفك",
"@authPhoneHint": { "description": "Signup phone field hint" },
"authOtpSentTo": "تم إرسال رمز التحقق إلى {phone}",
"@authOtpSentTo": { "placeholders": { "phone": { "type": "String" } } },
```
```jsonc
// app_en.arb
"authPhoneHint": "Enter your phone number",
"authOtpSentTo": "Verification code sent to {phone}",
```

- [ ] **Step 3: Regenerate** — Run: `flutter gen-l10n`. Expected: no warnings.

- [ ] **Step 4: Replace literals in the four files**

Swap each `'...'` literal with `context.l10n.<key>`. Where the string is inside a widget that lacks a `BuildContext`, thread `context` through (or move the string resolution up to the `build()` caller that has context — match the existing pattern in the file). Use `context.l10n.authOtpSentTo(phone)` for placeholders.

- [ ] **Step 5: Verify** — `flutter analyze` → `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/auth/views/signup_role_details_screen.dart \
        lib/ui/features/auth/views/signup_identity_screen.dart \
        lib/ui/features/auth/views/signup_phone_screen.dart \
        lib/ui/features/auth/views/login_view.dart \
        lib/l10n/app_ar.arb lib/l10n/app_en.arb lib/l10n/generated/
git commit -m "feat(l10n): localize auth signup + login production strings"
```

---

## Task 3: Localize the recycling company home + orders tabs

**Files:**
- Modify: `lib/ui/features/home/recycling/tabs/recycling_home_tab.dart` (22 strings — incl. `title:`, `content:`, tab labels, the withdraw-ad confirm dialog)
- Modify: `lib/ui/features/home/recycling/tabs/recycling_orders_tab.dart` (23 strings)
- Modify: `lib/ui/features/home/recycling/widgets/post_job_form.dart` (13 strings)
- Modify: `lib/ui/features/home/recycling/recycling_home_view.dart` (6 strings)
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

- [ ] **Step 1: Inventory strings** per file with the Arabic grep.

- [ ] **Step 2: Add keys with `recycling` prefix** to both ARB files. Note `recycling_home_tab.dart:84` builds a label with an embedded count — use a placeholder:
```jsonc
// app_ar.arb
"recyclingIncomingShipments": "الشحنات الواردة ({count})",
"@recyclingIncomingShipments": { "placeholders": { "count": { "type": "int" } } },
"recyclingActiveJobs": "الوظائف النشطة ({count})",
"@recyclingActiveJobs": { "placeholders": { "count": { "type": "int" } } },
```
```jsonc
// app_en.arb
"recyclingIncomingShipments": "Incoming shipments ({count})",
"recyclingActiveJobs": "Active jobs ({count})",
```
The withdraw-ad confirm dialog needs four keys: `recyclingWithdrawAdTitle`, `recyclingWithdrawAdBody`, `recyclingWithdrawAdCancel`, `recyclingWithdrawAdConfirm`.

- [ ] **Step 3: Regenerate** — `flutter gen-l10n`.

- [ ] **Step 4: Replace literals** in all four files with `context.l10n.<key>`; use `context.l10n.recyclingIncomingShipments(list.length)` for the count case.

- [ ] **Step 5: Verify** — `flutter analyze` clean.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/home/recycling/ lib/l10n/
git commit -m "feat(l10n): localize recycling home, orders tab, post-job form"
```

---

## Task 4: Localize supplier + restaurant + driver home tabs and profile tabs

**Files:**
- Modify: `lib/ui/features/home/supplier/tabs/individual_supplier_home_tab.dart` (11)
- Modify: `lib/ui/features/home/supplier/widgets/supplier_order_card.dart` (8)
- Modify: `lib/ui/features/home/restaurant/tabs/restaurant_home_tab.dart` (11)
- Modify: `lib/ui/features/home/driver/tabs/driver_home_tab.dart` (11)
- Modify: `lib/ui/features/home/driver/tabs/driver_profile_tab.dart` (6)
- Modify: `lib/ui/features/home/recycling/tabs/recycling_profile_tab.dart`
- Modify: `lib/ui/features/home/supplier/tabs/supplier_profile_tab.dart`
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

- [ ] **Step 1: Inventory** per file.

- [ ] **Step 2: Add keys** with role prefixes (`supplier`, `restaurant`, `driver`, `profile`). Many profile labels are shared across roles (e.g. "Logout", "Settings") — **reuse existing keys** (`logout`, `settings`, etc.) rather than creating role-specific duplicates. Check `app_ar.arb` before adding a new key.

- [ ] **Step 3: Regenerate** — `flutter gen-l10n`.

- [ ] **Step 4: Replace literals** in all seven files.

- [ ] **Step 5: Verify** — `flutter analyze` clean.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/home/supplier/ lib/ui/features/home/restaurant/ \
        lib/ui/features/home/driver/ lib/ui/features/home/recycling/tabs/recycling_profile_tab.dart \
        lib/l10n/
git commit -m "feat(l10n): localize supplier/restaurant/driver home + profile tabs"
```

---

## Task 5: Localize the supplier pickup wizard (3 steps + request view)

**Files:**
- Modify: `lib/ui/features/home/supplier/widgets/wizard/step_1_material_photo.dart` (6)
- Modify: `lib/ui/features/home/supplier/widgets/wizard/step_2_quantity_price.dart` (6)
- Modify: `lib/ui/features/home/supplier/widgets/wizard/step_3_location_review.dart` (20)
- Modify: `lib/ui/features/home/supplier/views/new_pickup_request_view.dart` (6)
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

- [ ] **Step 1: Inventory** per file.

- [ ] **Step 2: Add keys** with `wizard` prefix (`wizardStep1Title`, `wizardQuantityLabel`, `wizardPricePerKg`, `wizardLocationHint`, etc.).

- [ ] **Step 3: Regenerate** — `flutter gen-l10n`.

- [ ] **Step 4: Replace literals**. Price/quantity inputs likely use placeholders for units.

- [ ] **Step 5: Verify** — `flutter analyze` clean.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/home/supplier/ lib/l10n/
git commit -m "feat(l10n): localize supplier pickup wizard (steps 1-3 + request view)"
```

---

## Task 6: Localize driver order cards + pickup proof + earnings cards

**Files:**
- Modify: `lib/ui/features/home/driver/widgets/driver_active_order_card.dart` (13)
- Modify: `lib/ui/features/home/driver/views/pickup_proof_view.dart` (12)
- Modify: `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart` (10 — these are user-facing status/error strings surfaced by the UI, not internal logs)
- Modify: `lib/ui/features/home/driver/widgets/driver_earnings_header.dart` (7)
- Modify: `lib/ui/features/home/driver/widgets/driver_earnings_fee_row.dart` (8)
- Modify: `lib/ui/features/home/driver/widgets/driver_earnings_best_day_card.dart` (9)
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

> **Caveat for `driver_home_viewmodel.dart`:** ViewModels don't have a `BuildContext`, so they can't call `context.l10n`. Two valid options — pick per string:
> (a) If the string is an error message shown via `ViewState.Failed(AppFailure)`, keep the failure as a *type* and resolve the message in the **view** using `AppFailure` → localized label. (Preferred — keeps the VM pure.)
> (b) If it's a toast/snackbar triggered from the VM, pass `AppLocalizations` into the VM method call, or emit an enum/key the view localizes.
> Do NOT import `AppLocalizations` as a global singleton — match how other VMs in this repo surface errors (check `supplier_home_viewmodel.dart`).

- [ ] **Step 1: Inventory** per file.

- [ ] **Step 2: Add keys** with `driver` prefix. Earnings values use currency/number placeholders.

- [ ] **Step 3: Regenerate** — `flutter gen-l10n`.

- [ ] **Step 4: Replace literals** in cards/views. For the VM, apply caveat (a) or (b) above — keep the VM free of `BuildContext`.

- [ ] **Step 5: Verify** — `flutter analyze` clean.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/home/driver/ lib/l10n/
git commit -m "feat(l10n): localize driver order card, pickup proof, earnings cards"
```

---

## Task 7: Localize shared order details + marketplace sheets + collection sale

**Files:**
- Modify: `lib/ui/features/home/shared/order_details/order_arrival_section.dart` (12)
- Modify: `lib/ui/features/home/shared/order_tracking_card.dart`
- Modify: `lib/ui/features/home/shared/views/collection_sale_detail_view.dart` (16)
- Modify: `lib/ui/features/home/shared/views/accept_collection_job_sheet.dart` (8)
- Modify: `lib/ui/features/home/shared/market_item_details/widgets/market_item_delivery_address_sheet.dart` (14)
- Modify: `lib/ui/features/home/shared/market_item_details/widgets/market_item_purchase_choice_sheet.dart` (6)
- Modify: `lib/ui/features/home/shared/profile/widgets/payment_wallet_card.dart` (17)
- Modify: `lib/ui/common/widgets/dev_testing_panel.dart` (22 — **only the user-visible labels**; dev debug labels can stay, but the panel does show in some builds, so localize the labels a user would see and leave internal debug identifiers).
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

- [ ] **Step 1: Inventory** per file.

- [ ] **Step 2: Add keys** with `order`, `market`, `wallet`, `collection` prefixes.

- [ ] **Step 3: Regenerate** — `flutter gen-l10n`.

- [ ] **Step 4: Replace literals**.

- [ ] **Step 5: Verify** — `flutter analyze` clean.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/home/shared/ lib/ui/common/widgets/dev_testing_panel.dart lib/l10n/
git commit -m "feat(l10n): localize shared order/marketplace/wallet + dev panel labels"
```

---

## Task 8: Localize chat UI + earnings dashboard

**Files:**
- Modify: `lib/ui/features/chat/views/chat_view.dart` (20 strings — input hint, send button tooltip, empty state, timestamps labels)
- Modify: `lib/ui/features/earnings/views/earnings_dashboard_view.dart` (12)
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`

> **Do NOT touch:** `dawa_chatbot_service.dart`, `gemini_chat_service.dart`, `dawa_chat_view_model.dart` (demo scan content). See Scope decisions at the top.

- [ ] **Step 1: Inventory** the two files.

- [ ] **Step 2: Add keys** with `chat` and `earnings` prefixes.

- [ ] **Step 3: Regenerate** — `flutter gen-l10n`.

- [ ] **Step 4: Replace literals** in both files.

- [ ] **Step 5: Verify** — `flutter analyze` clean.

- [ ] **Step 6: Commit**

```bash
git add lib/ui/features/chat/views/chat_view.dart lib/ui/features/earnings/views/earnings_dashboard_view.dart lib/l10n/
git commit -m "feat(l10n): localize chat screen UI + earnings dashboard"
```

---

## Task 9: ARB parity safety-net test + sort keys

**Files:**
- Create: `test/l10n/arb_parity_test.dart`
- Modify: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb` (sort only — no semantic change)

This task locks in the work: a test that fails if the two ARB files ever drift, plus an alphabetical key sort so the files stay navigable.

- [ ] **Step 1: Write the failing test**

`test/l10n/arb_parity_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final arFile = File('lib/l10n/app_ar.arb');
  final enFile = File('lib/l10n/app_en.arb');

  Map<String, dynamic> keys(File f) {
    final raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    // Keep only real keys (drop @@locale and @metadata entries).
    return Map.fromEntries(
      raw.entries.where((e) => !e.key.startsWith('@') && e.key != '@@locale'),
    );
  }

  test('app_ar.arb and app_en.arb have identical key sets', () {
    final ar = keys(arFile).keys.toSet();
    final en = keys(enFile).keys.toSet();
    expect(ar.difference(en), isEmpty, reason: 'Keys in ar but missing in en');
    expect(en.difference(ar), isEmpty, reason: 'Keys in en but missing in ar');
  });

  test('no localized value is empty', () {
    for (final entry in {...keys(arFile), ...keys(enFile)}.entries) {
      expect((entry.value as String).trim().isNotEmpty, true,
          reason: 'Empty value for key ${entry.key}');
    }
  });
}
```

- [ ] **Step 2: Run the test — expect it to PASS** (the prior tasks kept the files in sync).

Run: `flutter test test/l10n/arb_parity_test.dart`
Expected: PASS (2 tests). If it fails, a prior task missed a key — fix that task, not this test.

- [ ] **Step 3: Sort the ARB files alphabetically by key**

Do this **only** for the top-level real keys (keep each `"@<key>"` metadata block immediately after its key). Re-running `flutter gen-l10n` after sorting confirms nothing broke. Use a stable sort; do not reformat values. Verify diff is purely reordering.

- [ ] **Step 4: Regenerate + full verify**

Run: `flutter gen-l10n`
Run: `flutter analyze` → `No issues found!`
Run: `flutter test test/l10n/arb_parity_test.dart` → PASS

- [ ] **Step 5: Commit**

```bash
git add test/l10n/arb_parity_test.dart lib/l10n/app_ar.arb lib/l10n/app_en.arb lib/l10n/generated/
git commit -m "test(l10n): add ARB parity test + alphabetize ARB keys"
```

---

## Task 10: Final full-suite verification + report

**Files:** none modified — verification only.

- [ ] **Step 1: Confirm zero remaining in-scope Arabic literals**

Run this and review the output:
```bash
grep -rP "[\x{0600}-\x{06FF}]" lib/ui --include="*.dart" \
  | grep -v "dawa_chatbot_service.dart\|gemini_chat_service.dart\|dawa_chat_view_model.dart" \
  | grep -vE "^\s*///|^\s*//" \
  | grep -vE "Text\(|title:|label:|hintText:|helperText:|content:|tooltip:" \
  > /tmp/remaining_ar.txt
wc -l /tmp/remaining_ar.txt
```
Expected: the remaining hits should be only data (e.g. demo sample names in non-chat files), enum label maps (which are *supposed* to hold Arabic labels and are accessed via `.label`), or comments. Document any unexpected survivors.

- [ ] **Step 2: Confirm no remaining in-scope English UI literals**

```bash
grep -rnP "(Text|title|label|hintText)\s*:\s*'[A-Za-z]" lib/ui --include="*.dart" \
  | grep -v "context.l10n" | grep -v "login_view.dart" | grep -v "kDebugMode"
```
Expected: near-empty. The `login_view.dart` dev-panel and debug-gated labels are out of scope.

- [ ] **Step 3: Full test suite**

Run: `flutter test`
Expected: no NEW failures beyond the pre-existing ones documented in AGENTS.md §4 (`mock_auth_repository_test.dart`, `chat_view_test.dart`).

- [ ] **Step 4: Clean analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Write a short completion report**

Append to `devPlans/localization_completion_report.md` (create it): number of keys added, files touched, anything left out-of-scope and why, and the manual smoke-test checklist (switch locale in settings → confirm each major screen flips).

- [ ] **Step 6: Commit**

```bash
git add devPlans/localization_completion_report.md
git commit -m "docs(l10n): localization completion report"
```

---

## Manual smoke test (after all tasks)

1. Launch the app, switch language to English in profile settings.
2. Walk every screen: login → each role signup → role home → order details → marketplace → chat → earnings → profile.
3. Confirm no screen shows Arabic when locale = English (except the deliberately-excluded chatbot data/prompt).
4. Switch back to Arabic, confirm no English leaks and layout is correct RTL.
5. Confirm interpolated labels (counts, prices, phone numbers) render correctly in both locales.

---

## Self-Review (run after writing this plan — done)

**1. Spec coverage:** The user asked for (a) localization implementation, (b) both ar+en, (c) good file sorting/structure, (d) better-looking result. (a)→Tasks 2–8; (b)→every task edits both ARB files; (c)→Task 1 DRY consolidation + Task 9 alphabetical sort + the shared `photo_source_picker.dart`; (d)→Task 9 sort + the consistency of all screens localizing. No gap.

**2. Placeholder scan:** No "TBD"/"implement later". Where a step says "Inventory the strings" it gives the exact grep command. ARB key *names* are illustrative (prefixed) because the real names depend on what the grep finds — the task tells the engineer to choose names following the stated convention. This is intentional, not a placeholder failure.

**3. Type consistency:** `showPhotoSourcePicker<T>` is generic in Task 1 Step 3 with a note to specialize to `ImageSource` after reading callers — flagged explicitly so the signature stays consistent across the three callers. The parity test in Task 9 reads the same two ARB files edited by every other task.

---

## Execution note

This plan is deliberately ordered so each task is independently committable and the app stays fully working + localized between tasks. If a subagent-driven execution is chosen, tasks can run in parallel **only within the constraint that no two tasks edit the same ARB files simultaneously** — otherwise merge conflicts on `app_ar.arb`/`app_en.arb` are guaranteed. Recommended: serialize Tasks 1–9 (they all touch the ARB files), then Task 10.
