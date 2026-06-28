import '../../core/result/result.dart';
import '../../data/models/report_request.dart';

abstract interface class IReportRequestRepository {
  /// Fetch all report requests for a given user, newest first.
  Future<AppResult<List<ReportRequest>>> fetchRequests(String userId);

  /// Submit a new report request.
  Future<AppResult<ReportRequest>> submitRequest({
    required String userId,
    required ReportTemplate template,
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}
