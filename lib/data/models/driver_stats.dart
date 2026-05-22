class DriverStats {
  final String driverId;
  final int noShowCount;
  final int fraudAttemptCount;
  final int lateArrivalCount;
  final int totalOrders;
  final int cancelledOrders;

  const DriverStats({
    required this.driverId,
    this.noShowCount = 0,
    this.fraudAttemptCount = 0,
    this.lateArrivalCount = 0,
    this.totalOrders = 0,
    this.cancelledOrders = 0,
  });

  double get cancellationRate =>
      totalOrders == 0 ? 0.0 : cancelledOrders / totalOrders;

  /// True when the driver has crossed thresholds that warrant manual review.
  /// 3+ no-shows, 2+ fraud attempts, or >30% cancellation rate.
  bool get isHighRisk =>
      noShowCount >= 3 || fraudAttemptCount >= 2 || cancellationRate > 0.30;

  DriverStats copyWith({
    int? noShowCount,
    int? fraudAttemptCount,
    int? lateArrivalCount,
    int? totalOrders,
    int? cancelledOrders,
  }) =>
      DriverStats(
        driverId: driverId,
        noShowCount: noShowCount ?? this.noShowCount,
        fraudAttemptCount: fraudAttemptCount ?? this.fraudAttemptCount,
        lateArrivalCount: lateArrivalCount ?? this.lateArrivalCount,
        totalOrders: totalOrders ?? this.totalOrders,
        cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      );
}
