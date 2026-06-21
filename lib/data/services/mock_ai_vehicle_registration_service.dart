import '../../data/models/order/order.dart' show VehicleType;
import '../../domain/services/i_ai_vehicle_registration_service.dart';

class MockAiVehicleRegistrationService implements IAiVehicleRegistrationService {
  static final _mockResults = [
    ExtractedVehicleData(
      vehicleType: VehicleType.pickup,
      vehicleClass: 'بيك آب',
      make: 'تويوتا',
      model: 'هايلوكس',
      color: 'أبيض',
      plateNumber: '11 - 12345',
      registrationExpiry: DateTime(2027, 3, 15),
      confidenceScore: 0.967,
      hasChemicalPermit: false,
    ),
    ExtractedVehicleData(
      vehicleType: VehicleType.van,
      vehicleClass: 'فان / ونيت',
      make: 'نيسان',
      model: 'أورفان',
      color: 'فضي',
      plateNumber: '22 - 67890',
      registrationExpiry: DateTime(2026, 11, 1),
      confidenceScore: 0.941,
      hasChemicalPermit: false,
    ),
    ExtractedVehicleData(
      vehicleType: VehicleType.truck,
      vehicleClass: 'شاحنة',
      make: 'مرسيدس',
      model: 'أكتروس',
      color: 'أحمر',
      plateNumber: '33 - 11223',
      registrationExpiry: DateTime(2028, 6, 30),
      confidenceScore: 0.989,
      hasChemicalPermit: true,
    ),
  ];

  int _callCount = 0;

  @override
  Future<VehicleRegistrationResult> extractVehicleData(String filePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 3500));

    if (filePath.contains('fail') || filePath.contains('invalid')) {
      return const VehicleRegistrationResult.failure(
        'تعذّر قراءة وثيقة المركبة. يرجى التأكد من وضوح الصورة والمحاولة مرة أخرى.',
      );
    }

    final result = _mockResults[_callCount % _mockResults.length];
    _callCount++;
    return VehicleRegistrationResult.success(result);
  }
}
