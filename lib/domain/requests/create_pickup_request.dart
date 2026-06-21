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
  final bool isUrgent;

  const CreatePickupRequest({
    required this.supplierId,
    required this.wasteTypes,
    required this.wasteForm,
    required this.weightCategory,
    required this.pickupAddress,
    this.notes,
    this.photoFiles = const [],
    this.isUrgent = false,
  });
}
