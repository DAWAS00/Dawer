import 'order.dart';

/// Extension for serializing/deserializing Orders to/from Supabase tables.
extension OrderSupabaseExt on Order {
  Map<String, dynamic> toSupabaseMap(String? activeUserId) {
    return {
      if (id.length == 36) 'id': id, // Only pass id if it's a UUID, Supabase auto-generates if omitted. Our mock uses 'ORD-xxx'
      'type': type.name, // ENUM
      'status': status.name,
      'supplier_id': activeUserId,
      'waste_types': wasteTypes.map((e) => e.name).toList(),
      if (wasteForm != null) 'waste_form': wasteForm!.name,
      if (weightCategory != null) 'weight_category': weightCategory!.name,
      if (pickupTarget != null) 'pickup_target': pickupTarget!.name,
      // Provide dummy point if no location
      'pickup_location': pickupLat != null && pickupLng != null 
          ? 'POINT($pickupLng $pickupLat)' 
          : 'POINT(35.9106 31.9539)', 
      if (dropoffLat != null && dropoffLng != null) 'dropoff_location': 'POINT($dropoffLng $dropoffLat)',
      if (estimatedWeightKg != null) 'estimated_weight_kg': estimatedWeightKg,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (reward > 0) 'reward_jd': reward,
      // 'is_urgent' boolean mapping if implemented
      if (supplierNotes != null) 'notes': supplierNotes,
      'is_marketplace_shared': isMarketplaceShared,
    };
  }
}

Order orderFromSupabaseJson(Map<String, dynamic> json) {
  T parseEnum<T extends Enum>(String? name, List<T> values, T fallback) {
    if (name == null) return fallback;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  T? parseEnumN<T extends Enum>(String? name, List<T> values) {
    if (name == null) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  DateTime? parseDt(String? s) => s == null ? null : DateTime.tryParse(s);

  return Order(
    id: json['id'] as String,
    type: parseEnum(json['type'] as String?, OrderType.values, OrderType.pickup),
    wasteTypes: ((json['waste_types'] as List?) ?? [])
        .map((n) => parseEnumN(n.toString(), WasteType.values))
        .whereType<WasteType>()
        .toList(),
    pickupAddress: 'موقع السحب المختار', // Needs reverse geo or ignore
    dropoffAddress: '', // Needs reverse geo or ignore
    status: parseEnum(
      json['status'] as String?,
      OrderStatus.values,
      OrderStatus.pending,
    ),
    reward: (json['reward_jd'] as num?)?.toDouble() ?? 0,
    createdAt: parseDt(json['created_at'] as String?) ?? DateTime.now(),
    acceptedAt: parseDt(json['accepted_at'] as String?),
    completedAt: parseDt(json['completed_at'] as String?),
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
    supplierNotes: json['notes'] as String?,
    estimatedWeightKg: (json['estimated_weight_kg'] as num?)?.toDouble(),
    wasteForm: parseEnumN(json['waste_form'] as String?, WasteForm.values),
    weightCategory: parseEnumN(json['weight_category'] as String?, WeightCategory.values),
    pickupTarget: parseEnumN(json['pickup_target'] as String?, PickupTarget.values),
    isMarketplaceShared: json['is_marketplace_shared'] as bool? ?? false,
  );
}
