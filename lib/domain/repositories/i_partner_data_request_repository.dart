import '../../core/result/result.dart';
import '../../data/models/partner_data_request.dart';

/// Gateway for B2B "purchase our recycling data" leads submitted from the
/// About Dwaar sheet on the login screen (pre-auth — no user session).
abstract interface class IPartnerDataRequestRepository {
  /// Submit a new data-access lead. The admin dashboard follows up by email.
  Future<AppResult<PartnerDataRequest>> submitRequest({
    required String companyName,
    required String contactName,
    required String email,
    String? phone,
    required String message,
  });
}
