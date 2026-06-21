
# Implementation Prompt — Collection Sale Lifecycle

> **What to give the AI:** Paste the full block under each Phase section into Claude (or your AI of choice). Each phase is self-contained. Do them in order — each one builds on the previous. The Design System block at the top must be included with every prompt.

---

## Design System Block
> Paste this at the top of every prompt that touches UI.

```
DESIGN SYSTEM — Dawer (دوّر):
- Direction: RTL (Arabic first). All text right-aligned by default.
- Primary Green: #14401F (dark) / #1E5C35 (main) / #06402B (deep)
- Accent Amber: #C8860A | Amber Container: #FEF3C7
- Blue (inTransit): #1E40AF | Blue Container: #DBEAFE
- Background: #F4F6F5 | Surface: #FFFFFF | Surface Low: #EBF4EE
- Text Primary: #002819 | Text Body: #404943 | Text Muted: #717973 | Text Disabled: #9CA3AF
- Status colors:
    pending   → bg #FEF3C7  text #C8860A
    accepted  → bg #D1FAE5  text #1E5C35
    inTransit → bg #DBEAFE  text #1E40AF
    completed → bg #DCFCE7  text #166534
    cancelled → bg #FEE2E2  text #991B1B
- Fonts: Cairo (Arabic, weight 400/600/700) + DM Sans (English/numbers, weight 400/500/700)
- Buttons: 48px height, 12px border-radius, ElevatedButton elevation 0
- Cards: 16px radius, white bg, BoxShadow(color: black 4% opacity, blurRadius 8, offset Offset(0,2))
- AppColors token file: lib/core/constants/app_colors.dart
- Google Fonts used at runtime — do NOT use system fonts
```

---

## Context Block
> Paste this in every prompt so the AI understands the codebase.

```
PROJECT: Dawer (دوّر) — Flutter waste-recycling logistics app. Arabic RTL. Jordan.
Three user roles: Driver (السائق), Supplier (المورد), Recycling Company (شركة التدوير).

ARCHITECTURE: Feature-scoped MVVM with Provider.
- AppOrderStore (ChangeNotifier, provided at app root) = single source of truth for all orders.
- Each role has its own ViewModel that delegates to the store.
- All data is mock (no backend). No HTTP calls.

RELEVANT MODELS:
  enum OrderType    { pickup, collection, collectionSale }
  enum OrderStatus  { pending, accepted, inTransit, completed, cancelled }
  enum PaymentModel { perKg, flatFee }
  enum CollectionDeliveryMethod { selfDelivery, assignRider }
  enum CollectionTransactionType { donate, sell }

Order fields relevant to this feature:
  String id
  OrderType type
  OrderStatus status
  String? supplierName        ← stores the acceptor's name on collectionSale orders
  String? linkedJobId         ← collectionSale links back to its parent collection job
  PaymentModel? paymentModel
  double? pricePerKg
  double? itemPrice
  double? minQuantityKg
  double? weightKg            ← actual weight delivered (filled on completion)
  String? jobDescription
  CollectionDeliveryMethod? collectionDeliveryMethod
  CollectionTransactionType? collectionTransactionType
  DateTime createdAt
  DateTime? acceptedAt
  DateTime? inTransitAt       ← when driver started the collection trip
  DateTime? completedAt       ← when driver confirmed delivery

EXISTING store methods (do NOT recreate these):
  createCollectionSale(jobId, acceptorName, ...)     → creates collectionSale
  createCollectionJob(...)                           → recycling co posts a job
  hasAcceptedJob(jobId, acceptorName)                → bool
  collectionSalesFor(acceptorName)                   → List<Order>

KEY FILES:
  lib/data/services/app_order_store.dart
  lib/data/models/order.dart
  lib/ui/features/home/shared/widgets/collection_sale_card.dart
  lib/ui/features/home/shared/views/collection_sale_detail_view.dart
  lib/ui/features/home/driver/tabs/driver_orders_tab.dart
  lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart
  lib/ui/features/home/supplier/viewmodels/base_supplier_viewmodel.dart
  lib/ui/features/home/supplier/tabs/supplier_orders_tab.dart
  lib/ui/features/home/recycling/tabs/recycling_home_tab.dart
```

---

## Full Lifecycle Overview

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                COLLECTION SALE FULL LIFECYCLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Recycling Co posts collection job]
        OrderType.collection | status: pending
        visible in marketplace → segment "وظائف التجميع"

        ↓  User (driver/supplier) taps "قبول الوظيفة"
           AcceptCollectionJobSheet shown
           User picks: delivery method + transaction type

