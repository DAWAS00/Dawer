import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/services/mock_ai_simulation_service.dart';

void main() {
  group('MockAiSimulationService', () {
    late MockAiSimulationService service;

    setUp(() {
      service = MockAiSimulationService();
    });

    test('generateProfile returns story and categories based on tagline', () async {
      final result = await service.generateProfile('Italian pasta place');
      
      expect(result.story, isNotEmpty);
      expect(result.categories, contains('Italian'));
    });

    test('verifyDocumentAndAddress returns verified for valid inputs', () async {
      final result = await service.verifyDocumentAndAddress('123 Main St', 'doc.pdf');
      
      expect(result.isVerified, isTrue);
    });

    test('verifyDocumentAndAddress returns unverified for empty inputs', () async {
      final result = await service.verifyDocumentAndAddress('', '');
      
      expect(result.isVerified, isFalse);
    });
  });
}
