/// Reward breakdown shape shared by the local reward calculation flow.
///
/// Field names match the persisted JSON payload used by app data models.
class RewardBreakdown {
  final double baseFee;
  final double distanceFee;
  final double materialFee;
  final double urgencyBonus;
  final double totalJd;
  final bool needsManualReview;

  const RewardBreakdown({
    required this.baseFee,
    required this.distanceFee,
    required this.materialFee,
    required this.urgencyBonus,
    required this.totalJd,
    this.needsManualReview = false,
  });

  /// All zeros — used as a safe fallback when calculation fails and the
  /// UI still needs a concrete number.
  static const RewardBreakdown zero = RewardBreakdown(
    baseFee: 0,
    distanceFee: 0,
    materialFee: 0,
    urgencyBonus: 0,
    totalJd: 0,
  );

  factory RewardBreakdown.fromJson(Map<String, dynamic> json) {
    double d(Object? v) => v is num ? v.toDouble() : 0.0;
    return RewardBreakdown(
      baseFee: d(json['base_fee']),
      distanceFee: d(json['distance_fee']),
      materialFee: d(json['material_fee']),
      urgencyBonus: d(json['urgency_bonus']),
      totalJd: d(json['total_jd']),
      needsManualReview: json['needs_manual_review'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'base_fee': baseFee,
        'distance_fee': distanceFee,
        'material_fee': materialFee,
        'urgency_bonus': urgencyBonus,
        'total_jd': totalJd,
        if (needsManualReview) 'needs_manual_review': true,
      };

  @override
  String toString() =>
      'RewardBreakdown(total: $totalJd, base: $baseFee, dist: $distanceFee, '
      'material: $materialFee, urgency: $urgencyBonus'
      '${needsManualReview ? ', needsReview' : ''})';
}
