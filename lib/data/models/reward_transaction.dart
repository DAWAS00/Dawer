enum RewardTransactionType { earned, redeemed, bonus }

extension RewardTransactionTypeLabel on RewardTransactionType {
  String get label => switch (this) {
    RewardTransactionType.earned => 'مكسبة',
    RewardTransactionType.redeemed => 'مُستبدلة',
    RewardTransactionType.bonus => 'مكافأة',
  };

  bool get isPositive => this != RewardTransactionType.redeemed;
}

class RewardTransaction {
  final String id;
  final RewardTransactionType type;
  final int points;
  final String description;
  final DateTime createdAt;
  final String? linkedOrderId;

  const RewardTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
    this.linkedOrderId,
  });
}
