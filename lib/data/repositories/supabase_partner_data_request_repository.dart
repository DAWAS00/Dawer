import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../data/models/partner_data_request.dart';
import '../../domain/repositories/i_partner_data_request_repository.dart';

final class SupabasePartnerDataRequestRepository
    implements IPartnerDataRequestRepository {
  SupabasePartnerDataRequestRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<PartnerDataRequest>> submitRequest({
    required String companyName,
    required String contactName,
    required String email,
    String? phone,
    required String message,
  }) async {
    // Submitted from the pre-auth login screen: the anon role may only
    // INSERT into partner_data_requests (no SELECT policy — only the admin
    // dashboard, via service_role, reads leads back). So we don't request
    // `.select()` after the insert; the confirmation model is built locally.
    try {
      final requestedAt = DateTime.now();
      final payload = {
        'company_name': companyName,
        'contact_name': contactName,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'message': message,
      };
      await _client.from('partner_data_requests').insert(payload);
      return Success(
        PartnerDataRequest(
          id: requestedAt.microsecondsSinceEpoch.toString(),
          companyName: companyName,
          contactName: contactName,
          email: email,
          phone: phone,
          message: message,
          requestedAt: requestedAt,
        ),
      );
    } on PostgrestException catch (e) {
      return Failure(NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
