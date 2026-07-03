# Partner Sign-Up — Document Verification, Address/Preferences & Design System (Phase 2)

> **Relationship to existing docs:** This is a **Phase 2 addendum** to
> `docs/signup-redesign-plan.md` (locked 2026-06-21). That plan already covers
> Screens 1–4 (phone → OTP → identity/role → role details) and is
> **substantially implemented** in the current codebase. This document covers
> what that plan scoped as **Screen 5 (documents)** — plus two things the
> original plan left thin: AI-verification *animation* design and
> Careem/Talabat-style address & preference selection — based on fresh
> competitor and UI/UX research (Careem, Talabat, DoorDash, Uber, Stripe
> Identity/Onfido/Persona, Dribbble/Behance).
>
> **Status:** Research + design — ready for review before implementation.
> **Scope:** All three roles — Driver, Supplier (individual + store/restaurant),
> Recycling Company.

---

## 1. Where the code actually stands today (audit, not assumption)

Read directly from the repo before writing this plan, so recommendations build
on reality instead of duplicating work:

| Area | State | Evidence |
|---|---|---|
| Screen 1–2 (phone + OTP) | **Built** | `signup_phone_screen.dart`, `verification_view.dart` |
| Screen 3 (photo + name + role cards) | **Built** | `signup_identity_screen.dart` |
| Screen 4 (vehicle/categories/location, progressive) | **Built** | `signup_role_details_screen.dart` |
| AI document-scan animation pattern | **Built, but only for vehicle registration** | `vehicle_registration_scan_section.dart` — idle → analyzing (shimmer + scanline + pulsing field labels) → valid (extracted-data card + confidence %) → invalid (retry). This is a genuinely good pattern; the recommendation below is to **generalize and reuse it**, not reinvent it. |
| Screen 5 (ID/license document upload, "under review") | **Not built** | No screen references `SignupController.submitDocuments()` or `ISignupOrchestrator.uploadIdentityDocument()`. The controller method and backend plumbing exist and work — there is simply no UI screen that calls them. `profiles.identity_doc_path` and `is_verified` are ready to receive data. |
| Business/company license AI verification | **Built as a service, wired to dead code** | `GeminiAiSimulationService.verifyDocumentAndAddress()` (Gemini Vision: "is this a valid business license/health permit/commercial registration?") is only called from `store_onboarding_viewmodel.dart`, which is the **pre-redesign, password-based wizard** — not part of the new phone-first flow and, per the redesign plan's own architecture decision #3, marked for deletion. |
| Map-based location picker | **Not built** | Screen 4 uses GPS "detect my location" + free-text address field only. No pin-drop/service-area map UI. |
| `vehicle_type`, `has_chemical_permit`, commercial-registration-doc columns | **Missing in schema** | `profiles` table (`00001_initial_schema.sql`) has `vehicle_model`, `vehicle_color`, `vehicle_plate`, `vehicle_photo_url` but **no `vehicle_type` or `has_chemical_permit` column** — the AI scan extracts these but there is nowhere to persist them. No `commercial_reg_doc_path` either. |
| Dead code | `store_onboarding_viewmodel.dart`, `license_scan_section.dart` (0 references anywhere in `lib/`), likely `recycling_co_onboarding_viewmodel.dart` / `individual_supplier_onboarding_viewmodel.dart` | Confirmed via grep — orphaned from the pre-redesign wizard. |

**The practical implication:** most of the "make a new sign-up UI" work is
already done and working. What's actually missing — and what this document
designs — is the **document/license verification screen (Screen 5)** with an
AI-verification animation, and an **upgraded address/preferences step**. Both
should extend patterns that already exist in the codebase rather than
introduce a new visual language.

---

## 2. Research: how other platforms handle this

### 2.1 Partner document verification

