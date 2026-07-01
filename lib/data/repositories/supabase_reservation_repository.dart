import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_reservation_repository.dart';
import '../models/reservation.dart';

final class SupabaseReservationRepository implements IReservationRepository {
  SupabaseReservationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<String?>> findUserNameByPhone(String phone) async {
    try {
      final rows = await _client.rpc('find_user_by_phone', params: {'p_phone': phone});
      final list = rows as List;
      if (list.isEmpty) return const Success(null);
      return Success(list.first['name'] as String?);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<String>> createReservation({
    required String buyerPhone,
    required String itemTitle,
    required double invoiceTotal,
    required int durationMinutes,
  }) async {
    try {
      final id = await _client.rpc('create_reservation', params: {
        'p_buyer_phone': buyerPhone,
        'p_item_title': itemTitle,
        'p_invoice_total': invoiceTotal,
        'p_duration_minutes': durationMinutes,
      });
      return Success(id as String);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<void>> approveReservation(String reservationId) =>
      _rpc('approve_reservation', {'p_reservation_id': reservationId});

  @override
  Future<AppResult<void>> completeReservation(String reservationId) =>
      _rpc('complete_reservation', {'p_reservation_id': reservationId});

  @override
  Future<AppResult<void>> cancelReservation(String reservationId, String reason) =>
      _rpc('cancel_reservation', {'p_reservation_id': reservationId, 'p_reason': reason});

  @override
  Future<AppResult<List<Reservation>>> fetchForCurrentUser() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return const Success([]);

      final rows = await _client
          .from('reservations')
          .select()
          .or('seller_id.eq.$uid,buyer_id.eq.$uid')
          .order('created_at', ascending: false);

      return Success((rows as List)
          .map((row) => Reservation.fromJson(row as Map<String, dynamic>))
          .toList());
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  Future<AppResult<void>> _rpc(String fn, Map<String, dynamic> params) async {
    try {
      await _client.rpc(fn, params: params);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
