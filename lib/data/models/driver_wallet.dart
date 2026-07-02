class DriverWallet {
  final double balance;
  final double heldAmount;

  const DriverWallet({required this.balance, required this.heldAmount});

  static const zero = DriverWallet(balance: 0, heldAmount: 0);

  factory DriverWallet.fromJson(Map<String, dynamic> json) {
    double d(Object? v) => v is num ? v.toDouble() : 0.0;
    return DriverWallet(
      balance: d(json['balance']),
      heldAmount: d(json['held_amount']),
    );
  }

  double get total => balance + heldAmount;
}
