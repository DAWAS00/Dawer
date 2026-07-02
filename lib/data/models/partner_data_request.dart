import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_data_request.freezed.dart';
part 'partner_data_request.g.dart';

/// Lifecycle of a B2B "we'd like to purchase your recycling data" lead
/// submitted from the About Dwaar sheet on the login screen.
enum PartnerDataRequestStatus { pending, contacted, closed }

/// A lead captured from a company that wants to buy/access Dwaar's
/// aggregated recycling data (e.g. municipalities, sustainability firms,
/// research partners). Submitted anonymously — before the requester has
/// a Dwaar account — so there is no [userId].
@freezed
class PartnerDataRequest with _$PartnerDataRequest {
  const factory PartnerDataRequest({
    required String id,
    required String companyName,
    required String contactName,
    required String email,
    String? phone,
    required String message,
    @Default(PartnerDataRequestStatus.pending) PartnerDataRequestStatus status,
    required DateTime requestedAt,
  }) = _PartnerDataRequest;

  factory PartnerDataRequest.fromJson(Map<String, dynamic> json) =>
      _$PartnerDataRequestFromJson(json);
}
