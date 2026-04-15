---
goal: Implement Collection Sale Full Lifecycle (pending → inTransit → completed + cancel path)
version: 1.0
date_created: 2026-04-15
last_updated: 2026-04-15
owner: Dawer Team
status: 'In progress'
tags: [feature, collection-sale, lifecycle, mvvm]
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In%20progress-yellow)

Implement the full collection sale lifecycle across data, viewmodel, and UI layers so that drivers/suppliers can progress a collection sale commitment from pending → inTransit → completed, with a hardened cancel path that blocks cancellation once transit has begun. The recycling company gains visibility into acceptor statuses on their job cards.

## 1. Requirements & Constraints

- **REQ-001**: `markCollectionSaleInTransit` transitions pending → inTransit, sets `inTransitAt`
- **REQ-002**: `completeCollectionSale` transitions inTransit → completed, sets `completedAt`, optionally stores `weightKg`
- **REQ-003**: `cancelCollectionSale` only allows pending → cancelled; blocks inTransit/completed
- **REQ-004**: `salesForCompanyJobs` returns all collectionSale orders linked to a company's jobs
- **REQ-005**: Driver and Supplier VMs expose lifecycle delegates
- **REQ-006**: Recycling VM exposes `jobSales` getter and `salesForJob(jobId)` method
- **REQ-007**: CollectionSaleCard shows state-dependent action buttons
- **REQ-008**: Completion dialog includes optional weight input for per-kg payment jobs
- **REQ-009**: Both SupplierHomeView and IndividualSupplierHomeView wire callbacks
- **REQ-010**: RecyclingHomeTab shows acceptor count + status chips on job cards
- **CON-001**: All data is mock — no HTTP, no DB
- **CON-002**: RTL Arabic-first UI with Design System colors/fonts
- **CON-003**: MVVM with Provider — VMs delegate to AppOrderStore (SSOT)
- **PAT-001**: Error returns as `String?` (null = success)
- **PAT-002**: Stateless widgets — dialogs via `showDialog`, no `setState`
- **GUD-001**: Do not create new Order fields — use existing model
- **GUD-002**: Do not change existing methods unless explicitly replacing

## 2. Implementation Steps

### Phase 1 — Data Layer: Store Methods

- GOAL-001: Add 4 lifecycle methods to AppOrderStore

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Add `markCollectionSaleInTransit(saleId)` to `app_order_store.dart` | | |
| TASK-002 | Add `completeCollectionSale(saleId, {actualWeightKg})` to `app_order_store.dart` | | |
| TASK-003 | Add/replace `cancelCollectionSale(saleId)` in `app_order_store.dart` | | |
| TASK-004 | Add `salesForCompanyJobs(companyName)` to `app_order_store.dart` | | |

### Phase 2 — ViewModel Layer

- GOAL-002: Add lifecycle delegates to Driver, BaseSupplier, and Recycling VMs

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Add `startCollectionSaleTransit`, `completeCollectionSale`, update `cancelCollectionSale` in `driver_home_viewmodel.dart` | | |
| TASK-006 | Add 3 lifecycle delegates to `base_supplier_viewmodel.dart` | | |
| TASK-007 | Add `jobSales` getter + `salesForJob(jobId)` to `recycling_home_viewmodel.dart` | | |

### Phase 3 — CollectionSaleCard UI

- GOAL-003: Add state-dependent action buttons to CollectionSaleCard

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-008 | Add `onStartTransit` and `onComplete` callbacks to widget | | |
| TASK-009 | Replace action area: pending shows 2 buttons, inTransit shows 1, completed/cancelled shows none | | |

### Phase 4 — DriverOrdersTab Wiring

- GOAL-004: Wire lifecycle callbacks in DriverOrdersTab and DriverHomeView

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-010 | Add `onStartTransit` / `onComplete` props to `DriverOrdersTab` | | |
| TASK-011 | Add `_handleStartTransit` and `_showCompleteDialog` methods | | |
| TASK-012 | Update `DriverHomeView` to pass VM methods to tab | | |

### Phase 5 — SupplierOrdersTab Wiring

