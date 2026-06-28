import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/services/market_ai_service.dart';
import '../../../../../data/services/location_service.dart';
import '../../shared/controllers/post_market_controller.dart';

class PublishFormController extends ChangeNotifier {
  final PostMarketController aiController;
  final LocationService locationService;
  final OrderMode mode;

  PublishFormController({
    required this.aiController,
    required this.locationService,
    required this.mode,
  }) {
    aiController.addListener(_onAiChanged);
  }

  // ─── State ─────────────────────────────────────────────────────────────────
  int _currentStep = 0;
  int get currentStep => _currentStep;

  final Set<WasteType> selectedTypes = {};
  WasteForm? wasteForm;
  WeightCategory? weightCategory;
  final List<String> images = [];
  final priceCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  
  double? pickedLat;
  double? pickedLng;
  String? pickedAddress;
  bool resolvingAddress = false;

  // ─── Getters ───────────────────────────────────────────────────────────────
  bool get step1Valid => selectedTypes.isNotEmpty;
  bool get step2Valid => wasteForm != null && weightCategory != null;
  bool get step3Valid => pickedLat != null;

  bool get canProceed {
    if (_currentStep == 0) return step1Valid;
    if (_currentStep == 1) return step2Valid;
    return true;
  }

  // ─── Actions ───────────────────────────────────────────────────────────────
  
  void nextStep() {
    if (_currentStep < 2 && canProceed) {
      _currentStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void toggleWasteType(WasteType type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }
    notifyListeners();
  }

  void selectWasteForm(WasteForm form) {
    wasteForm = form;
    notifyListeners();
  }

  void selectWeightCategory(WeightCategory cat) {
    weightCategory = cat;
    notifyListeners();
  }

  void addImage(String path) {
    images.add(path);
    notifyListeners();
    if (images.length == 1) {
      runAiAnalysis(path);
    }
  }

  String? _aiError;
  String? get aiError => _aiError;

  void clearAiError() {
    _aiError = null;
    notifyListeners();
  }

  void removeImage(int index) {
    images.removeAt(index);
    if (images.isEmpty) {
      aiController.clearAnalysis();
    }
    _aiError = null;
    notifyListeners();
  }

  // ─── AI Logic ──────────────────────────────────────────────────────────────

  void _onAiChanged() {
    notifyListeners();
  }

  Future<void> runAiAnalysis(String imagePath) async {
    _aiError = null;
    notifyListeners();
    try {
      final result = await aiController.analyze(File(imagePath), const Locale('ar'));
      if (result != null) {
        _applyAiResult(result);
      }
    } catch (e) {
      _aiError = e.toString();
      notifyListeners();
    }
  }

  void _applyAiResult(MarketAiResult result) {
    final filled = <String>[];
    
    if (result.wasteTypes.isNotEmpty) {
      selectedTypes.addAll(result.wasteTypes);
      filled.add('نوع المواد');
    }
    if (result.wasteForm != null) {
      wasteForm = result.wasteForm;
      filled.add('حالة المواد');
    }
    if (result.weightCategory != null) {
      weightCategory = result.weightCategory;
      filled.add('الكمية');
    }
    if (result.approxPriceJd != null) {
      priceCtrl.text = result.approxPriceJd!.toStringAsFixed(2);
      filled.add('السعر');
    }
    if (result.note != null && result.note!.isNotEmpty) {
      notesCtrl.text = result.note!;
      filled.add('الملاحظات');
    }
    
    aiController.reportFilledFields(filled);
    notifyListeners();
  }

  // ─── Location Logic ────────────────────────────────────────────────────────

  Future<void> updateLocation(double lat, double lng) async {
    pickedLat = lat;
    pickedLng = lng;
    resolvingAddress = true;
    notifyListeners();

    try {
      pickedAddress = await locationService.reverseGeocode(lat, lng);
    } catch (_) {
      pickedAddress = null;
    } finally {
      resolvingAddress = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    aiController.removeListener(_onAiChanged);
    priceCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }
}
