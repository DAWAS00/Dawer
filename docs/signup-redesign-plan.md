# Signup Flow Redesign Plan — Dwaar (دوّر)

> **Goal:** a fast, Arabic-first, role-aware signup that collects everything the
> backend needs *without* upfront friction. Based on research into Careem,
> Talabat, HungerStation, Uber, DoorDash, and a full audit of Dwaar's current
> code/data contract.
>
> **Status:** Design — ready for review before implementation.

---

## The core principle (the one idea that drives everything)

> **Phone is the account. Role + documents are capabilities.**

Every leading MENA app (Careem, Talabat, HungerStation) treats the phone number
as the identity and gates dangerous actions behind *async* verification — never
blocking initial signup on documents. Dwaar's current wizard does the opposite:
phone is collected *last* (Step 4), documents are collected upfront (Step 2),
and several collected fields are silently dropped.

The redesign inverts this: **phone + OTP first → name + role → minimum viable
account → the user enters the app → role-specific data + documents collected
progressively (and actually persisted)**.

---

## What's wrong today (evidence-backed, from the code audit)

| # | Problem | Evidence |
|---|---|---|
| 1 | **Phone is Step 4 of 4** — backwards vs. every MENA benchmark | `step4_credentials.dart:33` read-only; OTP already done upstream |
| 2 | **5+ fields collected then silently dropped** | `vehicleType`, `hasChemicalPermit` omitted from `toInsertRow` (`signup_request.dart:106-138`); `ownerManagerName`/`coverageArea`/`primaryCategory` never sent to `SignUpRequest` (`controller:52-54`); `profilePhotoUrl`/`identityDocPath` uploaded but URL never written back to `profiles` (`user_signup_service.dart:74-75`) |
| 3 | **A dead input** — "vehicle type & model" field's `onChanged` is `(v) => {}` | `step3_role_details.dart:68` — looks interactive, discards every keystroke |
| 4 | **AI vehicle scan is dormant** — `GeminiVehicleRegistrationService` exists but the wizard never calls it | only the *license* validator is wired (`controller:104`); the vehicle service is referenced only from the dead `SignUpViewModel` |
| 5 | **No validation actually runs** — `controller._validate()` only checks `name` + `vehiclePlate`; `SignUpRequest.validate()` is never called | `signup_wizard_controller.dart:130-143` |
| 6 | **Store/business supplier path is unreachable** — hardcoded to `individual` | `controller:40`, `login_view.dart:347`; no selector widget anywhere |
| 7 | **~65 ARB keys exist but the wizard uses 0** — every string hardcoded Arabic | `app_ar.arb:79-163` unused; `signup_wizard_view.dart:97` etc. all literals |
| 8 | **No location capture** — `profiles.location_lat/lng`, `address` always null | no map picker in any wizard step |
| 9 | **`vehicleType`/`hasChemicalPermit`**: model field + DB column both exist, AI can extract them, yet `toInsertRow` omits them | pure persistence bug |

---

## The redesigned flow (5 screens, phone-first)

