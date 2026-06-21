import 'dart:io';

import '../../data/models/order/order.dart';

class CreatePickupRequest {
  final String supplierId;
  final List<WasteType> wasteTypes;
  final WasteForm wasteForm;
  final WeightCategory weightCategory;
  final String pickupAddress;
  final String? notes;
  final List<File> photoFiles;
  final List<String> images;
  final double? estimatedWeightKg;
  final PickupTarget? pickupTarget;
  final double? itemPrice;
  final DateTime? scheduledAt;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final bool isUrgent;

  const CreatePickupRequest({
    required this.supplierId,
    required this.wasteTypes,
    required this.wasteForm,
    required this.weightCategory,
    required this.pickupAddress,
    this.notes,
    this.photoFiles = const [],
    this.images = const [],
    this.estimatedWeightKg,
    this.pickupTarget,
    this.itemPrice,
    this.scheduledAt,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.isUrgent = false,
  });
}