[AppOrderStore.createCollectionSale() called]
        OrderType.collectionSale | status: pending
        linkedJobId = parent job's id
        supplierName = acceptor's name
        collectionDeliveryMethod = selfDelivery | assignRider
        collectionTransactionType = donate | sell

        ↓  User taps "بدء التجميع" on CollectionSaleCard
           [MISSING — Phase 1 to implement]

[AppOrderStore.markCollectionSaleInTransit() called]
        OrderType.collectionSale | status: inTransit
        inTransitAt = DateTime.now()
        → Company sees this sale as active / incoming

        ↓  User taps "تأكيد التسليم" on CollectionSaleCard
           Confirmation dialog — enter actual weight if per-kg
           [MISSING — Phase 2 to implement]

[AppOrderStore.completeCollectionSale() called]
        OrderType.collectionSale | status: completed
        completedAt = DateTime.now()
        weightKg = actualWeight (optional, per-kg jobs)
        → If sell transaction: earnings calculated here
        → Company sees delivery confirmed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PARALLEL: cancel path (only when status == pending)

        ↓  User taps "إلغاء الالتزام"
           Confirmation dialog shown

[AppOrderStore.cancelCollectionSale() called]
        OrderType.collectionSale | status: cancelled
        Once inTransit or completed → cancellation BLOCKED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHO SEES WHAT:
  Driver/Supplier     → sees their own collectionSale card in Orders tab
  Recycling Company   → sees acceptor count + statuses on their job card
```

---

## Phase 1 — Data Layer: Store Methods

### Prompt 1-A — `markCollectionSaleInTransit`

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add `markCollectionSaleInTransit` to AppOrderStore.

File to edit: lib/data/services/app_order_store.dart

Add this method in the "Company actions" section, after `createCollectionSale`:

/// Driver/supplier signals they have collected the material and are heading to
/// the recycling facility. Moves collectionSale from pending → inTransit.
/// Returns an error string on failure, null on success.
String? markCollectionSaleInTransit(String saleId) {
  final idx = _orders.indexWhere(
    (o) => o.id == saleId && o.type == OrderType.collectionSale,
  );
  if (idx == -1) return 'الالتزام غير موجود';
  final current = _orders[idx];
  if (current.status != OrderStatus.pending) {
    return 'لا يمكن تغيير الحالة — الالتزام ليس في حالة انتظار';
  }
  _orders[idx] = current.copyWith(
    status: OrderStatus.inTransit,
    inTransitAt: DateTime.now(),
  );
  notifyListeners();
  return null;
}

RULES:
- Only transitions from pending → inTransit. Any other status returns an error string.
- Uses existing inTransitAt field on Order (already exists).
- Do NOT create new Order fields.
- Do NOT change any other methods.
```

### Prompt 1-B — `completeCollectionSale`

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add `completeCollectionSale` to AppOrderStore.

File to edit: lib/data/services/app_order_store.dart

Add this method after `markCollectionSaleInTransit`:

/// Driver/supplier confirms delivery to the recycling facility.
/// [actualWeightKg] is optional — used when paymentModel == perKg so the
/// final earnings can be calculated later.
/// Returns an error string on failure, null on success.
String? completeCollectionSale(String saleId, {double? actualWeightKg}) {
  final idx = _orders.indexWhere(
    (o) => o.id == saleId && o.type == OrderType.collectionSale,
  );
  if (idx == -1) return 'الالتزام غير موجود';
  final current = _orders[idx];
  if (current.status != OrderStatus.inTransit) {
    return 'يجب بدء التجميع أولاً قبل تأكيد التسليم';
  }
  _orders[idx] = current.copyWith(
    status: OrderStatus.completed,
    completedAt: DateTime.now(),
    weightKg: actualWeightKg ?? current.weightKg,
  );
  notifyListeners();
  return null;
}

