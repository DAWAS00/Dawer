import '../../core/result/result.dart';
import '../../data/models/partner_data_request.dart';
import '../../domain/repositories/i_partner_data_request_repository.dart';

/// In-memory implementation used when Supabase is unavailable (offline/mock
/// mode) and in tests.
class MockPartnerDataRequestRepository implements IPartnerDataRequestRepository {
  final List<PartnerDataRequest> _requests = [];

  List<PartnerDataRequest> get submittedRequests => List.unmodifiable(_requests);

  @override
  Future<AppResult<PartnerDataRequest>> submitRequest({
    required String companyName,
    required String contactName,
    required String email,
    String? phone,
    required String message,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final request = PartnerDataRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      companyName: companyName,
      contactName: contactName,
      email: email,
      phone: phone,
      message: message,
      requestedAt: DateTime.now(),
    );
    _requests.add(request);
    return Success(request);
  }
}
