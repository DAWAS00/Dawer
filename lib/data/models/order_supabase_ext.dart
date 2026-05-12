import 'order.dart';

/// Extension for serializing/deserializing Orders to/from Supabase tables.
extension OrderSupabaseExt on Order {
  Map<String, dynamic> toSupabaseMap(String? activeUserId) {
    return {
      if (id.length == 36) 'id': id, // Only pass id if it's a UUID, Supabase auto-generates if omitted. Our mock uses 'ORD-xxx'
      'type': type.name, // ENUM
      'status': status.name,
      if (type == OrderType.collection) 'company_id': activeUserId else 'supplier_id': activeUserId,
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
      'requires_rider': requiresRider,
      if (linkedJobId != null) 'linked_job_id': linkedJobId,
      if (collectionDeliveryMethod != null) 'collection_delivery_method': collectionDeliveryMethod!.name,
      if (collectionTransactionType != null) 'collection_transaction_type': collectionTransactionType!.name,
      if (jobDescription != null) 'job_description': jobDescription,
      if (paymentModel != null) 'payment_model': paymentModel!.name,
      if (pricePerKg != null) 'price_per_kg': pricePerKg,
      if (itemPrice != null) 'item_price': itemPrice,
      if (minQuantityKg != null) 'min_quantity_kg': minQuantityKg,
      if (weightKg != null) 'actual_weight_kg': weightKg,
    };
  }
}

/// Parses a PostGIS POINT string `'POINT(lng lat)'` into `(lat, lng)`.
/// Returns null when the string is absent or unparseable.
(double lat, double lng)? _parsePoint(String? point) {
  if (point == null) return null;
  final inner = point.replaceAll('POINT(', '').replaceAll(')', '').trim();
  final parts = inner.split(' ');
  if (parts.length != 2) return null;
  final lng = double.tryParse(parts[0]);
  final lat = double.tryParse(parts[1]);
  if (lat == null || lng == null) return null;
  return (lat, lng);
}

/// Formats coordinates into a human-readable string.
/// Shown until a reverse-geocoding service is added (Fix 3 TODO).
String _coordsLabel(double lat, double lng) =>
    '${lat.toStringAsFixed(4)}°N, ${lng.toStringAsFixed(4)}°E';

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

  final pickup = _parsePoint(json['pickup_location'] as String?);
  final dropoff = _parsePoint(json['dropoff_location'] as String?);
  final pickupAddr = json['pickup_address_text'] as String? ??
      (pickup != null ? _coordsLabel(pickup.$1, pickup.$2) : '—');
  final dropoffAddr = json['dropoff_address_text'] as String? ??
      (dropoff != null ? _coordsLabel(dropoff.$1, dropoff.$2) : '');

  return Order(
    id: json['id'] as String,
    type: parseEnum(json['type'] as String?, OrderType.values, OrderType.pickup),
    wasteTypes: ((json['waste_types'] as List?) ?? [])
        .map((n) => parseEnumN(n.toString(), WasteType.values))
        .whereType<WasteType>()
        .toList(),
    pickupAddress: pickupAddr,
    dropoffAddress: dropoffAddr,
    pickupLat: pickup?.$1,
    pickupLng: pickup?.$2,
    dropoffLat: dropoff?.$1,
    dropoffLng: dropoff?.$2,
    status: parseEnum(
      json['status'] as String?,
      OrderStatus.values,
      OrderStatus.pending,
    ),
    reward: (json['reward_jd'] as num?)?.toDouble() ?? 0,
    createdAt: parseDt(json['created_at'] as String?) ?? DateTime.now(),
    acceptedAt: parseDt(json['accepted_at'] as String?),
    inTransitAt: parseDt(json['in_transit_at'] as String?),
    completedAt: parseDt(json['completed_at'] as String?),
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
    supplierNotes: json['notes'] as String?,
    estimatedWeightKg: (json['estimated_weight_kg'] as num?)?.toDouble(),
    wasteForm: parseEnumN(json['waste_form'] as String?, WasteForm.values),
    weightCategory: parseEnumN(json['weight_category'] as String?, WeightCategory.values),
    pickupTarget: parseEnumN(json['pickup_target'] as String?, PickupTarget.values),
    isMarketplaceShared: json['is_marketplace_shared'] as bool? ?? false,
    requiresRider: json['requires_rider'] as bool? ?? false,
    linkedJobId: json['linked_job_id'] as String?,
    collectionDeliveryMethod: parseEnumN(json['collection_delivery_method'] as String?, CollectionDeliveryMethod.values),
    collectionTransactionType: parseEnumN(json['collection_transaction_type'] as String?, CollectionTransactionType.values),
    jobDescription: json['job_description'] as String?,
    paymentModel: parseEnumN(json['payment_model'] as String?, PaymentModel.values),
    pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
    itemPrice: (json['item_price'] as num?)?.toDouble(),
    minQuantityKg: (json['min_quantity_kg'] as num?)?.toDouble(),
    weightKg: (json['actual_weight_kg'] as num?)?.toDouble(),
  );
}
