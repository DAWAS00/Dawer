import 'order/order.dart';

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
      // PostgREST cannot cast WKT text → geography, so we write plain numeric
      // lat/lng columns; a DB trigger (00004_postgis_compat.sql) populates the
      // `pickup_location` geography column from these. If both are null, the
      // column default (Amman) applies.
      if (pickupLat != null) 'pickup_lat': pickupLat,
      if (pickupLng != null) 'pickup_lng': pickupLng,
      if (dropoffLat != null) 'dropoff_lat': dropoffLat,
      if (dropoffLng != null) 'dropoff_lng': dropoffLng,
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
      if (arrivedAtPickupAt != null) 'arrived_at_pickup_at': arrivedAtPickupAt!.toUtc().toIso8601String(),
      if (arrivedAtDropoffAt != null) 'arrived_at_dropoff_at': arrivedAtDropoffAt!.toUtc().toIso8601String(),
      if (arrivalConfirmationStatus != null) 'arrival_confirmation_status': arrivalConfirmationStatus!.name,
      if (supplierHoldAmount != null) 'supplier_hold_amount': supplierHoldAmount,
      if (driverCompensationAmount != null) 'driver_compensation_amount': driverCompensationAmount,
      if (fraudAttemptCount > 0) 'fraud_attempt_count': fraudAttemptCount,
      if (weightVarianceFlag) 'weight_variance_flag': true,
      if (requiredVehicleType != null) 'required_vehicle_type': requiredVehicleType!.name,
      if (requiresChemicalPermit) 'requires_chemical_permit': true,
      if (adminApprovalStatus != AdminApprovalStatus.notRequired)
        'admin_approval_status': adminApprovalStatus.name,
      if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
      if (isVatApplicable) 'is_vat_applicable': true,
      if (vatAmountJd != null) 'vat_amount_jd': vatAmountJd,
      if (proof != null) ...{
        'proof_image_path': proof!.imagePath,
        'proof_captured_at': proof!.capturedAt.toUtc().toIso8601String(),
        'proof_lat': proof!.lat,
        'proof_lng': proof!.lng,
        'proof_checksum': proof!.checksum,
      },
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
    supplierId: json['supplier_id'] as String?,
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
    inTransitAt: parseDt(json['in_transit_at'] as String?),
    completedAt: parseDt(json['completed_at'] as String?),
    distanceKm: (json['distance_km'] as num?)?.toDouble(),
    supplierNotes: json['notes'] as String?,
    estimatedWeightKg: (json['estimated_weight_kg'] as num?)?.toDouble(),
    pickupLat: (json['pickup_lat'] as num?)?.toDouble(),
    pickupLng: (json['pickup_lng'] as num?)?.toDouble(),
    dropoffLat: (json['dropoff_lat'] as num?)?.toDouble(),
    dropoffLng: (json['dropoff_lng'] as num?)?.toDouble(),
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
    requiredVehicleType: parseEnumN(json['required_vehicle_type'] as String?, VehicleType.values),
    requiresChemicalPermit: json['requires_chemical_permit'] as bool? ?? false,
    adminApprovalStatus: parseEnum(
      json['admin_approval_status'] as String?,
      AdminApprovalStatus.values,
      AdminApprovalStatus.notRequired,
    ),
    expiresAt: parseDt(json['expires_at'] as String?),
    isVatApplicable: json['is_vat_applicable'] as bool? ?? false,
    vatAmountJd: (json['vat_amount_jd'] as num?)?.toDouble(),
  );
}
