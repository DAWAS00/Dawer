import '../../core/result/result.dart';
import '../../data/models/order.dart';
import '../../data/models/user_role.dart';

/// Remote-side gateway for order writes and the live order stream.
///
/// `AppOrderStore` keeps the in-memory list of orders and uses an
/// [IOrderRepository] to (a) subscribe to remote changes and (b) push local
/// mutations back to the backend. The store stays pure Dart + `LocalStore`
/// and never touches Supabase directly, which is what makes it unit-testable.
abstract interface class IOrderRepository {
  /// Live snapshots of the `orders` table — full unfiltered stream.
  /// Used internally when no auth context is available.
  Stream<List<Order>> watchOrders();

  /// Role-scoped live stream. Applies server-side filters so each user only
  /// receives orders relevant to them:
  /// - supplier → orders they created (`supplier_id = userId`)
  /// - recyclingCo → jobs/shipments they own (`company_id = userId`)
  /// - driver → all pending orders + orders they own (falls back to full stream;
  ///   visibility is enforced by RLS on the DB)
  Stream<List<Order>> watchOrdersForUser(String userId, UserRole role);

  /// Persists [order] to the remote backend. The implementation is responsible
  /// for stamping the current authenticated user id where appropriate.
  Future<AppResult<void>> insertOrder(Order order);

  /// Marks [orderId] as accepted by the current user (driver). The
  /// implementation stamps `driver_id` and `accepted_at` server-side.
  Future<AppResult<void>> markAccepted(String orderId);

  /// Assigns a specific [driverId] to [orderId] (called by supplier).
  Future<AppResult<void>> assignDriver(String orderId, String driverId);

  /// Marks [orderId] as cancelled.
  Future<AppResult<void>> markCancelled(String orderId);

  /// Buyer-side marketplace acceptance — sets status accepted and records
  /// whether a rider is required, but does **not** stamp a driver id.
  Future<AppResult<void>> markPurchased(
    String orderId, {
    required bool requiresRider,
  });

  /// Marks [orderId] as in-transit (driver en route to dropoff). Stamps
  /// `in_transit_at` server-side.
  Future<AppResult<void>> markInTransit(String orderId);

  /// Marks [orderId] as completed. Stamps `completed_at` server-side.
  /// [actualWeightKg] is optional, used for collectionSale final settlement.
  Future<AppResult<void>> markCompleted(String orderId, {double? actualWeightKg});

  /// Updates an existing collection job.
  Future<AppResult<void>> updateOrder(Order order);

  /// Deletes an order (only if status is pending).
  Future<AppResult<void>> deleteOrder(String orderId);
}

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
