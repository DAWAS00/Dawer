import '../../data/models/order_enums.dart';

/// Pure domain service — no Flutter imports, no state.
/// Calculates estimated kg of CO₂ emissions avoided by diverting waste from
/// landfill, based on IPCC AR6 default emission factors.
abstract final class CarbonCalculator {
  // kg CO₂ avoided per kg of waste diverted
  static const Map<WasteType, double> _kgCo2PerKg = {
    WasteType.metal: 1.80,
    WasteType.plastic: 1.50,
    WasteType.paper: 1.10,
    WasteType.glass: 0.30,
    WasteType.oil: 2.20,
    WasteType.electronics: 2.00,
    WasteType.batteries: 1.60,
    WasteType.rubber: 1.20,
    WasteType.tires: 1.10,
    WasteType.organic: 0.50,
    WasteType.textile: 0.90,
    WasteType.wood: 0.70,
    WasteType.chemicals: 1.40,
    WasteType.construction: 0.35,
    WasteType.furniture: 0.65,
  };

  static const double _defaultRate = 0.80;

  /// Returns kg CO₂ avoided for a single [wasteType] at a given [weightKg].
  static double savedKgCo2(WasteType wasteType, double weightKg) {
    final rate = _kgCo2PerKg[wasteType] ?? _defaultRate;
    return weightKg * rate;
  }

  /// Sums CO₂ savings across multiple waste types (equal weight share assumed).
  static double savedKgCo2Multi(List<WasteType> types, double weightKg) {
    if (types.isEmpty || weightKg <= 0) return 0;
    final share = weightKg / types.length;
    return types.fold(0.0, (sum, t) => sum + savedKgCo2(t, share));
  }

  /// Human-readable label, e.g. '12.4 كغ CO₂' or '1.2 طن CO₂'.
  static String label(double kgCo2) {
    if (kgCo2 >= 1000) {
      return '${(kgCo2 / 1000).toStringAsFixed(1)} طن CO₂';
    }
    return '${kgCo2.toStringAsFixed(1)} كغ CO₂';
  }
}
