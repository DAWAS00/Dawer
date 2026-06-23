# TODOS

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

## ~~Timestamp read-back from Supabase~~ ✅ DONE
`arrivedAtPickupAt` and `arrivedAtDropoffAt` now parsed in `orderFromSupabaseJson`.
Fixed in `lib/data/models/order_supabase_ext.dart` (2 lines added after proof loop PR).
