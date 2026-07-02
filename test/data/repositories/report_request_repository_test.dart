import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/repositories/mock_report_request_repository.dart';
import 'package:dwaar/data/models/report_request.dart';
import 'package:dwaar/core/result/result.dart';

// NOTE: SupabaseReportRequestRepository integration tests require a live
// Supabase project. Run with: flutter test --tags=integration
// This file tests the mock implementation to document the expected contract.
void main() {
  group('MockReportRequestRepository (contract verification)', () {
    late MockReportRequestRepository repo;

    setUp(() => repo = MockReportRequestRepository());

    test('fetchRequests returns empty list for unknown user', () async {
      final result = await repo.fetchRequests('unknown-user');
      expect(result, isA<Success>());
      expect((result as Success).value, isEmpty);
    });

    test(
      'submitRequest creates a pending request and fetchRequests returns it',
      () async {
        final submitResult = await repo.submitRequest(
          userId: 'user-1',
          template: ReportTemplate.weeklySummary,
          periodStart: DateTime(2026, 6, 1),
          periodEnd: DateTime(2026, 6, 28),
        );
        expect(submitResult, isA<Success>());
        final req = (submitResult as Success<ReportRequest, dynamic>).value;
        expect(req.status, ReportStatus.pending);
        expect(req.userId, 'user-1');
        expect(req.template, ReportTemplate.weeklySummary);

        final fetchResult = await repo.fetchRequests('user-1');
        final list =
            (fetchResult as Success<List<ReportRequest>, dynamic>).value;
        expect(list.length, 1);
        expect(list.first.id, req.id);
      },
    );

    test('submitRequest returns unique IDs for multiple requests', () async {
      await repo.submitRequest(
        userId: 'user-1',
        template: ReportTemplate.monthlyInvoice,
        periodStart: DateTime(2026, 6, 1),
        periodEnd: DateTime(2026, 6, 28),
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));
      await repo.submitRequest(
        userId: 'user-1',
        template: ReportTemplate.co2Certificate,
        periodStart: DateTime(2026, 6, 1),
        periodEnd: DateTime(2026, 6, 28),
      );
      final result = await repo.fetchRequests('user-1');
      final list = (result as Success<List<ReportRequest>, dynamic>).value;
      expect(list.length, 2);
      expect(list.first.id, isNot(list.last.id));
    });

    test('fetchRequests isolates requests by userId', () async {
      await repo.submitRequest(
        userId: 'user-a',
        template: ReportTemplate.esgReport,
        periodStart: DateTime(2026, 6, 1),
        periodEnd: DateTime(2026, 6, 28),
      );
      final result = await repo.fetchRequests('user-b');
      final list = (result as Success<List<ReportRequest>, dynamic>).value;
      expect(list, isEmpty);
    });

    test('fetchRequests returns newest first', () async {
      await repo.submitRequest(
        userId: 'user-1',
        template: ReportTemplate.weeklySummary,
        periodStart: DateTime(2026, 6, 1),
        periodEnd: DateTime(2026, 6, 7),
      );
      await Future<void>.delayed(const Duration(milliseconds: 2));
      await repo.submitRequest(
        userId: 'user-1',
        template: ReportTemplate.monthlyInvoice,
        periodStart: DateTime(2026, 6, 1),
        periodEnd: DateTime(2026, 6, 28),
      );
      final result = await repo.fetchRequests('user-1');
      final list = (result as Success<List<ReportRequest>, dynamic>).value;
      expect(list.first.template, ReportTemplate.monthlyInvoice);
    });
  });
}
