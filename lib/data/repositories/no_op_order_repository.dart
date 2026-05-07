import '../../core/result/result.dart';
import '../../data/models/order.dart';
import '../../data/models/user_role.dart';
import '../../domain/repositories/i_order_repository.dart';

/// Default no-op implementation. Used by tests and any code path that wants to
/// run `AppOrderStore` without touching a real backend (e.g. seed-only mode).
final class NoOpOrderRepository implements IOrderRepository {
  const NoOpOrderRepository();

  @override
  Stream<List<Order>> watchOrders() => const Stream<List<Order>>.empty();

  @override
  Stream<List<Order>> watchOrdersForUser(String userId, UserRole role) =>
      const Stream<List<Order>>.empty();

  @override
  Future<AppResult<void>> insertOrder(Order order) async =>
      const Success(null);

  @override
  Future<AppResult<void>> updateOrder(Order order) async =>
      const Success(null);

  @override
  Future<AppResult<void>> deleteOrder(String orderId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> markAccepted(String orderId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> assignDriver(String orderId, String driverId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> markCancelled(String orderId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> markPurchased(
    String orderId, {
    required bool requiresRider,
  }) async =>
      const Success(null);

  @override
  Future<AppResult<void>> markInTransit(String orderId) async =>
      const Success(null);

  @override
  Future<AppResult<void>> markCompleted(String orderId, {double? actualWeightKg}) async =>
      const Success(null);
}
