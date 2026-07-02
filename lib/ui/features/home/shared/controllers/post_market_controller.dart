import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../../../../../data/services/market_ai_service.dart';
import '../../../../../data/services/mock_market_ai_service.dart';
import '../../../../../core/config/ai_config.dart';

/// Owns all AI-analysis state for the PostToMarket form.
///
/// Responsibilities:
///   - Driving [IMarketAiService.analyze] and exposing loading / result state.
///   - Translating [MarketAiResult] into the exact form-field values the widget
///     should apply (typed, validated, ready to set).
///
/// The widget remains responsible for its own selection/input state; this
/// controller only owns what the AI produces, keeping them independently
/// testable.
class PostMarketController extends ChangeNotifier {
  PostMarketController({IMarketAiService? aiService})
    : _aiService =
          aiService ??
          (AiConfig.hasGeminiKey ? MarketAiService() : MockMarketAiService());

  final IMarketAiService _aiService;

  // ── Observable AI state ──────────────────────────────────────────────────

  bool get isAnalyzing => _isAnalyzing;
  bool _isAnalyzing = false;

  /// Non-empty after a successful analysis. Contains display labels for the
  /// summary banner ("Waste Type", "Price", etc.).
  List<String> get filledFieldLabels => List.unmodifiable(_filledFieldLabels);
  final List<String> _filledFieldLabels = [];

  double? get estimatedWeightKg => _estimatedWeightKg;
  double? _estimatedWeightKg;

  /// 0.0–1.0. Consumers may use this to show a low-confidence warning.
  double get confidence => _confidence;
  double _confidence = 0.0;

  bool get hasLowConfidence =>
      _confidence > 0 && _confidence < _kLowConfidenceThreshold;

  static const double _kLowConfidenceThreshold = 0.70;

  // ── Multi-step state ─────────────────────────────────────────────────────

  int get currentStep => _currentStep;
  int _currentStep = 0;

  void setStep(int step) {
    if (_disposed) return;
    _currentStep = step;
    _safeNotify();
  }

  void nextStep() => setStep(_currentStep + 1);
  void prevStep() => setStep(_currentStep - 1);

  // ── Lifecycle guard ──────────────────────────────────────────────────────

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Safe wrapper — silently no-ops if the controller was disposed while an
  /// async operation was still in flight. Prevents the
  /// `A ChangeNotifier was used after being disposed` assertion.
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Runs AI analysis on [image]. Returns the result so the widget can apply
  /// it to its own form-field state, or null on error.
  ///
  /// Callers should catch [Exception] and handle user-facing error display;
  /// this method only manages the loading flag.
  Future<MarketAiResult?> analyze(File image, Locale locale) async {
    _isAnalyzing = true;
    _filledFieldLabels.clear();
    _estimatedWeightKg = null;
    _confidence = 0.0;
    _safeNotify();

    try {
      final result = await _aiService.analyze(image, locale: locale);
      if (_disposed) return null;
      _estimatedWeightKg = result.estimatedWeightKg;
      _confidence = result.confidence;
      return result;
    } finally {
      _isAnalyzing = false;
      _safeNotify();
    }
  }

  /// Called by the widget after it has applied [result] to its form state, so
  /// the controller can update the filled-fields summary banner.
  void reportFilledFields(List<String> labels) {
    if (_disposed) return;
    _filledFieldLabels
      ..clear()
      ..addAll(labels);
    _safeNotify();
  }

  void clearAnalysis() {
    if (_disposed) return;
    _filledFieldLabels.clear();
    _estimatedWeightKg = null;
    _confidence = 0.0;
    _safeNotify();
  }
}