| Platform | Pattern | Source |
|---|---|---|
| **Careem Captain** | 4 required documents: profile picture, ID card, driving license, car registration. Upload happens in-app after account creation; verified async, captain can't accept trips until approved. | [Careem driver requirements](https://www.uber.com/us/en/drive/requirements/documents/), [Careem application steps](https://help.careem.com/hc/en-us/articles/4408030572819-Application-steps-for-UAE) |
| **Talabat (restaurant partner)** | Requires trade license/business registration, tax certificate, ID, power of attorney, trademark certificate (region-dependent) — collected as part of the partner form, verified by a human review team before the store goes live. | [Talabat restaurant sign-up guide](https://www.urbanpiper.com/blog/talabat-restaurant-sign-up) |
| **Uber (driver)** | Documents uploaded from Account → Documents in the driver app (camera capture); background check runs in parallel and status shows as Onboarding/Consider/Suspended/Complete — never blocks initial app access. | [Uber document upload](https://help.uber.com/driving-and-delivering/article/uploading-documents), [Uber required documents](https://www.uber.com/us/en/drive/requirements/documents/) |
| **DoorDash (merchant)** | Business details + banking verification collected via a guided form (~15–20 min); menu/store setup can proceed while some verification is still pending. | [DoorDash merchant onboarding](https://merchants.doordash.com/en-us/learning-center/get-started-on-doordash) |
| **Stripe Identity / Onfido / Persona** (industry-standard KYC UX, not ride-hailing but the reference pattern for "AI verifying your document") | Guided capture with real-time glare/blur detection and auto-capture of the best frame; document authenticity + optional face-liveness match; typical verification completes in seconds, with a clear pass/fail/needs-review state. | [Onfido overview](https://onfido.vercel.app/), [Stripe Identity](https://stripe.com/identity), [ID verification case study](https://www.ux.danielspagnolo.com/casestudy-id-verification.html) |

**Takeaway that validates the existing codebase pattern:** the
scan-line-over-shimmer + "extracting: type… plate… model… expiry…" pulsing
labels + confidence-score result card already built in
`vehicle_registration_scan_section.dart` matches the industry pattern almost
exactly (guided capture → live "analyzing" feedback → structured
extracted-data confirmation with a confidence indicator). The gap isn't the
animation language — it's that this component only exists for one document
type and one role.

### 2.2 Address & preference/category selection ("Careem/Talabat" pattern the user asked about)

- **Careem Captain**: city is chosen once at signup (support-gated to change later); captains otherwise set working hours/areas as an ongoing preference, not a one-time form field — i.e., "coarse commitment at signup, fine-grained preference later, adjustable in-app." ([Careem Captain city selection](https://help.careem.com/hc/en-us/articles/4408012348819-How-can-I-apply-to-become-a-Captain))
- **Talabat/DoorDash restaurant partners**: cuisine/category tags chosen at signup directly drive what customers see, so category selection is treated as a *business* decision (chip multi-select, not a one-off checkbox) — consistent with the waste-type chip picker Dwaar already has on Screen 4.
- **Cross-platform pattern**: none of these apps make address/service-area a blocking, single-shot field — they let it be coarse at signup (detected GPS point or city) and refined later from a settings/profile screen, matching the "progressive, non-blocking" principle already locked into `docs/signup-redesign-plan.md`.

**Takeaway:** Dwaar's current GPS-detect-plus-text-field approach is directionally right (non-blocking, progressive) but underserves two things competitors get right: (1) a **visual map picker** so the user can *see and adjust* the pin, not just trust a geocoded address string; (2) treating the waste-category selection as a **reusable "preferences" pattern** that also appears later in profile settings — not a one-time signup artifact.

---

## 3. Design: Screen 5 — Document & License Verification

### 3.1 Per-role document requirements

| Role | Document(s) | Why | AI check |
|---|---|---|---|
| Driver | National ID **or** driving license (front + back) | Identity + legal right to drive | OCR extraction (name, ID number, expiry) + authenticity heuristic |
| Individual supplier | National ID (front + back) | Identity only — lightest-weight role | OCR extraction + authenticity heuristic |
| Store/restaurant supplier | Business/commercial registration **or** health permit | Confirms the business is legally allowed to operate | Reuses `GeminiAiSimulationService.verifyDocumentAndAddress()` — already built, just needs re-wiring into the new flow |
| Recycling company | Commercial registration + environmental/recycling license | Confirms legal authority to process waste — the highest-trust role in the app | Same Gemini document-verification call, extended prompt for recycling-specific licensing language |

Both-sides capture for IDs (Talabat Oman requires this; single-side capture is
a common source of rejected verifications industry-wide).

### 3.2 Flow (extends the existing 5-screen plan, doesn't block signup)

```
Screen 4 (role details) — "Save & Continue"
        ↓
┌───────────────────────────────────────────────────────────┐
│  Screen 5 — DOCUMENT VERIFICATION   (async, skippable)     │
│                                                             │
│  Driver / Individual supplier:        Store / Recycling Co:│
│  "ارفع بطاقتك الشخصية"                "ارفع رخصة العمل"    │
│  [الوجه الأمامي 📷]  [الوجه الخلفي 📷]  [صورة الوثيقة 📷]   │
│                                                             │
│  → AI ANALYZING state (reuse scan-line + shimmer pattern)  │
│     "🔍 نتحقق من الوثيقة..." + pulsing extracted fields    │
│                                                             │
│  → RESULT state:                                           │
│     ✅ verified inline    → badge: "قيد المراجعة" (pending)│
│     ⚠️ needs retake        → reason + retry, doesn't block  │
│                                                             │
│  [متابعة]   [تخطي، سأكمل لاحقاً]                            │
└───────────────────────────────────────────────────────────┘
        ↓
   HomeRouter — user is in the app; capability-gated banner shows
   "وثائقك قيد المراجعة" until an admin/AI flips is_verified = true
```

Key rule carried over from the locked architecture decision in the base plan:
**documents never block entry to the app.** Screen 5 can be skipped exactly
like Screen 4; the gate is on *capabilities* (drivers can't accept jobs,
companies can't receive marketplace orders) via `profiles.is_verified`, not on
navigation.

### 3.3 The AI verification animation — generalized component

Rather than a new animation, extract `vehicle_registration_scan_section.dart`'s
four-state pattern into a shared, parameterized `DocumentAiScanSection`:

| State | Visual (already built for vehicle scan, reused here) |
|---|---|
| `idle` | Dashed-border tile, icon + "اضغط لالتقاط صورة" prompt |
| `analyzing` | `AiShimmerLoader` + moving scan-line overlay + `AnimatedStatusText` cycling through role-specific extraction phrases ("نتحقق من الاسم… الرقم الوطني… تاريخ الانتهاء…" for ID; "نتحقق من الترخيص… اسم الشركة… تاريخ الإصدار…" for business docs) |
| `valid` | Green result card: thumbnail + extracted fields + confidence-score badge + "تأكيد" button |
| `invalid` | Red card with reason (blurry / expired / wrong document type) + retry button — never a dead end |

Parameterize by a small config object (`prompt text`, `extraction field list`,
`Gemini prompt template`, `target profile column`) so the same widget serves
ID cards, driving licenses, and business licenses without duplicating the
~600 lines currently locked into the vehicle-only component.

### 3.4 Trust microcopy (an explicit gap noted in the base plan, item 7)

Every document field should carry a one-line "why we need this," styled like
the existing `signupPrivacyNotice` on Screen 3:

- ID upload: "نستخدم هذه الصورة للتحقق من هويتك فقط، ولا نشاركها مع أي طرف ثالث."
- Business license: "نتحقق من الترخيص للتأكد من أن نشاطك مسجل رسمياً في الأردن."
- "Under review" badge: pair with an expected turnaround ("عادة خلال 24 ساعة") — Uber/DoorDash both set this expectation explicitly; Dwaar currently doesn't.

---

## 4. Design: Address & Preferences (Careem/Talabat-style upgrade to Screen 4)

### 4.1 Replace free-text-plus-GPS with an interactive map picker

- Full-bleed map (Google Maps, already a dependency) opens from the existing
  "detect location" tile.
- Center pin draggable; reverse-geocoded address updates live underneath (Jordan
  governorate/city granularity, matching the existing `geocoding` package
  already used).
- For drivers: label as "منطقة عملك الرئيسية" (primary work area) — a single
  point, matching Careem's "pick a city, refine later" model.
- For recycling companies/stores: label as "موقع المنشأة" (facility location) —
  this is a fixed legal address, not a roaming zone, so a single precise pin is
  correct (no radius selector needed here — that's a driver/coverage concept,
  not a fixed-facility one).

### 4.2 Category/preference selection as a reusable component

The existing waste-type chip multi-select (`_WasteTypeChips`) is already the
right interaction pattern (Talabat/DoorDash-style tag selection). Two
upgrades:

1. **Reuse it in profile settings**, not just signup — so "preferences" is a
   living setting, not a one-time form (matches how Careem treats
   working-area/hours as an ongoing preference rather than a signup-only
   field).
2. **Order chips by role relevance** — e.g. a recycling company sees the waste
   types it's licensed to *process* first; a supplier sees the types it
   *generates* first. Same component, role-aware default ordering.

---

## 5. Design system additions

Extend `AppColors` / `app_tokens.dart` (existing green/amber-based system —
`primaryGreen #0F5A34`, `accentAmber #D97706`, status-bg/text pairs already
follow a consistent soft-bg/high-contrast-text convention) with a small,
consistent **verification-state** token set, mirroring the existing
`statusPendingBg/Text`, `statusActiveBg/Text` naming convention already in
`app_colors.dart`:

| Token (new) | Value (proposed, consistent with existing palette) | Use |
|---|---|---|
| `verificationPendingBg` / `Text` | reuse `statusPendingBg #FEF3C7` / `statusPendingText #92400E` | "Under review" badge |
| `verificationApprovedBg` / `Text` | reuse `statusActiveBg #D1FAE5` / `statusActiveText #065F46` | Verified badge |
| `verificationRejectedBg` / `Text` | reuse `statusCancelledBg #FEE2E2` / `statusCancelledText #991B1B` | Needs-retake state |
| `aiScanLine` | `#60A5FA` (already used in the vehicle-scan overlay) | Keep as the one "AI is working" accent — don't introduce a second blue |
| `confidenceBadge` | `#059669` (already used) | Confidence-score chip, reused across all document types |

No new color family needed — the existing status-color convention already
covers pending/approved/rejected semantics; the recommendation is to name and
reuse it consistently rather than hardcode one-off hex values per screen (a
pattern already visible in the current code, e.g. `Color(0xFFECFDF5)` repeated
inline instead of referencing a token).

Animation timing tokens (currently inline, worth centralizing):
`scanLineDuration: 2s` (repeat-reverse), `pulseLabelInterval: 700ms`,
`pulseLabelLife: 1200ms`, `resultTransition: 300ms` — all already implicitly
defined inside `vehicle_registration_scan_section.dart`; centralize them into
`app_tokens.dart` when the component is generalized (Section 3.3) so every
document-scan instance stays visually in sync.

---

## 6. System design

### 6.1 Schema changes needed (migration)

```sql
-- New migration, e.g. 000XX_verification_fields.sql
ALTER TABLE public.profiles
  ADD COLUMN vehicle_type          TEXT,              -- currently extracted by AI, nowhere to land
  ADD COLUMN has_chemical_permit   BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN commercial_reg_path   TEXT,               -- business/recycling license object path
  ADD COLUMN verification_status   TEXT NOT NULL DEFAULT 'unverified'
    CHECK (verification_status IN ('unverified','pending','approved','rejected'));
-- Keep is_verified as a generated/derived boolean for backward compatibility
-- with existing capability-gating checks, or migrate call sites to the enum.
```

This directly fixes the two persistence gaps found in the audit (Section 1)
and upgrades the current boolean `is_verified` to the four-state machine the
base plan explicitly deferred ("tracked as follow-up if/when an admin review
dashboard is built" — Screen 5 is that follow-up).

### 6.2 Storage & repository

`IFileStorageRepository` already has the right shape
(`uploadProfilePhoto` / `uploadIdentityDocument` / `signedIdentityUrl`,
private `user-documents` bucket, signed URLs for admin/profile display — see
`i_file_storage_repository.dart`). Add one more method for the business-license
path, mirroring `uploadIdentityDocument`:

```dart
Future<AppResult<String>> uploadBusinessLicense({
  required String userId,
  required File file,
});
```

### 6.3 Orchestration

`ISignupOrchestrator.uploadIdentityDocument` already does upload → write-back
→ `is_verified = false` in one transaction-safe operation (fixing the
historical "uploaded but never persisted" bug). Extend with:

```dart
Future<AppResult<String>> uploadBusinessLicense(File document);
Future<AppResult<VerificationResult>> runAiVerification({
  required File document,
  required DocumentKind kind, // id, drivingLicense, businessLicense, recyclingLicense
});
```

`runAiVerification` is the wiring point that finally connects
`GeminiAiSimulationService.verifyDocumentAndAddress()` (already built, Gemini
Vision-based) to the *new* phone-first flow instead of the dead
`store_onboarding_viewmodel.dart`.

### 6.4 Admin review (explicitly out of scope for this phase, per the base plan)

The base plan already scopes this correctly: Phase 2 delivers the AI
pre-check + "pending" badge; a human admin review dashboard (`verification_status`
transitions from `pending` → `approved`/`rejected`) is separate follow-up
work, likely a Supabase Edge Function + a lightweight internal tool, not part
of the consumer-facing app.

---

## 7. Implementation task list (ordered)

1. **Cleanup**: delete `store_onboarding_viewmodel.dart`, `license_scan_section.dart`, and confirm `recycling_co_onboarding_viewmodel.dart` / `individual_supplier_onboarding_viewmodel.dart` are unreferenced before deleting (verify with grep first — don't assume).
2. **Migration**: add `vehicle_type`, `has_chemical_permit`, `commercial_reg_path`, `verification_status` columns (Section 6.1).
3. **Extract** `DocumentAiScanSection` from `vehicle_registration_scan_section.dart` as a parameterized shared widget (Section 3.3).
4. **Build Screen 5** (`signup_documents_screen.dart`): role-branches to ID-only (driver/individual) vs. business-license (store/recycling), both-sides capture for IDs, skip option, "under review" badge with turnaround copy.
5. **Wire** `runAiVerification` into `SignupController` / `SignupOrchestrator`, connecting the existing but currently-dead `verifyDocumentAndAddress()` Gemini call.
6. **Map picker**: replace GPS-detect+text-field with a draggable-pin map sheet on Screen 4 (Section 4.1).
7. **Design tokens**: add the verification-state tokens (Section 5) to `app_tokens.dart` / `AppColors`, replacing inline hex where the scan component gets generalized.
8. **Reuse category chips** in profile settings (Section 4.2) so preferences are editable post-signup, not signup-only.
9. **Localize**: add the new ARB keys (document prompts, trust microcopy, "under review" + turnaround) following the existing `context.l10n.*` convention; don't hardcode Arabic (the base plan already flags ~65 unused keys from the old wizard — audit before adding new ones in case some can be reused).
10. **Tests**: extend the `AppOrderStore`/signup test suite pattern with widget tests for the four-state scan component and a unit test for `verification_status` transitions.

---

## 8. Open questions for next research pass (per your note — more research later)

- Exact Jordanian legal document types accepted for recycling-company licensing (Ministry of Environment vs. municipal permits) — needs a local-regulatory source pass, not a UX one.
- Whether WhatsApp OTP (already flagged as a gap in the base plan) should ship before or alongside Screen 5 — both are "trust" investments but independent.
- Whether WhatsApp Business API delivery of the "under review" / "approved" notification is preferable to in-app-only status (Careem uses SMS + in-app; worth a follow-up look at what Jordanian users expect).

---

## Sources

- [Uber — Required Documents for Drivers](https://www.uber.com/us/en/drive/requirements/documents/)
- [Uber — Uploading documents (Help Center)](https://help.uber.com/driving-and-delivering/article/uploading-documents)
- [Careem — Application steps for UAE](https://help.careem.com/hc/en-us/articles/4408030572819-Application-steps-for-UAE)
- [Careem — How can I apply to become a Captain?](https://help.careem.com/hc/en-us/articles/4408012348819-How-can-I-apply-to-become-a-Captain)
- [Talabat Restaurant — Complete Guide to Signing Up (UrbanPiper)](https://www.urbanpiper.com/blog/talabat-restaurant-sign-up)
- [DoorDash — How to Sign Up for DoorDash as a Merchant](https://merchants.doordash.com/en-us/learning-center/get-started-on-doordash)
- [Onfido — Document ID & Facial Biometrics Verification](https://onfido.vercel.app/)
- [Stripe Identity](https://stripe.com/identity)
- [Identity verification case study — Daniel Spagnolo](https://www.ux.danielspagnolo.com/casestudy-id-verification.html)
- [Dribbble — KYC & Identity Verification App (Zoftify)](https://dribbble.com/shots/16440694-KYC-Identity-Verification-App-Mobile)
- [Dribbble — Identity verification screens (Rewire, by Nitzan Guy)](https://dribbble.com/shots/15591809-Identity-verification-screens)
- Internal: `docs/signup-redesign-plan.md` (base plan, locked 2026-06-21), and direct code audit of `lib/ui/features/auth/`, `lib/data/services/`, `lib/domain/`, `supabase/migrations/00001_initial_schema.sql`.
