import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/core/result/result.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/app_order_store.dart';
import 'package:dwaar/domain/repositories/i_order_repository.dart';

class _RecordingOrderRepository implements IOrderRepository {
  final List<String> calls = [];

  @override
  Stream<List<Order>> watchOrders() => const Stream.empty();

  @override
  Stream<List<Order>> watchOrdersForUser(String userId, UserRole role) =>
      const Stream.empty();

  @override
  Future<AppResult<void>> insertOrder(Order order) async {
    calls.add('insertOrder');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> updateOrder(Order order) async {
    calls.add('updateOrder');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> deleteOrder(String orderId) async {
    calls.add('deleteOrder');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markAccepted(String orderId) async {
    calls.add('markAccepted');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> assignDriver(String orderId, String driverId) async {
    calls.add('assignDriver');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markCancelled(String orderId) async {
    calls.add('markCancelled');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markPurchased(String orderId, {required bool requiresRider}) async {
    calls.add('markPurchased');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markInTransit(String orderId) async {
    calls.add('markInTransit');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markArrivedAtPickup(String orderId) async {
    calls.add('markArrivedAtPickup');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markArrivedAtDropoff(String orderId) async {
    calls.add('markArrivedAtDropoff');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> markCompleted(String orderId, {double? actualWeightKg}) async {
    calls.add('markCompleted');
    return const Success(null);
  }

  @override
  Future<AppResult<void>> recordTransaction({
    required String orderId,
    required breakdown,
    String? vehicleType,
  }) async {
    calls.add('recordTransaction');
    return const Success(null);
  }

  @override
  Future<AppResult<bool>> verifyArrival(String orderId, double lat, double lng) async {
    calls.add('verifyArrival');
    return const Success(true);
  }
}

void main() {
  group('AppOrderStore – collection sale lifecycle remote wiring', () {
    late _RecordingOrderRepository repo;
    late AppOrderStore store;

    setUp(() {
      repo = _RecordingOrderRepository();
      store = AppOrderStore(remote: repo);
    });

    test('createCollectionJob calls remote.insertOrder', () async {
      store.createCollectionJob(
        wasteTypes: [WasteType.plastic],
        pickupAddress: 'Test Area',
        companyName: 'Test Co',
      );
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('insertOrder'));
    });

    test('updateCollectionJob calls remote.updateOrder', () async {
      final job = store.createCollectionJob(
        wasteTypes: [WasteType.plastic],
        pickupAddress: 'Test Area',
        companyName: 'Test Co',
      );
      
      store.updateCollectionJob(
        jobId: job.id,
        companyName: 'Test Co',
        wasteTypes: [WasteType.paper],
        collectionArea: 'New Area',
        jobDescription: 'New Desc',
        paymentModel: PaymentModel.flatFee,
        price: 10,
      );
      
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, containsAll(['insertOrder', 'updateOrder']));
    });

    test('deleteCollectionJob calls remote.deleteOrder', () async {
      final job = store.createCollectionJob(
        wasteTypes: [WasteType.plastic],
        pickupAddress: 'Test Area',
        companyName: 'Test Co',
      );
      
      store.deleteCollectionJob(job.id, 'Test Co');
      
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, containsAll(['insertOrder', 'deleteOrder']));
    });

    test('createCollectionSale calls remote.insertOrder', () async {
      store.createCollectionSale(
        jobId: 'JOB-123',
        acceptorName: 'Test Supplier',
        collectionArea: 'Test Area',
        wasteTypes: [WasteType.plastic],
      );
      
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, contains('insertOrder'));
    });

    test('markCollectionSaleInTransit calls remote.markInTransit', () async {
      store.createCollectionSale(
        jobId: 'JOB-123',
        acceptorName: 'Test Supplier',
        collectionArea: 'Test Area',
        wasteTypes: [WasteType.plastic],
      );
      
      final saleId = store.collectionSalesFor('Test Supplier').first.id;
      store.markCollectionSaleInTransit(saleId);
      
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, containsAll(['insertOrder', 'markInTransit']));
    });

    test('completeCollectionSale calls remote.markCompleted', () async {
       store.createCollectionSale(
        jobId: 'JOB-123',
        acceptorName: 'Test Supplier',
        collectionArea: 'Test Area',
        wasteTypes: [WasteType.plastic],
      );
      
      final saleId = store.collectionSalesFor('Test Supplier').first.id;
      store.markCollectionSaleInTransit(saleId);
      store.completeCollectionSale(saleId, actualWeightKg: 10.5);
      
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, containsAll(['insertOrder', 'markInTransit', 'markCompleted']));
    });

    test('cancelCollectionSale calls remote.markCancelled', () async {
       store.createCollectionSale(
        jobId: 'JOB-123',
        acceptorName: 'Test Supplier',
        collectionArea: 'Test Area',
        wasteTypes: [WasteType.plastic],
      );
      
      final saleId = store.collectionSalesFor('Test Supplier').first.id;
      store.cancelCollectionSale(saleId);
      
      await Future<void>.delayed(Duration.zero);
      expect(repo.calls, containsAll(['insertOrder', 'markCancelled']));
    });
  });
}
