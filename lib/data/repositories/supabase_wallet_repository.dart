import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/result/result.dart';
import '../../data/models/driver_wallet.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/repositories/i_wallet_repository.dart';

final class SupabaseWalletRepository implements IWalletRepository {
  SupabaseWalletRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<DriverWallet>> getWallet() async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return const Success(DriverWallet.zero);

      final row = await _client
          .from('driver_wallet')
          .select('balance, held_amount')
          .eq('driver_id', uid)
          .maybeSingle();

      return Success(
        row != null ? DriverWallet.fromJson(row) : DriverWallet.zero,
      );
    } on PostgrestException catch (e) {
      return Failure(UnknownFailure(message: e.message, code: e.code));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<void>> holdForOrder(String orderId, double amount) =>
      _rpc('driver_wallet_hold', {'p_order_id': orderId, 'p_amount': amount});

  @override
  Future<AppResult<void>> releaseForOrder(String orderId, double amount) =>
      _rpc('driver_wallet_release', {
        'p_order_id': orderId,
        'p_amount': amount,
      });

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