RULES:
- Only transitions from inTransit → completed. Any other status returns error.
- weightKg is only overwritten if actualWeightKg is provided.
- completedAt field already exists on Order model. Use it.
- Do NOT change any other methods.
```

### Prompt 1-C — `cancelCollectionSale` (hardened)

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add or replace `cancelCollectionSale` in AppOrderStore.

File to edit: lib/data/services/app_order_store.dart

Check if a method named cancelCollectionSale or anything cancelling collectionSale
already exists. If it does, REPLACE it. If not, ADD it after completeCollectionSale.

/// Cancel a collection sale commitment. Only allowed when status == pending.
/// Once inTransit or completed, cancellation is blocked — the user must
/// contact the company directly.
/// Returns an error string on failure, null on success.
String? cancelCollectionSale(String saleId) {
  final idx = _orders.indexWhere(
    (o) => o.id == saleId && o.type == OrderType.collectionSale,
  );
  if (idx == -1) return 'الالتزام غير موجود';
  final status = _orders[idx].status;
  if (status == OrderStatus.inTransit) {
    return 'لا يمكن الإلغاء بعد بدء التجميع — تواصل مع الشركة مباشرة';
  }
  if (status == OrderStatus.completed) {
    return 'لا يمكن إلغاء التزام مكتمل';
  }
  if (status == OrderStatus.cancelled) {
    return 'هذا الالتزام ملغى مسبقاً';
  }
  _orders[idx] = _orders[idx].copyWith(status: OrderStatus.cancelled);
  notifyListeners();
  return null;
}

RULES:
- pending → cancelled ✓
- inTransit → error (cannot cancel)
- completed → error (cannot cancel)
- cancelled → error (already cancelled)
```

### Prompt 1-D — `salesForCompanyJobs` getter

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add `salesForCompanyJobs` getter to AppOrderStore.

File to edit: lib/data/services/app_order_store.dart

Add this in the "Recycling Company views" section, after the companyJobs getter:

/// All collectionSale commitments linked to jobs owned by [companyName].
/// Used by RecyclingHomeTab to show acceptor count + status per job.
List<Order> salesForCompanyJobs(String companyName) {
  final companyJobIds = _orders
      .where(
        (o) => o.type == OrderType.collection && o.supplierName == companyName,
      )
      .map((o) => o.id)
      .toSet();

  return _orders
      .where(
        (o) =>
            o.type == OrderType.collectionSale &&
            o.linkedJobId != null &&
            companyJobIds.contains(o.linkedJobId),
      )
      .toList();
}

RULES:
- Returns ALL sales for the company's jobs (all statuses — pending, inTransit, completed, cancelled).
- Caller filters by status if needed.
- Do NOT change any other method.
```

---

## Phase 2 — ViewModel Layer

### Prompt 2-A — DriverHomeViewModel

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add lifecycle delegates to DriverHomeViewModel.

File to edit: lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart

The ViewModel already has a reference to AppOrderStore as _store (or store).
Add these three methods that delegate directly to the store:

/// Move a collectionSale to inTransit. Returns error string or null.
String? startCollectionSaleTransit(String saleId) =>
    _store.markCollectionSaleInTransit(saleId);

/// Complete a collectionSale. [actualWeightKg] used for per-kg payment calculation.
String? completeCollectionSale(String saleId, {double? actualWeightKg}) =>
    _store.completeCollectionSale(saleId, actualWeightKg: actualWeightKg);

/// Cancel a pending collectionSale. Returns error string or null.
String? cancelCollectionSale(String saleId) =>
    _store.cancelCollectionSale(saleId);

RULES:
- Pure delegation. No extra logic in the ViewModel.
- Do not change the constructor or any existing methods.
- If cancelCollectionSale already exists in the ViewModel, update it to delegate
  to the new _store.cancelCollectionSale() instead of _store.cancelOrder().
```

### Prompt 2-B — BaseSupplierViewModel

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add lifecycle delegates to BaseSupplierViewModel.

File to edit: lib/ui/features/home/supplier/viewmodels/base_supplier_viewmodel.dart

This abstract base is shared by SupplierHomeViewModel and IndividualSupplierViewModel.
Add the same three methods as the DriverHomeViewModel:

/// Move a collectionSale to inTransit. Returns error string or null.
String? startCollectionSaleTransit(String saleId) =>
    _store.markCollectionSaleInTransit(saleId);

/// Complete a collectionSale.
String? completeCollectionSale(String saleId, {double? actualWeightKg}) =>
    _store.completeCollectionSale(saleId, actualWeightKg: actualWeightKg);

/// Cancel a pending collectionSale.
String? cancelCollectionSale(String saleId) =>
    _store.cancelCollectionSale(saleId);

