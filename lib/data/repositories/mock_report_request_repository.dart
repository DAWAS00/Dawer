import '../../core/result/result.dart';
import '../../data/models/report_request.dart';
import '../../domain/repositories/i_report_request_repository.dart';

class MockReportRequestRepository implements IReportRequestRepository {
  final List<ReportRequest> _requests = [];

  @override
  Future<AppResult<List<ReportRequest>>> fetchRequests(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final results = _requests.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return Success(results);
  }

  @override
  Future<AppResult<ReportRequest>> submitRequest({
    required String userId,
    required ReportTemplate template,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final request = ReportRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      template: template,
      requestedAt: DateTime.now(),
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    _requests.add(request);
    return Success(request);
  }
}
