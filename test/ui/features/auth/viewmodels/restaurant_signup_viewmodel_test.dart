import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/auth/viewmodels/restaurant_signup_viewmodel.dart';
import 'package:dwaar/domain/services/i_ai_simulation_service.dart';

class FastMockAiSimulationService implements IAiSimulationService {
  @override
  Future<AiGenerationResult> generateProfile(String tagline) async {
    return const AiGenerationResult(
      story: 'Fast mock story',
      categories: ['Fast', 'Mock'],
    );
  }

  @override
  Future<VerificationResult> verifyDocumentAndAddress(String address, String documentPath) async {
    return const VerificationResult(isVerified: true, statusMessage: 'Status: Verified');
  }
}

void main() {
  group('RestaurantSignupViewModel', () {
    late RestaurantSignupViewModel vm;
    late FastMockAiSimulationService aiService;

    setUp(() {
      aiService = FastMockAiSimulationService();
      vm = RestaurantSignupViewModel(aiService: aiService);
    });

    test('initial state is Step 1 and not submitted', () {
      expect(vm.currentStep, 1);
      expect(vm.isSubmitted, isFalse);
    });

    test('validates Step 1 correctly', () {
      expect(vm.validateCurrentStep(), isFalse); // Empty initially
      expect(vm.errors.containsKey('companyName'), isTrue);
      
      vm.updateBasicProfile(companyName: 'Test Co', ownerName: 'John');
      expect(vm.validateCurrentStep(), isTrue);
    });

    test('navigation works when valid', () {
      vm.updateBasicProfile(companyName: 'Test Co', ownerName: 'John');
      vm.nextStep();
      expect(vm.currentStep, 2);
      
      vm.previousStep();
      expect(vm.currentStep, 1);
    });

    test('generates AI profile', () async {
      vm.updateBasicProfile(companyName: 'Test Co', ownerName: 'John');
      vm.nextStep(); // Step 2
      
      vm.updateTagline('A great place');
      await vm.generateAiProfileWithRecommendations();
      
      expect(vm.data.aiGeneratedContent, 'Fast mock story');
      expect(vm.data.selectedCategories, contains('Fast'));
    });
  });
}