RULES:
- Add to the base class, NOT to the concrete subclasses.
- Both SupplierHomeViewModel and IndividualSupplierViewModel will inherit them automatically.
- Do not change the constructor or any existing methods.
```

### Prompt 2-C — RecyclingHomeViewModel

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add acceptor visibility getter to RecyclingHomeViewModel.

File to edit: lib/ui/features/home/recycling/viewmodels/recycling_home_viewmodel.dart

The ViewModel already delegates to AppOrderStore as _store.
Add one getter:

/// All collectionSale orders linked to this company's jobs.
/// Used to show who accepted which job and their status.
List<Order> get jobSales => _store.salesForCompanyJobs(_user.name);

Also add a helper method for the UI to get sales for a specific job:

/// Sales for one specific job by job ID.
List<Order> salesForJob(String jobId) =>
    jobSales.where((s) => s.linkedJobId == jobId).toList();

RULES:
- _user.name must match the company name used when creating jobs.
  Check how _user is initialized in this ViewModel and use the same name field.
- Do not change the constructor or any existing methods.
```

---

## Phase 3 — CollectionSaleCard UI

### Prompt 3-A — Action buttons for each state

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Add action buttons to CollectionSaleCard for the inTransit/completed lifecycle.

File to edit: lib/ui/features/home/shared/widgets/collection_sale_card.dart

CURRENT STATE:
The card has one optional callback: VoidCallback? onCancel
It shows the cancel button only when status == pending.

REQUIRED CHANGES:

1. Add two new optional callbacks to the widget class:
   VoidCallback? onStartTransit    // pending → inTransit
   VoidCallback? onComplete        // inTransit → completed

2. Replace the current action area at the bottom of the card with this logic:

   When status == pending:
     Show TWO buttons side by side (Row, 10px gap):
     LEFT: "بدء التجميع" — ElevatedButton, #14401F bg, white text, truck icon
     RIGHT: "إلغاء الالتزام" — OutlinedButton, red border #DC2626, red text

   When status == inTransit:
     Show ONE full-width button:
     "تأكيد التسليم" — ElevatedButton, #1E40AF bg, white text, check_circle icon

   When status == completed or cancelled:
     Show nothing (no action buttons).

3. Button specs:
   Height: 40px
   Border radius: 12px
   Font: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)
   Icons: local_shipping_rounded (بدء التجميع) | check_circle_rounded (تأكيد التسليم)
   Both buttons: elevation 0

4. The cancel button should open the EXISTING _showCancelDialog — do not change that dialog.
   The "بدء التجميع" button calls onStartTransit directly (no dialog needed).
   The "تأكيد التسليم" button calls onComplete directly — the parent widget handles the dialog.

RULES:
- Do not change the card's top section, status badge, waste chips, or pricing row.
- Do not remove the existing onCancel callback — keep it for backwards compatibility.
- All existing tap → CollectionSaleDetailView navigation stays unchanged.
- The card is a StatelessWidget — keep it stateless.
```

---

## Phase 4 — DriverOrdersTab Wiring

### Prompt 4-A — Wire callbacks + completion dialog

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Wire the new CollectionSaleCard callbacks in DriverOrdersTab and add the completion dialog.

File to edit: lib/ui/features/home/driver/tabs/driver_orders_tab.dart

CONTEXT:
DriverOrdersTab already receives a list of collectionSaleOrders and displays
CollectionSaleCard for each. Currently only onCancel is wired.

REQUIRED CHANGES:

1. Add two new callback props to DriverOrdersTab:
   final void Function(String saleId)? onStartTransit;
   final void Function(String saleId, {double? actualWeightKg})? onComplete;

2. Pass them into each CollectionSaleCard:
   CollectionSaleCard(
     sale: sale,
     onCancel: (saleId) => onCancelSale?.call(saleId),
     onStartTransit: onStartTransit == null ? null : () => _handleStartTransit(context, sale),
     onComplete: onComplete == null ? null : () => _showCompleteDialog(context, sale),
   )

3. Add _handleStartTransit — calls the callback and shows a SnackBar on error:
   void _handleStartTransit(BuildContext context, Order sale) {
     // calls onStartTransit!(sale.id)
     // the ViewModel returns an error string — show in SnackBar if not null
     // SnackBar: bg #991B1B, white Cairo text
   }

4. Add _showCompleteDialog — confirmation dialog, weight input if per-kg:

   Dialog structure:
   - Title "تأكيد التسليم" Cairo Bold, right-aligned
   - Body "هل وصلت إلى المنشأة وسلّمت المواد؟" Cairo, right-aligned
   - If sale.paymentModel == PaymentModel.perKg:
       Show a TextField below the body text:
       Label "الوزن الفعلي (كغ) — اختياري" Cairo
       keyboardType: TextInputType.numberWithOptions(decimal: true)
       textAlign: TextAlign.right
   - Cancel button: TextButton "إلغاء" Cairo
   - Confirm button: ElevatedButton "تأكيد" Cairo Bold, #1E40AF bg, white text
   - On confirm: call onComplete!(sale.id, actualWeightKg: weight)
     (weight is null if field empty or not shown)

5. Update the DriverHomeView that builds DriverOrdersTab to pass the new callbacks
   sourced from the DriverHomeViewModel (vm.startCollectionSaleTransit, vm.completeCollectionSale).

RULES:
- DriverOrdersTab stays a StatelessWidget — dialogs use showDialog, no setState.
- The TextEditingController for weight must be created inside the dialog builder
  (StatefulBuilder or use a local variable — don't store it in the widget).
- All error handling via SnackBar, not AlertDialog.
```

