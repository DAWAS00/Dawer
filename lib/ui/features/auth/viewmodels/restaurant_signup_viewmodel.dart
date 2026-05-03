import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../../data/models/restaurant_registration_data.dart';
import '../../../../domain/services/i_ai_simulation_service.dart';

class RestaurantSignupViewModel extends ChangeNotifier {
  final IAiSimulationService _aiService;

  RestaurantSignupViewModel({required IAiSimulationService aiService})
      : _aiService = aiService;

  int _currentStep = 1;
  int get currentStep => _currentStep;
  int get totalSteps => 4;

  RestaurantRegistrationData _data = const RestaurantRegistrationData();
  RestaurantRegistrationData get data => _data;

  bool _isLoadingAi = false;
  bool get isLoadingAi => _isLoadingAi;

  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  final Map<String, String> _errors = {};
  Map<String, String> get errors => _errors;

  bool _isSubmitted = false;
  bool get isSubmitted => _isSubmitted;

  // Validation
  bool validateCurrentStep() {
    _errors.clear();
    bool isValid = true;

    if (_currentStep == 1) {
      if (_data.companyName == null || _data.companyName!.trim().isEmpty) {
        _errors['companyName'] = 'Company name is required';
        isValid = false;
      }
      if (_data.ownerName == null || _data.ownerName!.trim().isEmpty) {
        _errors['ownerName'] = 'Owner name is required';
        isValid = false;
      }
    } else if (_currentStep == 2) {
      if (_data.tagline == null || _data.tagline!.trim().isEmpty) {
        _errors['tagline'] = 'Please provide a tagline to generate your profile';
        isValid = false;
      } else if (_data.aiGeneratedContent == null || _data.aiGeneratedContent!.trim().isEmpty) {
        _errors['aiGeneratedContent'] = 'Please generate and review your AI profile';
        isValid = false;
      }
      if (_data.selectedCategories.isEmpty) {
        _errors['selectedCategories'] = 'Please select at least one category';
        isValid = false;
      }
    } else if (_currentStep == 3) {
      if (_data.address == null || _data.address!.trim().isEmpty) {
        _errors['address'] = 'Address is required';
        isValid = false;
      }
      if (!_data.isCertificationVerified) {
        _errors['verification'] = 'You must verify your documents and address';
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

  Future<void> generateAiProfile() async {
    if (_data.tagline == null || _data.tagline!.trim().isEmpty) {
      _errors['tagline'] = 'Please provide a tagline first';
      notifyListeners();
      return;
    }

    _isLoadingAi = true;
    _errors.remove('aiGeneratedContent');
    notifyListeners();

    try {
      final result = await _aiService.generateProfile(_data.tagline!);
      _data = _data.copyWith(
        aiGeneratedContent: result.story,
        selectedCategories: result.categories.take(1).toList(), // Auto-select the first one
      );
      
      // Store recommended categories temporarily in errors for the UI to pick up if needed,
      // or we can add a new field. For prototyping, we'll assume the UI shows a set list
      // and highlights the selected ones, or we can add 'recommendedCategories' to the ViewModel state.
    } catch (e) {
      _errors['aiGeneratedContent'] = 'Failed to generate profile. Please try again.';
    } finally {
      _isLoadingAi = false;
      notifyListeners();
    }
  }

  // State to hold recommended categories generated by AI
  List<String> _recommendedCategories = [];
  List<String> get recommendedCategories => _recommendedCategories;

  Future<void> generateAiProfileWithRecommendations() async {
    if (_data.tagline == null || _data.tagline!.trim().isEmpty) {
      _errors['tagline'] = 'Please provide a tagline first';
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
      _errors['aiGeneratedContent'] = 'Failed to generate profile. Please try again.';
    } finally {
      _isLoadingAi = false;
      notifyListeners();
    }
  }

  Future<void> verifyLocationAndDocs(String documentPath) async {
    if (_data.address == null || _data.address!.trim().isEmpty) {
      _errors['address'] = 'Please provide an address first';
      notifyListeners();
      return;
    }

    _isVerifying = true;
    _errors.remove('verification');
    notifyListeners();

    try {
      final result = await _aiService.verifyDocumentAndAddress(_data.address!, documentPath);
      _data = _data.copyWith(isCertificationVerified: result.isVerified);
      if (!result.isVerified) {
        _errors['verification'] = result.statusMessage;
      }
    } catch (e) {
      _errors['verification'] = 'Verification failed. Please try again.';
    } finally {
      _isVerifying = false;
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
}