```
┌─────────────────────────────────────────────────────────────┐
│  Screen 1 — PHONE                                            │
│  ┌───────────────────────────────────────────┐              │
│  │  🇯🇴 +962  7 ▮▮ ▮▮▮▮ ▮▮▮▮                │  ← LTR,  │
│  └───────────────────────────────────────────┘     auto-  │
│  "سنتحقق من رقمك عبر رسالة نصية"                  format   │
│  [متابعة ▶]                                                 │
└─────────────────────────────────────────────────────────────┘
              ↓ (sends OTP)
┌─────────────────────────────────────────────────────────────┐
│  Screen 2 — OTP                                              │
│  [ 6 ] [  ] [  ] [  ] [  ] [  ]   ← single field styled as  │
│   00:42 إعادة إرسال                boxes, paste + SMS-autofill│
│  [تحقق ✓]                                                    │
└─────────────────────────────────────────────────────────────┘
              ↓ (verified → no profile yet → Screen 3)
┌─────────────────────────────────────────────────────────────┐
│  Screen 3 — IDENTITY + ROLE  (the "who are you?" screen)     │
│  ┌─────────┐  الاسم الكامل *                                │
│  │  📷     │  ┌──────────────────────────────┐              │
│  │ photo   │  │ أدخل اسمك كما في الهوية     │              │
│  └─────────┘  └──────────────────────────────┘              │
│                                                              │
│  ما نوع حسابك؟                                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                    │
│  │ 🚚 سائق   │ │ 🏪 مورد   │ │ 🏭 شركة   │                    │
│  │          │ │          │ │  تدوير    │                    │
│  └──────────┘ └──────────┘ └──────────┘                    │
│  (if supplier → sub-type toggle: فردي / متجر)               │
│  [متابعة ▶]   ← profile created HERE, user can enter app    │
└─────────────────────────────────────────────────────────────┘
              ↓ (profile row inserted → home shell)
              ↓ (role-specific screens are PROGRESSIVE — gate capabilities)
┌─────────────────────────────────────────────────────────────┐
│  Screen 4 — ROLE DETAILS  (contextual, shown when relevant)  │
│                                                              │
│  DRIVER:               SUPPLIER:        RECYCLING CO:        │
│  - vehicle plate *     - categories     - company name *     │
│  - scan registration   - coverage area  - manager name       │
│    (AI auto-fills       - location       - commercial reg    │
│     model/color/type/      picker        - location          │
│     chemical permit)                                          │
│  - location (home base)                                       │
│                                                              │
│  "لماذا نحتاج هذه البيانات؟" microcopy on sensitive fields   │
│  [حفظ ومتابعة]   ← all fields actually PERSISTED             │
└─────────────────────────────────────────────────────────────┘
              ↓ (async "under review" badge on documents)
┌─────────────────────────────────────────────────────────────┐
│  Screen 5 — DOCUMENT UPLOAD  (async, doesn't block signup)   │
│  - ID/license photo (camera OR gallery, both sides)          │
│  - AI extracts: doc number, org, expiry, categories          │
│  - "قيد المراجعة" badge (Uber/Careem pattern: 2-24h)         │
│  - user can close & return; state is draft-saved             │
└─────────────────────────────────────────────────────────────┘
```

**Key difference from today:** after Screen 3 the user is *in the app*. Screens
4 & 5 collect the role-specific data, but they're not a wall — a Driver can see
the app immediately, they just can't *accept jobs* until vehicle + documents
are verified. This is the Careem (account → captain activation) and DoorDash
(account → background check) pattern.

---

## Top 10 patterns to adopt (from research, ranked by impact)