---

## Phase 5 — SupplierOrdersTab Wiring

### Prompt 5 — Wire callbacks in SupplierOrdersTab

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Wire CollectionSaleCard callbacks in SupplierOrdersTab.

File to edit: lib/ui/features/home/supplier/tabs/supplier_orders_tab.dart

CONTEXT:
SupplierOrdersTab shows CollectionSaleCard for collectionSale orders.
Currently only onCancel is wired. The ViewModel for supplier tabs is
accessed via context.watch<SupplierHomeViewModel>() or context.watch<IndividualSupplierViewModel>().
Both extend BaseSupplierViewModel which now has startCollectionSaleTransit and completeCollectionSale.

REQUIRED CHANGES:
Identical pattern to DriverOrdersTab (Phase 4) but adapted for the supplier tab:

1. Wire onStartTransit → calls vm.startCollectionSaleTransit(sale.id)
   On error → SnackBar #991B1B

2. Wire onComplete → shows same _showCompleteDialog (copy the implementation from DriverOrdersTab —
   the logic is identical, weight input appears for per-kg jobs)
   On confirm → calls vm.completeCollectionSale(sale.id, actualWeightKg: weight)

3. Wire onCancel → calls vm.cancelCollectionSale(sale.id)
   On error → SnackBar #991B1B (e.g. "لا يمكن الإلغاء بعد بدء التجميع")

RULES:
- Same UI/UX as the driver tab — identical dialogs and SnackBar colors.
- Do not change the card list layout or section headers.
- Do not duplicate the dialog code if it can be extracted to a shared function — 
  but don't create a new file just for this; a private top-level function in the
  same file is fine.
```

---

## Phase 6 — RecyclingHomeTab: Acceptor Visibility

### Prompt 6 — Acceptor count row on job cards

```
[DESIGN SYSTEM + CONTEXT BLOCKS above]

TASK: Show acceptor count and status summary on each collection job card in RecyclingHomeTab.

File to edit: lib/ui/features/home/recycling/tabs/recycling_home_tab.dart

CONTEXT:
RecyclingHomeTab shows the company's active collection jobs (OrderType.collection).
Each job card currently shows: waste types, location, payment model, pricing.
The ViewModel now has jobSales getter and salesForJob(jobId) method.

REQUIRED CHANGES:

Add a small "acceptor summary row" at the bottom of each job card.
The row is only shown if salesForJob(jobId).isNotEmpty.

