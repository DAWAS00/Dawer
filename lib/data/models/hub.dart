/// A physical collection point managed by the admin dashboard.
/// Drivers use hub locations as dropoff targets.
class Hub {
  const Hub({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.active,
    required this.capacityKg,
    required this.currentLoad,
    required this.schedule,
    required this.nextShipmentDate,
    required this.lastShipmentDate,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool active;
  final double capacityKg;
  final Map<String, dynamic> currentLoad;
  final String schedule; // 'weekly' | 'monthly'
  final String? nextShipmentDate; // ISO date string or null
  final String? lastShipmentDate; // ISO date string or null
  final String status; // 'collecting' | 'ready' | 'shipped'
  final DateTime createdAt;

  factory Hub.fromJson(Map<String, dynamic> json) {
    return Hub(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      active: json['active'] as bool,
      capacityKg: (json['capacity_kg'] as num).toDouble(),
      currentLoad: Map<String, dynamic>.from(
        (json['current_load'] as Map?) ?? {},
      ),
      schedule: json['schedule'] as String,
      nextShipmentDate: json['next_shipment_date'] as String?,
      lastShipmentDate: json['last_shipment_date'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
