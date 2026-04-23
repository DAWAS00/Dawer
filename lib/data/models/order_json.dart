import 'order.dart';

/// JSON serialization helpers for [Order]. Kept separate from the model so
/// the core class stays free of persistence concerns.
extension OrderJson on Order {
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type.name,
        'wasteTypes': wasteTypes.map((e) => e.name).toList(),
        'pickupAddress': pickupAddress,
        'dropoffAddress': dropoffAddress,
        'status': status.name,
        if (driverName != null) 'driverName': driverName,
        if (driverPhone != null) 'driverPhone': driverPhone,
        if (driverRating != null) 'driverRating': driverRating,
        if (driverVehicle != null) 'driverVehicle': driverVehicle,
        if (driverVehicleModel != null) 'driverVehicleModel': driverVehicleModel,
        if (driverVehicleColor != null) 'driverVehicleColor': driverVehicleColor,
        if (driverLicensePlate != null) 'driverLicensePlate': driverLicensePlate,
        if (driverVehiclePhotoPath != null)
          'driverVehiclePhotoPath': driverVehiclePhotoPath,
        if (supplierName != null) 'supplierName': supplierName,
        'reward': reward,
        if (weightKg != null) 'weightKg': weightKg,
        'createdAt': createdAt.toIso8601String(),
        if (acceptedAt != null) 'acceptedAt': acceptedAt!.toIso8601String(),
        if (inTransitAt != null) 'inTransitAt': inTransitAt!.toIso8601String(),
        if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
        if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
        if (eta != null) 'eta': eta,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (proofImagePath != null) 'proofImagePath': proofImagePath,
        if (paidAmount != null) 'paidAmount': paidAmount,
        if (supplierNotes != null) 'supplierNotes': supplierNotes,
        'images': images,
        if (estimatedWeightKg != null) 'estimatedWeightKg': estimatedWeightKg,
        if (wasteForm != null) 'wasteForm': wasteForm!.name,
        if (weightCategory != null) 'weightCategory': weightCategory!.name,
        if (deliveryFee != null) 'deliveryFee': deliveryFee,
        if (pickupTarget != null) 'pickupTarget': pickupTarget!.name,
        if (itemPrice != null) 'itemPrice': itemPrice,
        if (jobDescription != null) 'jobDescription': jobDescription,
        if (pricePerKg != null) 'pricePerKg': pricePerKg,
        if (paymentModel != null) 'paymentModel': paymentModel!.name,
        if (minQuantityKg != null) 'minQuantityKg': minQuantityKg,
        'isEdited': isEdited,
        if (editedAt != null) 'editedAt': editedAt!.toIso8601String(),
        if (editNote != null) 'editNote': editNote,
        if (linkedJobId != null) 'linkedJobId': linkedJobId,
        if (collectionDeliveryMethod != null)
          'collectionDeliveryMethod': collectionDeliveryMethod!.name,
        if (collectionTransactionType != null)
          'collectionTransactionType': collectionTransactionType!.name,
        if (pickupLat != null) 'pickupLat': pickupLat,
        if (pickupLng != null) 'pickupLng': pickupLng,
        if (dropoffLat != null) 'dropoffLat': dropoffLat,
        if (dropoffLng != null) 'dropoffLng': dropoffLng,
        if (etaMinutes != null) 'etaMinutes': etaMinutes,
        'isMarketplaceShared': isMarketplaceShared,
      };
}

/// Decodes an [Order] from [json]. Unknown enum values fall back to a safe
/// default (e.g. `pending`) so a corrupt/outdated payload never crashes the
/// store.
Order orderFromJson(Map<String, dynamic> json) {
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
    wasteTypes: ((json['wasteTypes'] as List?) ?? const [])
        .whereType<String>()
        .map((n) => parseEnumN(n, WasteType.values))
        .whereType<WasteType>()
        .toList(),
    pickupAddress: json['pickupAddress'] as String? ?? '',
    dropoffAddress: json['dropoffAddress'] as String? ?? '',
    status: parseEnum(
      json['status'] as String?,
      OrderStatus.values,
      OrderStatus.pending,
    ),
    driverName: json['driverName'] as String?,
    driverPhone: json['driverPhone'] as String?,
    driverRating: (json['driverRating'] as num?)?.toDouble(),
    driverVehicle: json['driverVehicle'] as String?,
    driverVehicleModel: json['driverVehicleModel'] as String?,
    driverVehicleColor: json['driverVehicleColor'] as String?,
    driverLicensePlate: json['driverLicensePlate'] as String?,
    driverVehiclePhotoPath: json['driverVehiclePhotoPath'] as String?,
    supplierName: json['supplierName'] as String?,
    reward: (json['reward'] as num?)?.toDouble() ?? 0,
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    createdAt: parseDt(json['createdAt'] as String?) ?? DateTime.now(),
    acceptedAt: parseDt(json['acceptedAt'] as String?),
    inTransitAt: parseDt(json['inTransitAt'] as String?),
    completedAt: parseDt(json['completedAt'] as String?),
    scheduledAt: parseDt(json['scheduledAt'] as String?),
    eta: json['eta'] as String?,
    distanceKm: (json['distanceKm'] as num?)?.toDouble(),
    proofImagePath: json['proofImagePath'] as String?,
    paidAmount: (json['paidAmount'] as num?)?.toDouble(),
    supplierNotes: json['supplierNotes'] as String?,
    images: ((json['images'] as List?) ?? const [])
        .whereType<String>()
        .toList(),
    estimatedWeightKg: (json['estimatedWeightKg'] as num?)?.toDouble(),
    wasteForm: parseEnumN(json['wasteForm'] as String?, WasteForm.values),
    weightCategory:
        parseEnumN(json['weightCategory'] as String?, WeightCategory.values),
    deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
    pickupTarget: parseEnumN(json['pickupTarget'] as String?, PickupTarget.values),
    itemPrice: (json['itemPrice'] as num?)?.toDouble(),
    jobDescription: json['jobDescription'] as String?,
    pricePerKg: (json['pricePerKg'] as num?)?.toDouble(),
    paymentModel: parseEnumN(json['paymentModel'] as String?, PaymentModel.values),
    minQuantityKg: (json['minQuantityKg'] as num?)?.toDouble(),
    isEdited: json['isEdited'] as bool? ?? false,
    editedAt: parseDt(json['editedAt'] as String?),
    editNote: json['editNote'] as String?,
    linkedJobId: json['linkedJobId'] as String?,
    collectionDeliveryMethod: parseEnumN(
      json['collectionDeliveryMethod'] as String?,
      CollectionDeliveryMethod.values,
    ),
    collectionTransactionType: parseEnumN(
      json['collectionTransactionType'] as String?,
      CollectionTransactionType.values,
    ),
    pickupLat: (json['pickupLat'] as num?)?.toDouble(),
    pickupLng: (json['pickupLng'] as num?)?.toDouble(),
    dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
    dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
    etaMinutes: (json['etaMinutes'] as num?)?.toInt(),
    isMarketplaceShared: json['isMarketplaceShared'] as bool? ?? false,
  );
}
