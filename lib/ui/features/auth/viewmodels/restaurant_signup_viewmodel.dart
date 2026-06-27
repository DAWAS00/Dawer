
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/restaurant_registration_data.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/services/i_ai_simulation_service.dart';
import '../../../../domain/services/i_ai_marketplace_service.dart';
import '../../../../data/services/gemini_ai_marketplace_service.dart';
import 'license_validation_viewmodel.dart';

class RestaurantSignupViewModel extends ChangeNotifier {
  final IAiSimulationService _aiService;
  final ImagePicker _picker = ImagePicker();
  final LicenseValidationViewModel licenseVm = LicenseValidationViewModel();

  File? _licenseFile;

  RestaurantSignupViewModel({required IAiSimulationService aiService})
      : _aiService = aiService;

  int _currentStep = 1;
  int get currentStep => _currentStep;
  int get totalSteps => 4;

  RestaurantRegistrationData _data = const RestaurantRegistrationData();
  RestaurantRegistrationData get data => _data;

  bool _isLoadingAi = false;
  bool get isLoadingAi => _isLoadingAi;

  bool _isAiCheckingDoc = false;
  bool get isAiCheckingDoc => _isAiCheckingDoc;

  bool _isDocValid = false;
  bool get isDocValid => _isDocValid;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  final Map<String, String> _errors = {};
  Map<String, String> get errors => _errors;

  bool _isSubmitted = false;
  bool get isSubmitted => _isSubmitted;

  // Real-time AI Suggestions
  String _cuisineType = '';
  String get cuisineType => _cuisineType;

  final IAiMarketplaceService _aiMarketplaceService = GeminiAiMarketplaceService();
  AiMarketplaceSuggestion? _suggestion;
  AiMarketplaceSuggestion? get suggestion => _suggestion;
  bool _isLoadingSuggestion = false;
  bool get isLoadingSuggestion => _isLoadingSuggestion;
  Timer? _debounce;

  void updateCuisineType(String cuisine) {
    _cuisineType = cuisine;
    _fetchSuggestions(cuisine);
    notifyListeners();
  }

  void _fetchSuggestions(String input) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _isLoadingSuggestion = true;
      notifyListeners();

