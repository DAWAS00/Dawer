import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order.dart';
import 'package:dwaar/data/models/user.dart';
import 'package:dwaar/data/services/app_order_store.dart';

void main() {
  late AppOrderStore store;

  setUp(() => store = AppOrderStore());

  const mockDriver = User(
    id: 'DRV-001',
    name: 'سائق اختبار',
    role: 'سائق',
    address: '',
    points: 0,
    totalOrders: 0,
    isVerified: true,
    vehicleModel: 'تويوتا',
    vehicleColor: 'أبيض',
    licensePlate: 'أ ب ج 1234',
  );

  group('AppOrderStore – seed data', () {
    test('loads seed orders on construction', () {
      expect(store.driverFeed.isNotEmpty, isTrue);
    });

    test('loads seed market items on construction', () {
      expect(store.marketItems.isNotEmpty, isTrue);
    });
  });

  group('AppOrderStore – acceptOrder', () {
    test('accepts a pending order and sets activeOrderId', () {
      final pendingId = store.driverFeed.first.id;
      final error = store.acceptOrder(pendingId, mockDriver);
      expect(error, isNull);
      expect(store.driverActiveOrder?.id, pendingId);
      expect(store.driverActiveOrder?.status, OrderStatus.accepted);
    });

    test('returns error if driver already has active order', () {
      final pendingId = store.driverFeed.first.id;
      store.acceptOrder(pendingId, mockDriver);
      final anotherPendingId =
          store.driverFeed.firstWhere((o) => o.id != pendingId).id;
      final error = store.acceptOrder(anotherPendingId, mockDriver);
      expect(error, isNotNull);
    });
  });

  group('AppOrderStore – markInTransit', () {
    test('sets status to inTransit and records inTransitAt', () {
      final pendingId = store.driverFeed.first.id;
      store.acceptOrder(pendingId, mockDriver);
      store.markInTransit(pendingId);
      final order = store.driverActiveOrder!;
      expect(order.status, OrderStatus.inTransit);
      expect(order.inTransitAt, isNotNull);
    });
  });

  group('AppOrderStore – completeOrder', () {
    test('sets status to completed and records completedAt', () {
      final pendingId = store.driverFeed.first.id;
      store.acceptOrder(pendingId, mockDriver);
      final active = store.driverActiveOrder!;
      store.completeOrder(active);
      final history = store.driverHistory;
      expect(history.any((o) => o.id == pendingId), isTrue);
      final completed = history.firstWhere((o) => o.id == pendingId);
      expect(completed.status, OrderStatus.completed);
      expect(completed.completedAt, isNotNull);
    });

    test('clears activeOrderId after completion', () {
      final pendingId = store.driverFeed.first.id;
      store.acceptOrder(pendingId, mockDriver);
      store.completeOrder(store.driverActiveOrder!);
      expect(store.driverHasActiveOrder, isFalse);
    });
  });

  group('AppOrderStore – cancelOrder', () {
    test('cancels a pending supplier order', () {
      final order = store.createPickupRequest(
        wasteTypes: [WasteType.paper],
        supplierName: 'مورد دوّر',
        pickupAddress: 'test address',
      );
      final error = store.cancelOrder(order.id);
      expect(error, isNull);
      final orders = store.supplierOrdersFor('مورد دوّر');
      final cancelled = orders.firstWhere((o) => o.id == order.id);
      expect(cancelled.status, OrderStatus.cancelled);
    });

    test('returns error when cancelling a non-pending order', () {
      final pendingId = store.driverFeed.first.id;
      store.acceptOrder(pendingId, mockDriver);
      final error = store.cancelOrder(pendingId);
      expect(error, isNotNull);
    });
  });

  group('AppOrderStore – submitDriverRating', () {
    test('updates driver rating on the order', () {
      final pendingId = store.driverFeed.first.id;
      store.acceptOrder(pendingId, mockDriver);
      store.completeOrder(store.driverActiveOrder!);
      store.submitDriverRating(pendingId, 4.5);
      final order = store.driverHistory.firstWhere((o) => o.id == pendingId);
      expect(order.driverRating, 4.5);
    });
  });

  group('AppOrderStore – createPickupRequest', () {
    test('creates an order with scheduledAt when provided', () {
      final scheduled = DateTime(2026, 5, 1, 10, 0);
      final order = store.createPickupRequest(
        wasteTypes: [WasteType.plastic],
        supplierName: 'مورد دوّر',
        pickupAddress: 'test',
        scheduledAt: scheduled,
      );
      expect(order.scheduledAt, scheduled);
    });
  });

  group('AppOrderStore – collection sale lifecycle', () {
    AppOrderStore storeWithSale({PaymentModel? paymentModel}) {
      final s = AppOrderStore();
      s.createCollectionJob(
        wasteTypes: [WasteType.plastic],
        pickupAddress: 'منطقة الرابية',
        companyName: 'شركة اختبار',
      );
      final jobId = s.pendingCollectionJobs.first.id;
      s.createCollectionSale(
        jobId: jobId,
        acceptorName: 'مورد اختبار',
        collectionArea: 'منطقة الرابية',
        wasteTypes: [WasteType.plastic],
        paymentModel: paymentModel,
      );
      return s;
    }

    test('markCollectionSaleInTransit succeeds from accepted', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      expect(s.collectionSalesFor('مورد اختبار').first.status, OrderStatus.accepted);
      final error = s.markCollectionSaleInTransit(saleId);
      expect(error, isNull);
      final sale = s.collectionSalesFor('مورد اختبار').first;
      expect(sale.status, OrderStatus.inTransit);
      expect(sale.inTransitAt, isNotNull);
    });

    test('markCollectionSaleInTransit fails if already inTransit', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      s.markCollectionSaleInTransit(saleId);
      final error = s.markCollectionSaleInTransit(saleId);
      expect(error, isNotNull);
    });

    test('markCollectionSaleInTransit fails for wrong id', () {
      final s = storeWithSale();
      final error = s.markCollectionSaleInTransit('SALE-NONEXISTENT');
      expect(error, isNotNull);
    });

    test('completeCollectionSale succeeds from inTransit', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      s.markCollectionSaleInTransit(saleId);
      final error = s.completeCollectionSale(saleId);
      expect(error, isNull);
      final sale = s.collectionSalesFor('مورد اختبار').first;
      expect(sale.status, OrderStatus.completed);
      expect(sale.completedAt, isNotNull);
    });

    test('completeCollectionSale fails if not inTransit', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      final error = s.completeCollectionSale(saleId);
      expect(error, isNotNull);
    });

    test('completeCollectionSale stores actualWeightKg', () {
      final s = storeWithSale(paymentModel: PaymentModel.perKg);
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      s.markCollectionSaleInTransit(saleId);
      final error = s.completeCollectionSale(saleId, actualWeightKg: 42.5);
      expect(error, isNull);
      final sale = s.collectionSalesFor('مورد اختبار').first;
      expect(sale.weightKg, 42.5);
    });

    test('cancelCollectionSale succeeds from accepted', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      s.cancelCollectionSale(saleId);
      final sale = s.collectionSalesFor('مورد اختبار').first;
      expect(sale.status, OrderStatus.cancelled);
    });

    test('cancelCollectionSale silent when inTransit', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      s.markCollectionSaleInTransit(saleId);
      s.cancelCollectionSale(saleId);
      final sale = s.collectionSalesFor('مورد اختبار').first;
      expect(sale.status, OrderStatus.inTransit);
    });

    test('cancelCollectionSale silent when completed', () {
      final s = storeWithSale();
      final saleId = s.collectionSalesFor('مورد اختبار').first.id;
      s.markCollectionSaleInTransit(saleId);
      s.completeCollectionSale(saleId);
      s.cancelCollectionSale(saleId);
      final sale = s.collectionSalesFor('مورد اختبار').first;
      expect(sale.status, OrderStatus.completed);
    });

    test('salesForCompanyJobs returns only sales for that company', () {
      final s = storeWithSale();
      final sales = s.salesForCompanyJobs('شركة اختبار');
      expect(sales.length, 1);
      expect(sales.first.supplierName, 'مورد اختبار');
    });

    test('salesForCompanyJobs returns empty for company with no jobs', () {
      final s = storeWithSale();
      final sales = s.salesForCompanyJobs('شركة وهمية');
      expect(sales, isEmpty);
    });
  });
}
