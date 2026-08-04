# Ghuson — Financial Model & Money Rules

**Everything money-related in one place:** the in-app ledger design, the pricing engine, the
credits system, and the business-level financial model. Read this before implementing any
screen or table that touches JOD.

**Not financial advice.** Projections here are the team's own planning models, not audited
statements. Ghuson is **pre-revenue** — no actuals exist as of 2026-07-30.

**Evidence labels** (the project's own convention, reused here):
`Confirmed` = in the codebase or a cited source · `Approved requirement` = a fixed rule ·
`Assumption` = placeholder to make the math complete · `Open decision` = must be resolved.

---

## 1. Money principles (Approved requirements)

1. **No payment gateway.** Money is **ledger-only** — balances, holds, and transactions are
   recorded; no funds actually move through the app. A payment-provider interface may be
   defined but stays unimplemented. Settlement happens outside the app during the POC.
2. **The server owns every number.** Balances, platform cut, payouts, penalties, and credits
   are computed and written by Postgres RPCs / Edge Functions. The client may *display* a
   calculation for preview, but the server's result always wins. Never let the app write
   `driver_wallet.balance`.
3. **Atomic writes.** A ledger row and the cached balance update happen in one transaction,
   in one SQL function. Never two client calls.
4. **JOD has 3 decimals (fils).** Round to 3 decimal places, not 2. The legacy pricing engine
   uses `_round3()` — keep that. Money is `numeric`, never float, in the database. In Dart,
   prefer integer fils (1 JOD = 1000 fils) for arithmetic and format at the edge.
5. **Tabular figures** for every monetary value in the UI (brand requirement).
6. **Every amount is auditable** — each ledger row carries type, amount, order/reservation
   reference, actor, note, and timestamp. Manual/rescue work is logged as cost, never hidden.

---

## 2. In-app ledger data model

Per the FigJam contract + legacy migrations. All amounts `numeric`, currency JOD.

| Table | Key columns | Purpose |
|---|---|---|
| `driver_wallet` | `driver_id` PK, `balance`, `held_amount` | One row per driver. `balance` is a **cached** total; ledger is the truth |
| `wallet_transactions` | `id`, `driver_id`, `order_id`, `type`, `amount`, `note` | Types: `hold` · `release` · `refund` · `penalty` |
| `transactions` | `id`, `order_id`, `driver_id`, `total_jd`, `platform_cut_jd`, `driver_payout_jd`, `status`, `needs_manual_review` | Per-order settlement record. Status: `pending` · `paid` · `failed` |
| `escrow_wallets` *(reservations)* | `user_id`, `balance` | Negative balances allowed (MVP) — a penalty can push a user negative |
| `escrow_ledger` | `user_id`, `reservation_id`, `type`, `amount` | Types: `penalty_debit` · `penalty_credit` |
| `green_credit_entries` | `user_id`, `order_id`, `credits`, `reason`, `created_at` | Credits ledger; `profiles.green_points` is a cached total |
| `pricing_rules` | `waste_type`, `price_per_kg_jd`, `zone_id` | Admin-managed price table per material per zone |
| `orders` | `reward_jd`, `estimated_weight_kg`, `actual_weight_kg`, `weight_variance_flag` | Order-level money + the variance flag |
| `invoice_items` *(legacy model)* | `name`, `quantity`, `price`, `total = quantity × price` | Itemized invoice breakdown |

**Wallet RPCs** (`Confirmed`, legacy `20260522_wallet_functions.sql` — carry forward):

| Function | Effect |
|---|---|
| `driver_wallet_hold(order, amount)` | `held_amount += amount`; inserts `hold` row (note: "قبول الطلب") |
| `driver_wallet_release(order, amount)` | `held_amount -= amount` (floored at 0), `balance += amount`; inserts `release` row |
| `auto_credit_driver_compensation()` | Trigger: on cancel with `driver_compensation_amount` set, releases the hold and credits compensation |

---

## 3. Order money lifecycle

```
create      → reward_jd computed server-side from the pricing engine (§4)
accept      → driver_wallet_hold(expected payout)          [wallet_transactions: hold]
complete    → driver_wallet_release(payout)                [wallet_transactions: release]
            → transactions row (total, platform_cut, driver_payout, status)
            → green_credit_entries row (§5)
cancel      → refund / compensation path                   [refund | penalty]
```

`Approved requirement`: status changes go through `transition_order_status()`; the money side
fires **inside** that transaction, never as a separate client call.

**Weight variance:** if `|actual − estimated| / estimated > 50%`, set
`needs_manual_review = true` and `weight_variance_flag` — recycler-confirmed weight governs
settlement, and an admin reviews before payout is marked `paid`.

---

## 4. Pricing engine (`Confirmed` — legacy `RewardService`)

The legacy app carries **two** fee engines. `RewardService` is the real one; `FeeCalculator`
is a simpler older path. **`Open decision`: keep only one in the rewrite — recommend
`RewardService`, and note the POC may replace both with a flat coordination fee (§7).**

`gross_fee = base_fee(vehicle) + distance_fee + weight_surcharge + material_fee + urgency`
`platform_cut = gross_fee × 10%`
`driver_payout = clamp(gross_fee − platform_cut, base_fee, 50.00)`
All values rounded to 3 decimals.

**Base fee & distance rate by vehicle (JOD, JOD/km)**

| Vehicle | Base | Per km |
|---|---|---|
| Motorcycle | 0.80 | 0.30 |
| Car | 1.20 | 0.45 |
| Pickup *(default)* | 1.50 | 0.60 |
| Van | 2.00 | 0.75 |
| Truck | 3.50 | 1.00 |
| Heavy truck | 5.00 | 1.20 |

**Material rate (JOD/kg, applied to actual weight when available, else estimated)**

| Rate | Materials |
|---|---|
| 0.15 | copper/aluminium |
| 0.10 | electronics |
| 0.08 | chemicals, batteries |
| 0.07 | metal |
| 0.05 | oil |
| 0.03 | plastic, tires |
| 0.02 | paper, textile, wood, rubber, construction, glass, furniture |
| 0.01 | organic |

**Weight surcharge (JOD):** `<5 kg → 0` · `5–20 → 1.5` · `20–100 → 4.0` · `≥100 → 8.0`
**Urgency bonus:** `+0.50` when flagged urgent.
**Platform cut:** `10%` of gross. **Max driver payout:** `50.00` JOD.
**Unknown material rate → `needs_manual_review = true`.**

> `FeeCalculator` (the other engine): `2.00 base + weight surcharge (0/1.5/4/8) + 0.20/km`.
> Kept here only so nobody re-implements it by accident.

---

## 5. Green credits — "خُضَر" (`Confirmed` — `GreenCreditsConfig`)

Non-monetary loyalty points with a defined cash redemption. Brand calls the surfaced metric
**Green Score**; `Open decision`: whether Green Score = credits, or a composite (see §9).

`credits = round((10 + kg × 1.0) × material_multiplier × streak_multiplier)`, clamped 1–9999.

- **Material multiplier:** electronics/batteries 5.0 · chemicals 4.0 · copper-aluminium & oil 3.0 ·
  tires 2.5 · rubber & metal 2.0 · furniture, glass, construction 1.5 · wood & textile 1.2 ·
  plastic, paper, organic 1.0 (highest multiplier across the order's materials wins)
- **Streak multiplier** (consecutive ISO weeks with ≥1 completed order):
  `0–1 → 1.0` · `2–3 → 1.25` · `4–7 → 1.5` · `8+ → 2.0`
- **Levels (cumulative):** Sapling 500 · Tree 2,000 · Forest Guardian 5,000
- **Redemption:** every **500 credits → 5.00 JOD** off the next invoice (≈ 0.01 JOD/credit)

Credits are earned on `completed` orders only, and written server-side as a
`green_credit_entries` row — never incremented from the client.

---

## 6. Reservations / escrow penalty (`Confirmed` — `20260701_reservations_escrow.sql`)

- Seller creates a reservation for a buyer with an `invoice_total` and a countdown deadline.
- **Breach penalty = `round(invoice_total × 0.10, 2)`**, moved from the breaching party to the
  other side via `apply_escrow_penalty()` — a `penalty_debit` + `penalty_credit` ledger pair.
- Trigger: seller cancels an **active** reservation with reason `sold_elsewhere`.
- No penalty when cancelling before the buyer approved, or on a plain expiry cancel.
- Escrow balances may go **negative** (accepted MVP behavior).

---

## 7. Business model — revenue streams

Two generations exist and they disagree. **The POC model governs**; the canvas is investor
framing from the Dawer era.

### 7a. Current: POC / Business Plan v1 (29 Jul 2026)

| Item | Value | Label |
|---|---|---|
| Primary payer, branch 1 | **The business supplier** (not the recycler) | Approved requirement |
| Revenue | Coordination fee per completed pickup **only** | Approved requirement |
| Material resale value | **Excluded** from Ghuson revenue — flows supplier ↔ recycler directly | Approved requirement |
| Price per pickup | 6 JOD conservative / 15 JOD optimistic | **Open decision** — no confirmed price exists |
| Parallel hypotheses | Managed Recovery Route (recycler/sponsor-funded), Branch Launch Sponsorship | Assumption |

### 7b. Superseded: Business Model Canvas (Dawer era)

10% platform fee per delivery (~59% margin on platform revenue) · 5% marketplace commission on
material value · **150 JOD/month** recycler subscription for the sourcing dashboard · Phase-2 AI
agent add-on · pre-seed target **JOD 106,000** (Oasis500 / Flat6Labs) · escrow via CliQ / Zain Cash ·
Y1 ~8,700 orders / ~11,700 JOD → Y2 ~33,800 orders / ~41,600 JOD, break-even ≈ month 24.

> The 10% platform cut in §4 is the *code* implementation of the canvas model. If the POC
> coordination-fee model wins, §4's cut becomes irrelevant for branch 1 — **flag this before
> building any pricing UI.**

---

## 8. Unit economics & Year-1 model

### 8a. Contribution formulas (`Approved requirement`)

```
Order contribution = platform revenue
                   − driver compensation/incentive − supplier subsidy
                   − transaction technology cost − consumables
                   − refund/loss − direct support

Route contribution = total route revenue
                   − driver cost − fuel/transport cost
                   − incentives − direct operations & exception cost
```

### 8b. Cost assumptions (all `Assumption` — placeholders)

| Item | Value |
|---|---|
| Driver compensation | 3.00 JOD / completed pickup |
| Fuel & vehicle | 15.00 JOD / route day (≈10 stops → 1.50/pickup) |
| Technology & consumables | 0.50 JOD / pickup |
| Contingency | 10% of variable cost |
| **Variable cost per pickup** | **≈ 5.50 JOD** |
| Field lead | 400 JOD/mo → 500 from month 7 |
| Hosting (Supabase, maps, SMS) | 150 JOD/mo → 200 from month 9 |
| **Fixed cost per month** | **550 → 700 JOD** |

**Contribution per pickup:** 6.00 − 5.50 = **0.50 JOD** (conservative) · 15.00 − 5.50 = **9.50 JOD** (optimistic).
**Break-even volume:** 700 ÷ 0.50 = **≈1,400 pickups/month** · 700 ÷ 9.50 = **≈74 pickups/month**.

### 8c. Year-1 projection — scenario comparison

Pre-revenue: there are no actuals and no budget. The two pricing scenarios are presented as
the comparison pair, since price is the single open variable driving the outcome.

```
PROJECTED STATEMENT OF OPERATIONS — YEAR 1 (12 months)
Ghuson · pre-revenue · all amounts in JOD · UNAUDITED PROJECTION

                              Conservative   Optimistic     Variance      Variance
                              (6 JOD/pickup) (15 JOD/pickup)   (JOD)         (%)
                              ------------   -------------  ----------    ---------
Completed pickups                      541             541           —          — 

REVENUE
  Coordination fees                3,246.0         8,115.0     4,869.0      +150.0%
                              ------------   -------------  ----------
TOTAL REVENUE                      3,246.0         8,115.0     4,869.0      +150.0%

DIRECT / VARIABLE COSTS
  Driver compensation              ~1,623.0        ~1,623.0           —          — 
  Fuel & transport                   ~811.5          ~811.5           —          — 
  Technology & consumables           ~270.5          ~270.5           —          — 
  Contingency (10%)                  ~270.5          ~270.5           —          — 
                              ------------   -------------  ----------
TOTAL VARIABLE COSTS               ~2,975.5        ~2,975.5           —          — 

CONTRIBUTION                         ~270.5        ~5,139.5     4,869.0    +1,800.0%
  Contribution margin                   8.3%           63.3%                +55.0 pp

OPERATING (FIXED) COSTS
  Field lead                        ~5,400.0        ~5,400.0           —          — 
  Hosting & platform                ~2,000.0        ~2,000.0           —          — 
  Startup / month-1 setup             ~764.4          ~764.4           —          — 
                              ------------   -------------  ----------
TOTAL FIXED COSTS                  ~8,164.4        ~8,164.4           —          — 

                              ------------   -------------  ----------
NET LOSS                          (7,893.9)       (3,024.8)    4,869.0       +61.7%
  Net margin                         (243.2%)         (37.3%)              +205.9 pp

TOTAL COSTS (all in)              11,139.9        11,139.9           —          — 
  Average cost per pickup             20.59           20.59
```

*Variable/fixed split is derived from §8b applied to the plan's monthly totals; the plan itself
publishes only combined monthly cost, revenue, and net — those three tie exactly
(11,139.9 total cost; −7,893.9 / −3,024.8 cumulative net).*

**Monthly ramp** (pickups → revenue): M1 0 → 0 · M2 1 · M3 8 · M4 22 · M5 32 · M6 40 · M7 48 ·
M8 56 · M9 68 · M10 78 · M11 88 · M12 100. Suppliers scale 0 → 32 over the same period.
Optimistic crosses **monthly** break-even in month 10 (78 pickups vs 74 needed); conservative
never does within Year 1.

### 8d. Key metrics

| Metric | Conservative | Optimistic | Change |
|---|---|---|---|
| Revenue per pickup | 6.00 | 15.00 | +9.00 |
| Variable cost per pickup | 5.50 | 5.50 | — |
| Contribution per pickup | 0.50 | 9.50 | +9.00 |
| Total cost per pickup (incl. fixed) | 20.59 | 20.59 | — |
| Contribution margin | 8.3% | 63.3% | +55.0 pp |
| Break-even volume / month | ~1,400 | ~74 | −1,326 |
| Month of first positive month | never (Y1) | month 10 | — |
| Cumulative Y1 net | (7,893.9) | (3,024.8) | +4,869.0 |

### 8e. Material variances & flags

| Item | Variance | Direction | Driver | Action |
|---|---|---|---|---|
| Revenue | +4,869 JOD (+150%) | Favorable | **Price only** — volume identical in both scenarios | Resolve price at Gate A |
| Contribution | +4,869 JOD (+1,800%) | Favorable | Same; variable cost is price-insensitive | — |
| Fixed cost absorption | 8,164 JOD against 541 pickups | Unfavorable | Field lead is 66% of all cost at this volume | Test lower-cost field model or higher density |
| Total cost/pickup 20.59 vs price 6–15 | Structural | Unfavorable | Fixed-cost dominance at pilot scale | Volume, not price alone, closes this |

**The load-bearing finding, stated plainly:** at 6 JOD, per-pickup-only pricing does not become
a viable business at the volume the POC itself targets. Either the price rises toward the
optimistic case, the unit of value shifts (monthly minimum commitment, recycler- or
sponsor-funded route), or fixed cost shrinks relative to volume. This is exactly what the
Gate A pricing test exists to settle.

### 8f. Runway

Founder self-funds the Year-1 shortfall (≈7,894 JOD conservative / ≈3,025 JOD optimistic).
**`Open decision` across three plan revisions: no approved maximum experiment loss (cash
ceiling) has been named.** The POC's own governance rule requires one before Gate B.

---

## 9. Open decisions (must be resolved before building money UI)

1. **Fee model** — POC coordination fee vs the coded 10% platform cut + material-rate engine.
   These are incompatible; §4's engine assumes the latter.
2. **Price per pickup** — no confirmed value anywhere in the project.
3. **Green Score formula** — brand mockups show "92". Is it green credits, kg diverted,
   verification rate, or a composite? Needed before the score appears on any screen.
4. **Cash ceiling** — maximum approved experiment loss.
5. **Two fee engines** — delete `FeeCalculator` or `RewardService`.
6. **Credit redemption in a ledger-only world** — 500 credits → 5 JOD off an invoice implies an
   invoice/settlement path that doesn't exist yet without a gateway.
7. **Payment rail** — CliQ / Zain Cash named in the canvas, unimplemented; POC explicitly
   excludes automated payouts.

---

## 10. Rules for implementing money in the app

- Display-only calculations may run client-side for **preview**, clearly derived from the same
  constants; the server value is authoritative and overwrites any preview on write.
- Never sum ledger rows on the client to display a balance — read the cached balance the
  server maintains, and show the ledger as history.
- Show `held_amount` distinctly from `balance` — drivers must see what's pending vs available.
- Money formatting: 3 decimals, JOD suffix, tabular figures, RTL-safe (numerals stay LTR inside
  Arabic text).
- Any screen showing a payout must also expose the breakdown (base, distance, weight, material,
  urgency, platform cut) — the legacy `RewardBreakdown` model is the right shape.
- `needs_manual_review` orders must render a visible "under review" state, never a payable one.
- No screen may offer a withdrawal/payout action while the ledger-only rule stands.
