import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../models/order/order.dart';
import '../models/order_supabase_ext.dart';
import '../models/reward_breakdown.dart';
import '../models/user_role.dart';

/// Supabase-backed implementation of [IOrderRepository].
///
/// All write methods catch transport/Postgrest errors and surface them as
/// [AppFailure]s; the caller decides whether to display them. Network errors
/// are mapped to [NetworkFailure] so the UI can show a localized retry hint.
final class SupabaseOrderRepository implements IOrderRepository {
  SupabaseOrderRepository(this._client);

  final SupabaseClient _client;

  // ── Reads ──────────────────────────────────────────────────────────────────

  @override
  Stream<List<Order>> watchOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(orderFromSupabaseJson).toList());
  }

  @override
  Stream<List<Order>> watchOrdersForUser(String userId, UserRole role) {
    switch (role) {
      case UserRole.supplier:
        return _client
            .from('orders')
            .stream(primaryKey: ['id'])
            .eq('supplier_id', userId)
            .order('created_at', ascending: false)
            .map((rows) => rows.map(orderFromSupabaseJson).toList());
      case UserRole.recyclingCo:
        return _client
            .from('orders')
            .stream(primaryKey: ['id'])
            .eq('company_id', userId)
            .order('created_at', ascending: false)
            .map((rows) => rows.map(orderFromSupabaseJson).toList());
      case UserRole.driver:
        // Drivers need both available (pending, no driver) and their own orders.
        // Supabase .stream().eq() supports only a single equality filter.
        // RLS on the DB enforces visibility; we fall back to the full stream
        // and rely on client-side filtering in AppOrderStore until pagination
        // is added in a later sprint.
        return watchOrders();
    }
  }

  // ── Writes ─────────────────────────────────────────────────────────────────

  @override
  Future<AppResult<void>> insertOrder(Order order) async {
    final authUserId = _client.auth.currentUser?.id;
    final payload = order.toSupabaseMap(authUserId)..remove('id');
    return _runWithRetry(() => _client.from('orders').insert(payload));
  }

  @override
  Future<AppResult<void>> updateOrder(Order order) async {
    final authUserId = _client.auth.currentUser?.id;
    final payload = order.toSupabaseMap(authUserId);
    return _run(() => _client.from('orders').update(payload).eq('id', order.id));
  }

  @override
  Future<AppResult<void>> deleteOrder(String orderId) {
    return _run(() => _client.from('orders').delete().eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markAccepted(String orderId) {
    return _runWithRetry(() => _client.from('orders').update({
          'status': 'accepted',
          'driver_id': _client.auth.currentUser?.id,
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> assignDriver(String orderId, String driverId) {
    return _run(() => _client.from('orders').update({
          'status': 'accepted',
          'driver_id': driverId,
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markCancelled(String orderId) {
    return _run(() => _client.from('orders').update({
          'status': 'cancelled',
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markPurchased(
    String orderId, {
    required bool requiresRider,
  }) {
    return _run(() => _client.from('orders').update({
          'status': 'accepted',
          'accepted_at': DateTime.now().toUtc().toIso8601String(),
          'requires_rider': requiresRider,
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markInTransit(String orderId) {
    return _run(() => _client.from('orders').update({
          'status': 'inTransit',
          'in_transit_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markArrivedAtPickup(String orderId) {
    return _run(() => _client.from('orders').update({
          'status': 'arrivedAtPickup',
          'arrived_at_pickup_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markArrivedAtDropoff(String orderId) {
    return _run(() => _client.from('orders').update({
          'status': 'arrivedAtDropoff',
          'arrived_at_dropoff_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> markCompleted(String orderId, {double? actualWeightKg}) {
    return _run(() => _client.from('orders').update({
          'status': 'completed',
          'completed_at': DateTime.now().toUtc().toIso8601String(),
          if (actualWeightKg != null) 'actual_weight_kg': actualWeightKg,
        }).eq('id', orderId));
  }

  @override
  Future<AppResult<void>> recordTransaction({
    required String orderId,
    required RewardBreakdown breakdown,
    String? vehicleType,
  }) {
    if (_client.auth.currentUser == null) return Future.value(const Success(null));
    return _run(() => _client.rpc('record_order_transaction', params: {
          'p_order_id': orderId,
          'p_base_fee': breakdown.baseFee,
          'p_distance_fee': breakdown.distanceFee,
          'p_material_fee': breakdown.materialFee,
          'p_urgency_bonus': breakdown.urgencyBonus,
          'p_weight_surcharge': breakdown.weightSurcharge,
          'p_gross_fee': breakdown.grossFee,
          'p_platform_cut': breakdown.platformCut,
          'p_driver_payout': breakdown.driverPayout,
          'p_vehicle_type': vehicleType,
          'p_needs_manual_review': breakdown.needsManualReview,
        }));
  }

  @override
  Future<AppResult<bool>> verifyArrival(
    String orderId,
    double lat,
    double lng,
  ) async {
    try {
      final result = await _client.rpc('verify_driver_arrival', params: {
        'p_order_id': orderId,
        'p_lat': lat,
        'p_lng': lng,
      }) as bool? ?? false;
      return Success(result);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      if (_isNetworkError(e)) return const Failure(NetworkFailure());
      return Failure(UnknownFailure.fromException(e));
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  Future<AppResult<void>> _run(Future<void> Function() op) async {
    try {
      await op();
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      if (_isNetworkError(e)) {
        return const Failure(NetworkFailure());
      }
      return Failure(UnknownFailure.fromException(e));
    }
  }

  Future<AppResult<void>> _runWithRetry(
    Future<void> Function() op, {
    int retries = 1,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        await op();
        return const Success(null);
      } on PostgrestException catch (e) {
        if (attempts >= retries) {
          return Failure(UnknownFailure(message: e.message, code: e.code));
        }
      } catch (e) {
        if (attempts >= retries) {
          if (_isNetworkError(e)) {
            return const Failure(NetworkFailure());
          }
          return Failure(UnknownFailure.fromException(e));
        }
      }
      attempts++;
      await Future.delayed(delay);
    }
  }

  static bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('connection refused') ||
        msg.contains('failed host lookup');
  }
}
