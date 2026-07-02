class RewardBreakdown {
  final double baseFee;
  final double distanceFee;
  final double weightSurcharge;
  final double materialFee;
  final double urgencyBonus;
  final double grossFee;
  final double platformCut;
  final double driverPayout;
  final double totalJd; // equals driverPayout — kept for backward compat
  final bool needsManualReview;

  double get base => baseFee;
  double get distance => distanceFee;
  double get material => materialFee;
  double get urgency => urgencyBonus;

  const RewardBreakdown({
    required this.baseFee,
    required this.distanceFee,
    required this.materialFee,
    required this.urgencyBonus,
    required this.totalJd,
    this.weightSurcharge = 0,
    this.grossFee = 0,
    this.platformCut = 0,
    this.driverPayout = 0,
    this.needsManualReview = false,
  });

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
      weightSurcharge: d(json['weight_surcharge']),
      materialFee: d(json['material_fee']),
      urgencyBonus: d(json['urgency_bonus']),
      grossFee: d(json['gross_fee']),
      platformCut: d(json['platform_cut']),
      driverPayout: d(json['driver_payout']),
      totalJd: d(json['total_jd']),
      needsManualReview: json['needs_manual_review'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'base_fee': baseFee,
    'distance_fee': distanceFee,
    'weight_surcharge': weightSurcharge,
    'material_fee': materialFee,
    'urgency_bonus': urgencyBonus,
    'gross_fee': grossFee,
    'platform_cut': platformCut,
    'driver_payout': driverPayout,
    'total_jd': totalJd,
    if (needsManualReview) 'needs_manual_review': true,
  };

  @override
  String toString() =>
      'RewardBreakdown(payout: $driverPayout, gross: $grossFee, '
      'base: $baseFee, dist: $distanceFee, weight: $weightSurcharge, '
      'material: $materialFee, urgency: $urgencyBonus, cut: $platformCut'
      '${needsManualReview ? ', needsReview' : ''})';
}
