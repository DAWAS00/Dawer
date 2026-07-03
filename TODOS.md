# TODOS

## Both-sides ID capture on Screen 5 document verification (V2)
**What:** Capture front AND back of national ID / driving license, not just front, on the new signup document-verification screen.
**Why:** `docs/design/partner-signup-verification-research-plan.md` Section 3.1 calls for both-sides capture (matches Talabat Oman and industry KYC norms). The current backend only supports one stored image per document type (`uploadIdentityDocument`/`uploadBusinessLicense` each take a single `File`).
**Pros:** Matches the research plan and reduces rejected verifications caused by missing back-side data (signature, issue authority, etc).
**Cons:** Requires a second storage path/column and a second AI-verification pass (or a decision to store-only for the back side without re-running AI on it) — a real interface/schema change, not just UI.
**Context:** Screen 5 (`lib/ui/features/auth/views/signup_documents_screen.dart`) currently captures a single front-side photo per document, matching what the storage/orchestrator layer can persist today. Building a fake "back" capture UI with nowhere to persist it would be worse than not having it.
**Depends on:** New `identity_doc_back_path` (or similar) column + `IFileStorageRepository`/`ISignupOrchestrator` method additions.

## Map picker for Screen 4 location (V2)
**What:** Replace the GPS-detect + free-text address field on the signup role-details screen with a draggable-pin map sheet (Google Maps, already a dependency).
**Why:** `docs/design/partner-signup-verification-research-plan.md` Section 4.1 — competitors (Careem, Talabat) let users see and adjust the pin rather than trusting a geocoded string.
**Pros:** More accurate facility/work-area locations; fewer support tickets from bad reverse-geocode results.
**Cons:** New full-screen map UI + sheet, more surface area to test; not required for Screen 5 (document verification) which was this pass's focus.
**Context:** Deferred from the same implementation pass that shipped Screen 5 document verification, to keep that change reviewable on its own.
**Depends on:** None — can be picked up independently.

## Reuse waste-type chip selector in profile settings (V2)
**What:** Make the signup waste-type chip multi-select (`_WasteTypeChips` in `signup_role_details_screen.dart`) reusable from a profile/settings screen, with role-aware default ordering (a recycling company sees what it's licensed to *process* first; a supplier sees what it *generates* first).
**Why:** `docs/design/partner-signup-verification-research-plan.md` Section 4.2 — Careem treats working-area/category as an ongoing preference, not a one-time signup field; Dwaar currently only lets you set it once at signup.
**Pros:** Users can correct/update categories without contacting support; matches competitor UX.
**Cons:** Requires extracting `_WasteTypeChips` into a shared widget and adding a profile-settings entry point + backend update call — no such settings screen exists yet for this field.
**Context:** Deferred from the same pass that shipped Screen 5 document verification.
**Depends on:** A profile/account-settings screen to host it (may not exist yet — check `lib/ui/features/home/*/tabs/*_profile_tab.dart` first).

## Supplier weight confirmation (V2)
**What:** Supplier sees the driver's entered pickup weight and can accept or dispute it before the order moves to `inTransit`.
**Why:** Prevents weight disputes from being invisible until delivery. Currently driver self-reports, no cross-check.
**Pros:** Creates an audit trail for every weight — makes the ops manager's job easier when billing disputes arise.
**Cons:** Adds a supplier interaction step to an already multi-step flow. Requires UI on the supplier side and a new order status or confirmation field.
**Context:** V1 ships with driver-only weight capture. Add this when field data shows weight disputes as a recurring ops manager complaint.
**Depends on:** V1 proof loop shipped and validated by a real recycling company.

## Screen reader / Semantics labels for proof screens (design debt)
**What:** Add Flutter `Semantics` wrappers to PickupProofView weight field, photo capture container, and ops map driver chips.
**Why:** Proof screens currently have no screen reader support. TalkBack users cannot interact with the proof flow.
**Pros:** Accessibility compliance; future-proofs the feature; low effort once screens are built.
**Cons:** Adds ~10 lines of Semantics wrapping per screen; negligible risk.
**Context:** V1 target users (drivers in Jordan, ops managers) are unlikely to use TalkBack. Add after V1 ships and the screens are stable.
**Depends on:** PickupProofView and OrderCompletionSection weight field implemented first.

## Weight vs WeightCategory variance check (V2)
**What:** When driver enters `pickup_proof_weight_kg`, cross-check it against the order's `WeightCategory` enum and log a discrepancy if wildly inconsistent (e.g. driver enters 0.1 kg for a `heavy` order).
**Why:** V1 ships with driver-only weight entry and no validation against the declared category. Fraudulent or mistaken entries are invisible to the ops manager until billing disputes arise.
**Pros:** Creates an automatic audit signal for the ops manager; pairs with the existing `weightVarianceFlag` field already on the Order model.
**Cons:** Requires defining threshold rules per WeightCategory (how many kg = "wildly wrong"?). Risk of false positives if category was set incorrectly by the supplier.
**Context:** Flagged by outside voice during eng review run 2. V1 deliberately defers this — the `weightVarianceFlag` field already exists on Order, so the infrastructure is ready. Add after V1 ships and real weight data is available to calibrate thresholds.
**Depends on:** V1 proof loop shipped and validated; real weight data from field use.

## Dashboard adapter placeholders — order address + driver location (DX review finding)
**What:** `src/lib/adapters.ts` has three hardcoded values: `order.address` always returns `"Jordan"` (PostGIS geography not easily parsed in TS), idle driver `lat/lng` defaults to Amman city centre (31.963, 35.910), and `idleSince` is always exactly 5 minutes ago.
**Why:** Ops manager sees all orders at a single map point and idle drivers clustered at one location. Misleading at scale.
**Pros:** Correct order and driver positions on the live map; accurate idle time indicators.
**Cons:** Requires adding plain `pickup_lat FLOAT`, `pickup_lng FLOAT`, `pickup_address TEXT` columns to `orders` via a new Supabase migration, updating `order_supabase_ext.dart` to write them, and updating the dashboard adapter to read them.
**Context:** Root cause is that Supabase stores `pickup_location` as PostGIS `geography(Point)`, which the JS client receives as a WKB hex string. Until a plain-column alternative exists, the placeholder is unavoidable.
**Depends on:** New migration + order model update + adapter update.

## useRiders hook — N+1 Realtime re-fetch at scale (DX review finding)
**What:** `src/hooks/useRiders.ts` re-fetches ALL drivers from Supabase on every Realtime event from `driver_locations` or `orders` tables. With 10 drivers updating every 30s, this is 20+ full reads/min. At 50+ drivers this degrades.
**Why:** Full re-fetch is simple and correct today. Incremental merge using the Realtime event payload would reduce load to one row per event.
**Pros:** Sustains real-time performance at scale without increasing Supabase read load.
**Cons:** Merging Realtime payload into React state immutably requires careful identity matching; adds ~30 lines of hook complexity.
**Context:** Acceptable at current Dwaar scale (2-10 drivers). Add when driver count exceeds 30 and re-fetch latency becomes noticeable.
**Depends on:** Validated at scale; no rush.

## ~~Timestamp read-back from Supabase~~ ✅ DONE
`arrivedAtPickupAt` and `arrivedAtDropoffAt` now parsed in `orderFromSupabaseJson`.
Fixed in `lib/data/models/order_supabase_ext.dart` (2 lines added after proof loop PR).