Layout spec (inside the existing job card, below pricing):
  Thin divider (1px #E2E8F0) — 8px margin top
  Row, right-aligned:
    Icon: group_rounded, size 14, color #9CA3AF
    Text "الملتزمون:" Cairo Bold 12px #404943, 4px gap after icon
    Then a Wrap of small status chips, 4px spacing:
      One chip per sale (or one chip per status group if more than 3 sales)
      Chip: 20px height, 8px h-padding, 6px radius
      Color matches status colors from design system above
      Text: sale.status.label (use existing StatusLabel extension)

  If no sales (empty): do NOT show the divider or row.
  Maximum: show first 3 individual chips. If more → show count: "+٢ آخرون"

Example rendering:
  [معلق] [في الطريق] → two chips
  [مكتمل] [مكتمل] [+١ آخر] → two chips + overflow

RULES:
- Access sales via: final sales = vm.salesForJob(job.id);
- vm is the RecyclingHomeViewModel accessed via context.watch<RecyclingHomeViewModel>()
- Do not add a new screen or navigation — this is inline on the existing card.
- Do not change the existing job card structure above the divider.
- Use existing AppColors tokens where possible. Fallback to hex only if token missing.
```

---

## Phase 7 — Tests

### Prompt 7 — Unit tests for new store methods

```
[CONTEXT BLOCK above — no UI design system needed for tests]

TASK: Add unit tests for the three new AppOrderStore methods.

File to edit: test/data/app_order_store_test.dart

Add a new test group after the existing groups:

group('AppOrderStore – collection sale lifecycle', () {

  // Helper: create a store with a seed collection job + accepted sale
  AppOrderStore storeWithSale() {
    final s = AppOrderStore();
    // create a collection job
    s.createCollectionJob(
      wasteTypes: [WasteType.plastic],
      pickupAddress: 'منطقة الرابية',
      companyName: 'شركة اختبار',
    );
    final jobId = s.pendingCollectionJobs.first.id;
    // create a sale (acceptor commits to the job)
    s.createCollectionSale(
      jobId: jobId,
      acceptorName: 'مورد اختبار',
      collectionArea: 'منطقة الرابية',
      wasteTypes: [WasteType.plastic],
    );
    return s;
  }

  test('markCollectionSaleInTransit succeeds from pending', () { ... });
  test('markCollectionSaleInTransit fails if already inTransit', () { ... });
  test('markCollectionSaleInTransit fails for wrong id', () { ... });

  test('completeCollectionSale succeeds from inTransit', () { ... });
  test('completeCollectionSale fails if still pending', () { ... });
  test('completeCollectionSale stores actualWeightKg', () { ... });

  test('cancelCollectionSale succeeds from pending', () { ... });
  test('cancelCollectionSale blocked when inTransit', () { ... });
  test('cancelCollectionSale blocked when completed', () { ... });

  test('salesForCompanyJobs returns only sales for that company', () { ... });
  test('salesForCompanyJobs returns empty for company with no jobs', () { ... });
});

RULES:
- Use AppOrderStore() directly — no mocks.
- Assert on: return value (null = success, String = error), order status after call,
  and timestamp fields (inTransitAt, completedAt) are non-null after transition.
- Run flutter test after adding — must pass with 0 failures.
```

---

## Validation Checklist

After all phases are implemented, verify:

```
□ flutter analyze → 0 issues
□ flutter test    → all tests pass

DATA LAYER:
□ AppOrderStore has: markCollectionSaleInTransit, completeCollectionSale,
  cancelCollectionSale, salesForCompanyJobs
□ markCollectionSaleInTransit: pending → inTransit, sets inTransitAt
□ completeCollectionSale: inTransit → completed, sets completedAt, stores weightKg
□ cancelCollectionSale: pending → cancelled, blocks inTransit/completed
□ salesForCompanyJobs: returns all sales for company's jobs across all statuses

VIEWMODEL LAYER:
□ DriverHomeViewModel: startCollectionSaleTransit, completeCollectionSale, cancelCollectionSale
□ BaseSupplierViewModel: same 3 methods (both supplier VMs inherit them)
□ RecyclingHomeViewModel: jobSales getter + salesForJob(jobId) method

UI LAYER:
□ CollectionSaleCard when pending: shows "بدء التجميع" + "إلغاء الالتزام" side by side
□ CollectionSaleCard when inTransit: shows "تأكيد التسليم" full-width, no cancel
□ CollectionSaleCard when completed/cancelled: no action buttons
□ DriverOrdersTab: all 3 callbacks wired, completion dialog with optional weight input
□ SupplierOrdersTab: same as above
□ RecyclingHomeTab: acceptor row appears under job cards, correct status chips
□ Cancel after inTransit shows error SnackBar (does not change status)

FULL FLOW SMOKE TEST:
□ As driver: accept job → CollectionSaleCard appears in orders tab as pending
□ As driver: tap "بدء التجميع" → card updates to inTransit (blue badge)
□ As driver: tap "تأكيد التسليم" → confirm dialog → card updates to completed (green badge)
□ As company: job card shows acceptor chips after driver accepts
□ As company: chip updates from معلق → في الطريق → مكتمل as driver progresses
□ As driver: attempt cancel after "بدء التجميع" → SnackBar error shown, status unchanged
```

---

## Related
- [[Projects/Dawer/Logic/Collection Sale Lifecycle]]
- [[Projects/Dawer/Daily Tasks]]
- [[Projects/Dawer/Reports/2026-04-14]]
- [[Projects/Dawer/Reports/2026-04-15]]
- [[Projects/Dawer/Architecture]]