- GOAL-005: Wire lifecycle callbacks in SupplierOrdersTab and both supplier home views

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | Add `onStartTransit` / `onComplete` props to `SupplierOrdersTab` | | |
| TASK-014 | Add `_handleStartTransit` and `_showCompleteDialog` methods | | |
| TASK-015 | Wire callbacks in `SupplierHomeView` | | |
| TASK-016 | Wire callbacks in `IndividualSupplierHomeView` | | |

### Phase 6 — RecyclingHomeTab Acceptor Visibility

- GOAL-006: Show acceptor count and status summary on job cards

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-017 | Add acceptor summary row builder to `recycling_home_tab.dart` | | |
| TASK-018 | Integrate row into job card list with max 3 chips + overflow | | |

### Phase 7 — Tests

- GOAL-007: Unit tests for all new store methods

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-019 | Add 11 unit tests for collection sale lifecycle in `app_order_store_test.dart` | | |
| TASK-020 | Run `flutter analyze` — 0 issues | | |
| TASK-021 | Run `flutter test` — all pass | | |

## 3. Alternatives

- **ALT-001**: Use sealed classes for state transitions instead of String? error returns — rejected to match existing codebase pattern
- **ALT-002**: Extract completion dialog to shared widget file — rejected per Design.md (private function in same file is fine)

## 4. Dependencies

- **DEP-001**: `provider` ^6.1.5+1 (already in pubspec)
- **DEP-002**: `google_fonts` ^8.0.2 (already in pubspec)
- **DEP-003**: Existing `Order` model with `copyWith` (no changes needed)

## 5. Files

- **FILE-001**: `lib/data/services/app_order_store.dart` — 4 new methods
- **FILE-002**: `lib/ui/features/home/driver/viewmodels/driver_home_viewmodel.dart` — 3 method changes
- **FILE-003**: `lib/ui/features/home/supplier/viewmodels/base_supplier_viewmodel.dart` — 3 new methods
- **FILE-004**: `lib/ui/features/home/recycling/viewmodels/recycling_home_viewmodel.dart` — 2 new members
- **FILE-005**: `lib/ui/features/home/shared/widgets/collection_sale_card.dart` — 2 new callbacks + action area rewrite
- **FILE-006**: `lib/ui/features/home/driver/tabs/driver_orders_tab.dart` — new props + dialog
- **FILE-007**: `lib/ui/features/home/driver/driver_home_view.dart` — wire new callbacks
- **FILE-008**: `lib/ui/features/home/supplier/tabs/supplier_orders_tab.dart` — new props + dialog
- **FILE-009**: `lib/ui/features/home/supplier/supplier_home_view.dart` — wire new callbacks
- **FILE-010**: `lib/ui/features/home/supplier/individual_supplier_home_view.dart` — wire new callbacks
- **FILE-011**: `lib/ui/features/home/recycling/tabs/recycling_home_tab.dart` — acceptor row
- **FILE-012**: `test/data/app_order_store_test.dart` — 11 new tests

## 6. Testing

- **TEST-001**: `markCollectionSaleInTransit` succeeds from pending
- **TEST-002**: `markCollectionSaleInTransit` fails if already inTransit
- **TEST-003**: `markCollectionSaleInTransit` fails for wrong id
- **TEST-004**: `completeCollectionSale` succeeds from inTransit
- **TEST-005**: `completeCollectionSale` fails if still pending
- **TEST-006**: `completeCollectionSale` stores actualWeightKg
- **TEST-007**: `cancelCollectionSale` succeeds from pending
- **TEST-008**: `cancelCollectionSale` blocked when inTransit
- **TEST-009**: `cancelCollectionSale` blocked when completed
- **TEST-010**: `salesForCompanyJobs` returns only sales for that company
- **TEST-011**: `salesForCompanyJobs` returns empty for company with no jobs

## 7. Risks & Assumptions

- **RISK-001**: `createCollectionJob` signature may vary — verified compatible with test helper
- **ASSUMPTION-001**: `_user.name` in RecyclingHomeViewModel matches the `companyName` used when creating jobs (verified: `companyName` getter returns `_company.name`)
- **ASSUMPTION-002**: Both supplier home views share the same `SupplierOrdersTab` widget

## 8. Related Specifications / Further Reading

- `Design.md` — Full lifecycle specification with exact code blocks
- `CLAUDE.md` — Architecture overview and conventions
