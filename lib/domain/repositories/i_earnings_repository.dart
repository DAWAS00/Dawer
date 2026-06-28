import '../../core/result/result.dart';
import '../entities/earnings/earnings_summary.dart';

abstract interface class IEarningsRepository {
  /// Fetches the earnings summary for a specific rider within a date range.
  Future<AppResult<EarningsSummary>> getEarningsSummary({
    required String riderId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
