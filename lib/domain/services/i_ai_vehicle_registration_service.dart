import '../../data/models/order/order.dart' show VehicleType;

class ExtractedVehicleData {
  final VehicleType vehicleType;
  final String vehicleClass; // raw Arabic from registration e.g. "بيك آب"
  final String? make; // e.g. "تويوتا"
  final String? model; // e.g. "هايلوكس"
  final String? color; // e.g. "أبيض"
  final String? plateNumber; // e.g. "11 - 12345"
  final DateTime? registrationExpiry;
  final double confidenceScore;
  final bool hasChemicalPermit;

  const ExtractedVehicleData({
    required this.vehicleType,
    required this.vehicleClass,
    required this.confidenceScore,
    this.make,
    this.model,
    this.color,
    this.plateNumber,
    this.registrationExpiry,
    this.hasChemicalPermit = false,
  });
}

class VehicleRegistrationResult {
  final bool isValid;
  final ExtractedVehicleData? data;
  final String? failReason;

  const VehicleRegistrationResult.success(ExtractedVehicleData this.data)
    : isValid = true,
      failReason = null;

  const VehicleRegistrationResult.failure(String this.failReason)
    : isValid = false,
      data = null;
}

abstract class IAiVehicleRegistrationService {
  Future<VehicleRegistrationResult> extractVehicleData(String filePath);
}