      try {
        final result = await _aiMarketplaceService.getSuggestionsForRestaurant(input, _data.companyName ?? '');
        _suggestion = result;
      } catch (_) {
        // Silently ignore AI errors
      } finally {
        _isLoadingSuggestion = false;
        notifyListeners();
      }
    });
  }

  // Validation
  bool validateCurrentStep() {
    _errors.clear();
    bool isValid = true;

    if (_currentStep == 1) {
      if (_data.companyName == null || _data.companyName!.trim().isEmpty) {
        _errors['companyName'] = 'restaurantSignupErrorCompanyNameRequired';
        isValid = false;
      }
      if (_data.ownerName == null || _data.ownerName!.trim().isEmpty) {
        _errors['ownerName'] = 'restaurantSignupErrorOwnerNameRequired';
        isValid = false;
      }
    } else if (_currentStep == 2) {
      if (_data.tagline == null || _data.tagline!.trim().isEmpty) {
        _errors['tagline'] = 'restaurantSignupErrorTaglineRequired';
        isValid = false;
      } else if (_data.aiGeneratedContent == null || _data.aiGeneratedContent!.trim().isEmpty) {
        _errors['aiGeneratedContent'] = 'restaurantSignupErrorAiProfileRequired';
        isValid = false;
      }
      if (_data.selectedCategories.isEmpty) {
        _errors['selectedCategories'] = 'restaurantSignupErrorCategoryRequired';
        isValid = false;
      }
    } else if (_currentStep == 3) {
      if (_data.address == null || _data.address!.trim().isEmpty) {
        _errors['address'] = 'restaurantSignupErrorAddressRequired';
        isValid = false;
      }
      if (!_data.isCertificationVerified) {
        _errors['verification'] = 'restaurantSignupErrorVerificationRequired';
        isValid = false;
      }
    }

    notifyListeners();
    return isValid;
  }

  void nextStep() {
    if (validateCurrentStep()) {
      if (_currentStep < totalSteps) {
        _currentStep++;
        notifyListeners();
      }
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      _errors.clear();
      notifyListeners();
    }
  }

  void updateBasicProfile({String? ownerName, String? companyName, String? photoPath}) {
    _data = _data.copyWith(
      ownerName: ownerName,
      companyName: companyName,
      photoPath: photoPath,
    );
    if (_errors.containsKey('ownerName') || _errors.containsKey('companyName')) {
      _errors.remove('ownerName');
      _errors.remove('companyName');
    }
    notifyListeners();
  }

  void updateTagline(String tagline) {
    _data = _data.copyWith(tagline: tagline);
    if (_errors.containsKey('tagline')) _errors.remove('tagline');
    notifyListeners();
  }

  void updateAiContent(String content) {
    _data = _data.copyWith(aiGeneratedContent: content);
    if (_errors.containsKey('aiGeneratedContent')) _errors.remove('aiGeneratedContent');
    notifyListeners();
  }

  void toggleCategory(String category) {
    final currentCategories = List<String>.from(_data.selectedCategories);
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    _data = _data.copyWith(selectedCategories: currentCategories);
    if (_errors.containsKey('selectedCategories') && currentCategories.isNotEmpty) {
      _errors.remove('selectedCategories');
    }
    notifyListeners();
  }

  void updateAddress(String address) {
    _data = _data.copyWith(address: address);
    if (_errors.containsKey('address')) _errors.remove('address');
    notifyListeners();
  }

  // State to hold recommended categories generated by AI
  List<String> _recommendedCategories = [];
  List<String> get recommendedCategories => _recommendedCategories;

  Future<void> generateAiProfileWithRecommendations() async {
    if (_data.tagline == null || _data.tagline!.trim().isEmpty) {
      _errors['tagline'] = 'restaurantSignupErrorTaglineFirst';
      notifyListeners();
      return;
    }

    _isLoadingAi = true;
    _errors.remove('aiGeneratedContent');
    notifyListeners();

    try {
      final result = await _aiService.generateProfile(_data.tagline!);
      _recommendedCategories = result.categories;
      _data = _data.copyWith(
        aiGeneratedContent: result.story,
        selectedCategories: result.categories.isNotEmpty ? [result.categories.first] : [],
      );
    } catch (e) {
      _errors['aiGeneratedContent'] = 'restaurantSignupErrorAiGenerationFailed';
    } finally {
      _isLoadingAi = false;
      notifyListeners();
    }
  }

  Future<void> pickLicense(ImageSource source) async {
    final xf = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1200);
    if (xf != null) {
      _licenseFile = File(xf.path);
      await licenseVm.analyzeDocument(_licenseFile!, UserRole.supplier);
      // Sync to legacy isCertificationVerified so step-3 validation passes
      _data = _data.copyWith(
        isCertificationVerified: licenseVm.state == LicenseValidationState.valid,
      );
      _errors.remove('verification');
      notifyListeners();
    }
  }

  void clearLicense() {
    _licenseFile = null;
    licenseVm.reset();
    _data = _data.copyWith(isCertificationVerified: false);
    notifyListeners();
  }

  List<String> get aiCategories => licenseVm.suggestedCategories;

  Future<void> verifyLocationAndDocs(String documentPath) async {
    if (_data.address == null || _data.address!.trim().isEmpty) {
      _errors['address'] = 'restaurantSignupErrorAddressFirst';
      notifyListeners();
      return;
    }

    _isVerifying = true;
    _isAiCheckingDoc = true;
    _isDocValid = false;
    _errors.remove('verification');
    notifyListeners();

    try {
      final result = await _aiService.verifyDocumentAndAddress(_data.address!, documentPath);
      _data = _data.copyWith(isCertificationVerified: result.isVerified);
      _isDocValid = result.isVerified;
      if (!result.isVerified) {
        _errors['verification'] = result.statusMessage;
      }
    } catch (e) {
      _errors['verification'] = 'restaurantSignupErrorVerificationFailed';
      _isDocValid = false;
    } finally {
      _isVerifying = false;
      _isAiCheckingDoc = false;
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    if (!validateCurrentStep()) return false;
    if (_currentStep != totalSteps) return false;

    _isSubmitted = true;
    notifyListeners();

    // Simulate backend submission
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, send `_data.toJson()` to the backend repository
    
    _isSubmitted = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    licenseVm.dispose();
    super.dispose();
  }
}
