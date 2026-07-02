import '../../core/result/result.dart';
import '../entities/earnings/earnings_summary.dart';
import '../repositories/i_earnings_repository.dart';

class EarningsService {
  final IEarningsRepository _repository;

  EarningsService(this._repository);

  Future<AppResult<EarningsSummary>> getEarningsSummary({
    required String riderId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getEarningsSummary(
      riderId: riderId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
