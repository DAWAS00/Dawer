import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../data/models/report_request.dart';
import '../../domain/repositories/i_report_request_repository.dart';

final class SupabaseReportRequestRepository
    implements IReportRequestRepository {
  SupabaseReportRequestRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppResult<List<ReportRequest>>> fetchRequests(String userId) async {
    try {
      final rows = await _client
          .from('report_requests')
          .select()
          .eq('user_id', userId)
          .order('requested_at', ascending: false);
      final requests = rows
          .map((row) => ReportRequest.fromJson(row))
          .toList();
      return Success(requests);
    } on PostgrestException catch (e) {
      return Failure(NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }

  @override
  Future<AppResult<ReportRequest>> submitRequest({
    required String userId,
    required ReportTemplate template,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    try {
      final payload = {
        'user_id': userId,
        'template': template.name,
        'period_start': periodStart.toIso8601String().substring(0, 10),
        'period_end': periodEnd.toIso8601String().substring(0, 10),
      };
      final row = await _client
          .from('report_requests')
          .insert(payload)
          .select()
          .single();
      return Success(ReportRequest.fromJson(row));
    } on PostgrestException catch (e) {
      return Failure(NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(UnknownFailure.fromException(e));
    }
  }
}
