enum ReservationStatus {
  pendingApproval,
  reserved,
  completed,
  cancelled,
  expiredBuyerPenalized,
  cancelledSellerPenalized,
}

extension ReservationStatusDb on ReservationStatus {
  static ReservationStatus fromDb(String value) => switch (value) {
    'pending_approval' => ReservationStatus.pendingApproval,
    'reserved' => ReservationStatus.reserved,
    'completed' => ReservationStatus.completed,
    'cancelled' => ReservationStatus.cancelled,
    'expired_buyer_penalized' => ReservationStatus.expiredBuyerPenalized,
    'cancelled_seller_penalized' => ReservationStatus.cancelledSellerPenalized,
    _ => throw ArgumentError('Unknown reservation status: $value'),
  };

  String get label => switch (this) {
    ReservationStatus.pendingApproval => 'بانتظار موافقة المشتري',
    ReservationStatus.reserved => 'محجوز',
    ReservationStatus.completed => 'مكتمل',
    ReservationStatus.cancelled => 'ملغى',
    ReservationStatus.expiredBuyerPenalized =>
      'انتهى الوقت — غرامة على المشتري',
    ReservationStatus.cancelledSellerPenalized =>
      'ألغاه البائع — غرامة على البائع',
  };

  bool get isOpen =>
      this == ReservationStatus.pendingApproval ||
      this == ReservationStatus.reserved;
}

class Reservation {
  final String id;
  final String sellerId;
  final String buyerId;
  final String itemTitle;
  final double invoiceTotal;
  final int durationMinutes;
  final ReservationStatus status;
  final double? penaltyAmount;
  final String? penaltyParty;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? deadline;
  final DateTime? resolvedAt;

  const Reservation({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.itemTitle,
    required this.invoiceTotal,
    required this.durationMinutes,
    required this.status,
    this.penaltyAmount,
    this.penaltyParty,
    this.cancelReason,
    required this.createdAt,
    this.approvedAt,
    this.deadline,
    this.resolvedAt,
  });

  double get penaltyPreview =>
      double.parse((invoiceTotal * 0.10).toStringAsFixed(2));

  Duration? get timeRemaining {
    if (deadline == null) return null;
    final remaining = deadline!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isExpired => deadline != null && DateTime.now().isAfter(deadline!);

  factory Reservation.fromJson(Map<String, dynamic> json) {
    double? d(Object? v) => v == null ? null : (v as num).toDouble();
    DateTime? dt(Object? v) => v == null ? null : DateTime.parse(v as String);

    return Reservation(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      buyerId: json['buyer_id'] as String,
      itemTitle: json['item_title'] as String,
      invoiceTotal: d(json['invoice_total'])!,
      durationMinutes: json['duration_minutes'] as int,
      status: ReservationStatusDb.fromDb(json['status'] as String),
      penaltyAmount: d(json['penalty_amount']),
      penaltyParty: json['penalty_party'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      createdAt: dt(json['created_at'])!,
      approvedAt: dt(json['approved_at']),
      deadline: dt(json['deadline']),
      resolvedAt: dt(json['resolved_at']),
    );
  }
}
