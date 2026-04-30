import '../../core/result/result.dart';
import '../../data/models/order.dart';

/// Remote-side gateway for order writes and the live order stream.
///
/// `AppOrderStore` keeps the in-memory list of orders and uses an
/// [IOrderRepository] to (a) subscribe to remote changes and (b) push local
/// mutations back to the backend. The store stays pure Dart + `LocalStore`
/// and never touches Supabase directly, which is what makes it unit-testable.
abstract interface class IOrderRepository {
  /// Live snapshots of the `orders` table as ordered lists. Each emission is
  /// the latest full result set (most-recent first).
  Stream<List<Order>> watchOrders();

  /// Persists [order] to the remote backend. The implementation is responsible
  /// for stamping the current authenticated user id where appropriate.
  Future<AppResult<void>> insertOrder(Order order);

  /// Marks [orderId] as accepted by the current user (driver). The
  /// implementation stamps `driver_id` and `accepted_at` server-side.
  Future<AppResult<void>> markAccepted(String orderId);

  /// Marks [orderId] as cancelled.
  Future<AppResult<void>> markCancelled(String orderId);

  /// Buyer-side marketplace acceptance — sets status accepted and records
  /// whether a rider is required, but does **not** stamp a driver id.
  Future<AppResult<void>> markPurchased(
    String orderId, {
    required bool requiresRider,
  });
}

/// Default no-op implementation. Used by tests and any code path that wants to
/// run `AppOrderStore` without touching a real backend (e.g. seed-only mode).
final class NoOpOrderRepository implements IOrderRepository {
  const NoOpOrderRepository();

  @override
  Stream<List<Order>> watchOrders() => const Stream<List<Order>>.empty();

  @override
  Future<AppResult<void>> insertOrder(Order order) async =>
      const Success(null);

  @override
  Future<AppResult<void>> markAccepted(String orderId) async =>
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
}