1. **Phone-OTP as Screen 1** (Careem, Talabat, HungerStation all do this). Currently Dwaar's last step.
2. **WhatsApp OTP option** (Careem) — SMS reliability in Jordan is uneven.
3. **Force LTR on phone, OTP, vehicle plate** even in RTL (FlutterFire #9379, Bumble Tech, Smashing). Number-one documented RTL bug.
4. **Single OTP field styled as 6 boxes** with paste + SMS-autofill (Baymard: don't split single logical inputs).
5. **Progressive gating** — account in 2 taps, capabilities verified async (Careem/DoorDash/Uber all do this).
6. **"Under review" state for documents** — Uber 2-24h, DoorDash hours-days, Careem Jordan weeks. Don't block on inline validation.
7. **"Why we need this" microcopy** on National ID / criminal record / license (DoorDash does this for SSN; MENA apps don't — open differentiator).
8. **Role selection after OTP, friendly cards, allow multi-role per phone** (Dwaar is 3-roles-one-app, unlike Careem's separate apps).
9. **Camera + gallery upload for documents, both sides** (Talabat Oman requires both sides; Uber drivers report gallery > in-app camera quality).
10. **Draft-save wizard state for resume-later** — document capture is the highest-friction step (DoorDash allows multi-session completion).

**Do NOT invest in:** Google/Facebook social login (low MENA adoption — phone-first is the norm). Put that effort into WhatsApp.

---

## Per-role data contract (fixed — every field below MUST persist)

Driven by `SignUpRequest` + `profiles` schema. Bold = currently broken/missing.

### All roles (Screens 1-3)
| Field | Required | Source | Persists? |
|---|---|---|---|
| phone | yes | Screen 1 (OTP-verified) | ✓ |
| name | yes | Screen 3 | ✓ |
| role | yes | Screen 3 cards | ✓ |
| profilePhoto | optional | Screen 3 picker | ✗ **URL not written back to `profiles.profile_photo_url`** |
| supplierType (supplier only) | yes | Screen 3 toggle | ✗ **hardcoded `individual`, no selector** |
| email | optional | (defer to settings) | n/a |

### Driver (Screen 4)
| Field | Required | Source | Persists? |
|---|---|---|---|
| vehiclePlate | yes | manual text | ✓ |
| vehicleType | yes | **AI from registration scan** | ✗ **`toInsertRow` omits it + AI service unwired** |
| vehicleModel | optional | AI + manual | ✗ **dead `onChanged: (v){}`** |
| vehicleColor | optional | AI + manual | ✗ never collected |
| vehiclePhotoUrl | optional | photo upload | ✗ never collected |
| hasChemicalPermit | yes | **AI from registration scan** | ✗ **`toInsertRow` omits it + AI unwired** |
| location (home base) | yes | map picker | ✗ **no map picker** |

### Supplier (Screen 4)
| Field | Required | Source | Persists? |
|---|---|---|---|
| categories | optional | AI + manual chips | ✓ (AI only today) |
| coverageArea | optional | manual text | ✗ **orphan — no backend column** |
| location | optional | map picker | ✗ **no map picker** |

### Recycling Company (Screen 4)
| Field | Required | Source | Persists? |
|---|---|---|---|
| businessName | yes | manual text | ✓ (used as `name`) |
| ownerManagerName | yes | manual text | ✗ **orphan — no backend column** |
| commercialRegDoc | yes | photo upload | ✗ **not collected** |
| location | yes | map picker | ✗ **no map picker** |

### All roles (Screen 5 — documents)
| Field | Required | Source | Persists? |
|---|---|---|---|
| identityDocument | yes | camera/gallery | ✗ **uploaded but path not written to `profiles.identity_doc_path`** |
| extracted (docId, org, expiry) | optional | AI | ✗ **shown in UI, never stored** |

---

## Implementation phases (in dependency order)

### Phase A — Fix the data-layer bugs first (no UX change, stops data loss)
1. **`signup_request.dart:toInsertRow`** — add `vehicle_type`, `has_chemical_permit`, `profile_photo_url`, `identity_doc_path` to the row.
2. **`user_signup_service.dart`** — after upload, write the returned `profilePhotoUrl`/`identityDocPath` back into the request before insert (or do a follow-up `UPDATE`).
3. **`step3_role_details.dart:68`** — fix the dead `onChanged: (v) => {}` → actually set `controller.vehicleModel`.
4. **Wire `GeminiVehicleRegistrationService`** into the wizard controller (it currently only calls the license validator). Driver scan → vehicle scan.
5. **`controller._validate()`** — call `SignUpRequest.validate()` instead of the 2-line subset. Or delete the subset and rely on the model's rules.
6. **Add DB columns** for the orphans that are genuinely needed: decide on `owner_manager_name`, `coverage_area` (add columns or drop the fields — don't collect what you won't store).

### Phase B — Reorder to phone-first (the big UX change)
1. **New Screen 1 (phone entry)** — replace the current login-page role grid path; phone input with LTR forcing, country-code prefix `+962`, format hint.
2. **New Screen 2 (OTP)** — single field styled as 6 boxes, SMS-autofill (`sms_autofill` package), paste support, resend timer.
3. **Move Step 4 (phone read-only) → deleted**; phone is now established at Screen 1.
4. **VerificationView** — already routes to the wizard on `phoneNotRegistered`; point it at the new Screen 3 instead.

### Phase C — Role + identity screen (Screen 3)
1. Profile photo + name + role cards (reuse `friendly_role_card.dart`).
2. **Add supplier sub-type toggle** (فردي / متجر) — currently unreachable.
3. **Insert the profile row here** (after Screen 3) so the user enters the app. Defer role-specific data to Screen 4.

### Phase D — Role-specific details screen (Screen 4, progressive)
1. Branch by role: driver vehicle fields + registration scan, supplier categories + coverage, recycling company name + manager + commercial reg.
2. **Add map picker** for location (`google_maps_flutter` + a "select on map" sheet) — fills `location_lat/lng`/`address`.
3. **Wire vehicle AI scan** → auto-fill `vehicleType`/`model`/`color`/`hasChemicalPermit` (fixes Phase A #4 visually).
4. **"Why we need this" microcopy** under sensitive fields.

### Phase E — Documents screen (Screen 5, async)
1. ID/license upload with **camera + gallery** options.
2. **Both-sides capture** for IDs.
3. **"Under review" badge** with expected turnaround.
4. **Draft-save** to `SharedPreferences` so the user can resume.

### Phase F — Localization + polish
1. **Wire the ~65 existing ARB keys** into every step (replace hardcoded Arabic with `context.l10n.*`).
2. Add any missing keys (WhatsApp option, "under review", "why we need this").
3. RTL pass: force LTR on phone/OTP/plate; verify back-arrow + progress-bar mirroring.
4. Skeleton loaders during AI scans; friendly empty states.

### Phase G — Trust + edge cases
1. **Resume-later**: if a draft exists on app launch, offer "continue signup?"
2. **WhatsApp OTP** delivery option (needs a provider; can stub initially).
3. **Multi-role per phone** (future) — allow a Supplier to also register as Driver from settings, instead of re-registering.

---

## Architecture decisions (LOCKED 2026-06-21)

1. **Profile row insertion: PROGRESSIVE (after Screen 3).** The `profiles` row
   is created right after phone+OTP+name+role. The user enters the app
   immediately with `is_verified=false`. Role-specific data (Screen 4) and
   documents (Screen 5) are collected progressively and gate capabilities
   (Driver can't accept jobs until vehicle verified, etc.). Matches
   Careem/DoorDash/Uber.

2. **Wizard structure: PageView for Screens 1-3, independent routes for 4-5.**
   Linear early steps stay swipeable (back-button friendly). Role-specific
   detail + document screens are independent routes so they can be deep-linked
   (e.g. a "finish your driver profile" notification → Screen 4 directly).

3. **Dead `SignUpView`/`SignUpViewModel`: DELETE NOW, rewrite fresh.** Remove
   both files immediately — they're unreachable and confuse readers. The map
   picker and vehicle fields will be rewritten fresh in the new flow (not mined
   from the dead code).

4. **Orphan fields: DROP THEM.** Remove `ownerManagerName`, `coverageArea`,
   `primaryCategory` from the wizard UI entirely. They're collected today but
   never persisted. If a recycling company's manager name becomes a real
   requirement later, add it as a proper column then. For now: less code, no
   silent data loss. (`coverage_area` need → covered by the new map-picked
   `address`/`location` fields.)

5. **Async verification state machine: deferred.** The "under review" badge
   (Phase E) can start as a client-side flag on `profiles.is_verified`. A full
   `verification_status` enum (`unverified`/`pending`/`approved`/`rejected`)
   is tracked as follow-up if/when an admin review dashboard is built.

---

## What NOT to do (explicitly out of scope)

- **Don't build Google/Facebook social login** — low MENA adoption; phone-first is the norm.
- **Don't block signup on document approval** — progressive gating only.
- **Don't add password fields** — OTP-only (matches the restored `SupabaseAuthRepository` contract).
- **Don't build the full admin review dashboard yet** — Phase 5 just needs the *badge*; the review tool is separate work.

---

## Success metrics (how we know it worked)

- **Time-to-first-screen-in-app** drops from "complete 4 steps" to "phone + OTP + name + role" (~30-60s).
- **Zero fields collected-but-not-persisted** (the 5+ current orphans all fixed or dropped).
- **Driver vehicle data actually populates** (`vehicleType`/`hasChemicalPermit` non-null after signup with AI scan).
- **All signup strings localized** (no hardcoded Arabic in the wizard).
- **Signup works fully offline / mock** (existing `useSupabase` gate preserves dev/test flow).

---

## Reference: research sources (key ones)

- **Careem**: customer phone-first OTP (SMS + WhatsApp); captain onboarding is account → documents → in-person → LTRC → activation (Jordan).
- **Talabat**: phone-first; separate rider app; both-sides document capture (Oman).
- **HungerStation**: combined web rider form; phone first field.
- **Uber/DoorDash**: account fast → background check async (Uber 2-24h, DoorDash hours-days). Documents don't block initial onboarding.
- **Baymard**: don't split single logical inputs (OTP) — use one field styled as boxes.
- **NN/G**: progressive disclosure — reveal complexity only as needed.
- **RTL** (FlutterFire #9379, Bumble, Smashing): force LTR on phone/OTP/plate fields; Unicode LRM.

Full source list in the research notes.
