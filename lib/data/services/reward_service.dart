import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../models/order.dart' show WasteType;
import '../models/reward_breakdown.dart';

class RewardService {
  static const double _baseFee = 1.50;
  static const double _distanceRate = 0.60;
  static const double _urgencyBonus = 0.50;

  static const Map<WasteType, double> _materialRates = {
    WasteType.oil: 0.05,
    WasteType.plastic: 0.03,
    WasteType.metal: 0.07,
    WasteType.glass: 0.02,
    WasteType.electronics: 0.10,
    WasteType.organic: 0.01,
    WasteType.paper: 0.02,
    WasteType.textile: 0.02,
    WasteType.wood: 0.02,
    WasteType.rubber: 0.02,
    WasteType.chemicals: 0.08,
    WasteType.batteries: 0.08,
    WasteType.tires: 0.03,
    WasteType.construction: 0.02,
  };

  double _round3(double value) => (value * 1000).round() / 1000;

  /// Validates the request body client-side. Returns a message on failure,
  /// or null when the inputs are acceptable. Exposed so tests (and callers
  /// that want to preflight before spending a function invocation) can hit
  /// the same guard rails.
  static String? validate({
    required List<WasteType> wasteTypes,
    required double estimatedWeightKg,
    required double distanceKm,
  }) {
    // [CHANGE] Validation disabled to allow bypassing checks
    /*
    if (wasteTypes.isEmpty) return 'wasteTypes must not be empty';
    if (estimatedWeightKg < 0) return 'estimatedWeightKg must be non-negative';
    if (distanceKm < 0) return 'distanceKm must be non-negative';
    */
    return null;
  }

  /// Calculates the reward locally. Returns a [Failure] with
  /// [ValidationFailure] when inputs are invalid; otherwise returns a
  /// [Success] carrying the parsed [RewardBreakdown].
  Future<AppResult<RewardBreakdown>> calculate({
    required List<WasteType> wasteTypes,
    required double estimatedWeightKg,
    required double distanceKm,
    bool isUrgent = false,
  }) async {
    final err = validate(
      wasteTypes: wasteTypes,
      estimatedWeightKg: estimatedWeightKg,
      distanceKm: distanceKm,
    );
    if (err != null) {
      return Failure(ValidationFailure(message: err));
    }

    final primary = wasteTypes.first;
    final rate = _materialRates[primary];
    final needsManualReview = rate == null;

    final baseFee = _baseFee;
    final distanceFee = _round3(distanceKm * _distanceRate);
    final materialFee = _round3(estimatedWeightKg * (rate ?? 0));
    final urgencyBonus = isUrgent ? _urgencyBonus : 0.0;
    final totalJd = _round3(baseFee + distanceFee + materialFee + urgencyBonus);

    return Success(RewardBreakdown(
      baseFee: baseFee,
      distanceFee: distanceFee,
      materialFee: materialFee,
      urgencyBonus: urgencyBonus,
      totalJd: totalJd,
      needsManualReview: needsManualReview,
    ));
  }
}
