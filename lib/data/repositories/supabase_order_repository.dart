import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../models/order.dart';
import '../models/order_supabase_ext.dart';

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

  // ── Writes ─────────────────────────────────────────────────────────────────

  @override
  Future<AppResult<void>> insertOrder(Order order) async {
    final authUserId = _client.auth.currentUser?.id;
    final payload = order.toSupabaseMap(authUserId)..remove('id');
    return _run(() => _client.from('orders').insert(payload));
  }

  @override
  Future<AppResult<void>> markAccepted(String orderId) {
    return _run(() => _client.from('orders').update({
          'status': 'accepted',
          'driver_id': _client.auth.currentUser?.id,
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

  static bool _isNetworkError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('connection refused') ||
        msg.contains('failed host lookup');
  }
}
