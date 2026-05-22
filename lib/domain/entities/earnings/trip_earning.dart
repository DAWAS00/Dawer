class TripEarning {
  final String orderId;
  final DateTime date;
  final double amount;
  final double distanceKm;
  final String pickupAddress;
  final String dropoffAddress;

  const TripEarning({
    required this.orderId,
    required this.date,
    required this.amount,
    required this.distanceKm,
    required this.pickupAddress,
    required this.dropoffAddress,
  });
}
