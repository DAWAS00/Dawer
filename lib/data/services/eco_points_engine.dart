import '../models/eco_badge.dart';
import '../models/order.dart' show WasteType;

/// Configurable points-per-kg rates by waste type.
const Map<WasteType, double> _pointRates = {
  WasteType.oil:             10.0, // premium — cooking oil
  WasteType.copperAluminium: 8.0,
  WasteType.electronics:     7.0,
  WasteType.batteries:       7.0,
  WasteType.chemicals:       6.0,
  WasteType.metal:           5.0,
  WasteType.plastic:         4.0,
  WasteType.glass:           3.0,
  WasteType.paper:           3.0,
  WasteType.wood:            3.0,
  WasteType.rubber:          2.0,
  WasteType.tires:           2.0,
  WasteType.textile:         2.0,
  WasteType.construction:    2.0,
  WasteType.furniture:       2.0,
  WasteType.organic:         1.0,
};

const double _defaultPointsPerKg = 5.0;

/// Stateless engine for the Dawer supplier eco-points & badge system.
///
/// All methods are pure — no state, no Supabase calls. Wire real data in
/// when Supabase is connected; the logic stays identical.
class EcoPointsEngine {
  const EcoPointsEngine._();

  /// Points earned for collecting [weightKg] of [wasteType].
  static double pointsForCollection({
    required double weightKg,
    WasteType wasteType = WasteType.oil,
  }) {
    final rate = _pointRates[wasteType] ?? _defaultPointsPerKg;
    return (weightKg * rate).roundToDouble();
  }

  /// Rate in points-per-kg for the given waste type.
  static double rateFor(WasteType type) =>
      _pointRates[type] ?? _defaultPointsPerKg;

  /// Derive approximate lifetime kg from accumulated points.
  ///
  /// Used when explicit kg data is unavailable (treats all as oil rate).
  static double lifetimeKgFromPoints(int totalPoints) =>
      totalPoints / (_pointRates[WasteType.oil] ?? 10.0);

  /// All badges the supplier has earned based on [lifetimeKg] and
  /// [completedOrders]. Returns earned badges only.
  static List<EcoBadge> earnedBadges({
    required double lifetimeKg,
    required int completedOrders,
  }) =>
      EcoBadge.all
          .where((b) => b.isEarned(
              lifetimeKg: lifetimeKg, completedOrders: completedOrders))
          .toList();

  /// Returns true when the user has earned the Eco Hero badge (100 kg).
  static bool isEcoHero(double lifetimeKg) => lifetimeKg >= 100;

  /// JOD fuel credit a driver earns per completed delivery.
  static const double fuelCreditPerDelivery = 0.05;

  /// Total fuel credit earned by a driver given completed delivery count.
  static double driverFuelCredit(int completedDeliveries) =>
      completedDeliveries * fuelCreditPerDelivery;

  /// Amman neighborhood leaderboard — kg recycled per district.
  ///
  /// In production this would be a Supabase aggregate query:
  ///   SELECT district, SUM(estimated_weight_kg) FROM orders
  ///   WHERE status='completed' GROUP BY district ORDER BY sum DESC
  ///
  /// For the demo, seeded with realistic Amman data.
  static List<LeaderboardEntry> neighborhoodLeaderboard() => const [
        LeaderboardEntry('الصويفية',   '🏆', 482),
        LeaderboardEntry('عبدون',      '🥈', 391),
        LeaderboardEntry('الرابية',    '🥉', 347),
        LeaderboardEntry('شميساني',    '4️⃣',  298),
        LeaderboardEntry('دابوق',      '5️⃣',  261),
        LeaderboardEntry('الجاردنز',   '6️⃣',  233),
        LeaderboardEntry('جبل عمان',   '7️⃣',  198),
        LeaderboardEntry('خلدا',       '8️⃣',  175),
        LeaderboardEntry('ام الحيران', '9️⃣',  142),
        LeaderboardEntry('الميدان',    '🔟', 118),
      ];

  /// Partner discount coupons unlocked at points milestones.
  static const List<DiscountCoupon> coupons = [
    DiscountCoupon(
      title: 'خصم 10% — سيفواي',
      description: 'خصم على مشترياتك التالية في سوبرماركت سيفواي',
      code: 'DAWER10',
      pointsRequired: 100,
      iconEmoji: '🛒',
      color: 0xFF0369A1,
    ),
    DiscountCoupon(
      title: 'توصيل مجاني',
      description: 'توصيل مجاني على طلبك القادم في دوّر',
      code: 'FREEDEL',
      pointsRequired: 200,
      iconEmoji: '🚚',
      color: 0xFF166534,
    ),
    DiscountCoupon(
      title: 'خصم 15% — مطاعم تاج مول',
      description: 'خصم على الفاتورة في أي مطعم داخل تاج مول',
      code: 'TAJMEAL15',
      pointsRequired: 300,
      iconEmoji: '🍽️',
      color: 0xFFB45309,
    ),
    DiscountCoupon(
      title: 'كوبون وقود 5 دينار',
      description: 'رصيد وقود بقيمة 5 دينار أردني في محطات الوقود الشريكة',
      code: 'FUEL5JD',
      pointsRequired: 500,
      iconEmoji: '⛽',
      color: 0xFF7C3AED,
    ),
  ];
}

class LeaderboardEntry {
  final String district;
  final String medal;
  final int kgCollected;

  const LeaderboardEntry(this.district, this.medal, this.kgCollected);
}

class DiscountCoupon {
  final String title;
  final String description;
  final String code;
  final int pointsRequired;
  final String iconEmoji;
  final int color; // ARGB int for const compat

  const DiscountCoupon({
    required this.title,
    required this.description,
    required this.code,
    required this.pointsRequired,
    required this.iconEmoji,
    required this.color,
  });
}
