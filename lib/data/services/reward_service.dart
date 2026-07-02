import '../../core/result/result.dart';
import '../../domain/failures/app_failure.dart';
import '../models/order/order.dart' show VehicleType, WasteType;
import '../models/reward_breakdown.dart';

class RewardService {
  static const double _urgencyBonus = 0.50;
  static const double _platformCutRate = 0.10;
  static const double _maxPayout = 50.0;

  static const Map<VehicleType, double> _baseFees = {
    VehicleType.motorcycle: 0.80,
    VehicleType.car: 1.20,
    VehicleType.pickup: 1.50,
    VehicleType.van: 2.00,
    VehicleType.truck: 3.50,
    VehicleType.heavyTruck: 5.00,
  };

  static const Map<VehicleType, double> _distanceRates = {
    VehicleType.motorcycle: 0.30,
    VehicleType.car: 0.45,
    VehicleType.pickup: 0.60,
    VehicleType.van: 0.75,
    VehicleType.truck: 1.00,
    VehicleType.heavyTruck: 1.20,
  };

  static const Map<WasteType, double> _materialRates = {
    WasteType.copperAluminium: 0.15,
    WasteType.electronics: 0.10,
    WasteType.chemicals: 0.08,
    WasteType.batteries: 0.08,
    WasteType.metal: 0.07,
    WasteType.oil: 0.05,
    WasteType.plastic: 0.03,
    WasteType.tires: 0.03,
    WasteType.paper: 0.02,
    WasteType.textile: 0.02,
    WasteType.wood: 0.02,
    WasteType.rubber: 0.02,
    WasteType.construction: 0.02,
    WasteType.glass: 0.02,
    WasteType.furniture: 0.02,
    WasteType.organic: 0.01,
  };

  double _round3(double v) => (v * 1000).round() / 1000;

  static String? validate({
    required List<WasteType> wasteTypes,
    required double estimatedWeightKg,
    required double distanceKm,
  }) {
    if (wasteTypes.isEmpty) return 'يجب تحديد نوع النفايات';
    if (estimatedWeightKg < 0) return 'يجب أن يكون الوزن المقدر غير سالب';
    if (distanceKm < 0) return 'يجب أن تكون المسافة غير سالبة';
    return null;
  }

  static bool hasWeightVariance(double estimatedKg, double actualKg) {
    if (estimatedKg <= 0) return false;
    return ((actualKg - estimatedKg) / estimatedKg).abs() > 0.50;
  }

  static double weightSurchargeFor(double weightKg) {
    if (weightKg < 5) return 0.0;
    if (weightKg < 20) return 1.5;
    if (weightKg < 100) return 4.0;
    return 8.0;
  }

  Future<AppResult<RewardBreakdown>> calculate({
    required List<WasteType> wasteTypes,
    required double estimatedWeightKg,
    required double distanceKm,
    bool isUrgent = false,
    double? actualWeightKg,
    VehicleType vehicleType = VehicleType.pickup,
  }) async {
    final err = validate(
      wasteTypes: wasteTypes,
      estimatedWeightKg: estimatedWeightKg,
      distanceKm: distanceKm,
    );
    if (err != null) return Failure(ValidationFailure(message: err));

    final primary = wasteTypes.first;
    final rate = _materialRates[primary];
    final weightForMaterial = actualWeightKg ?? estimatedWeightKg;
    final weightVariance =
        actualWeightKg != null &&
        hasWeightVariance(estimatedWeightKg, actualWeightKg);
    final needsManualReview = rate == null || weightVariance;

    final baseFee = _baseFees[vehicleType] ?? 1.50;
    final distanceFee = _round3(
      distanceKm * (_distanceRates[vehicleType] ?? 0.60),
    );
    final weightSurch = weightSurchargeFor(estimatedWeightKg);
    final materialFee = _round3(weightForMaterial * (rate ?? 0));
    final urgency = isUrgent ? _urgencyBonus : 0.0;
    final grossFee = _round3(
      baseFee + distanceFee + weightSurch + materialFee + urgency,
    );
    final platformCut = _round3(grossFee * _platformCutRate);
    final driverPayout = _round3(
      (grossFee - platformCut).clamp(baseFee, _maxPayout),
    );

    return Success(
      RewardBreakdown(
        baseFee: baseFee,
        distanceFee: distanceFee,
        weightSurcharge: weightSurch,
        materialFee: materialFee,
        urgencyBonus: urgency,
        grossFee: grossFee,
        platformCut: platformCut,
        driverPayout: driverPayout,
        totalJd: driverPayout,
        needsManualReview: needsManualReview,
      ),
    );
  }
}
