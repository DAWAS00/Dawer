import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/waste_analysis_result.dart';
import '../../../../../data/services/gemini_waste_analysis_service.dart';
import 'dawa_chatbot_service.dart';
import 'dawa_image_scan_service.dart';
import 'gemini_chat_service.dart';

/// Represents a single chat bubble in the Dawa support conversation.
class DawaMessage {
  final String text;
  final bool isUser;
  final List<DawaEntry> followUps;

  /// When non-null, this message was triggered by an ML Kit image result.
  final String? mlSource;

  /// When non-null, displays an image thumbnail above the text bubble.
  final String? imagePath;

  /// When non-null, renders a [WasteAnalysisResultCard] instead of a plain
  /// text bubble. Set for any material type Gemini Vision successfully
  /// identifies — oil, wood, plastic, metal, electronics, etc.
  final WasteAnalysisResult? wasteAnalysis;

  const DawaMessage({
    required this.text,
    required this.isUser,
    this.followUps = const [],
    this.mlSource,
    this.imagePath,
    this.wasteAnalysis,
  });
}

/// Manages the AI-powered support chat for the Dawer platform.
/// Typed messages are handled by Gemini; chip taps use the local knowledge base.
class DawaChatViewModel extends ChangeNotifier {
  final List<DawaMessage> _messages = [];
  List<DawaMessage> get messages => List.unmodifiable(_messages);

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isThinking = false;
  bool get isThinking => _isThinking;

  // True while Gemini Vision is analyzing an oil image (after ML Kit completes).
  bool _isAnalyzing = false;
  bool get isAnalyzing => _isAnalyzing;

  bool get isBusy => _isScanning || _isThinking || _isAnalyzing;

  bool _disposed = false;

  WasteType? _lastScannedType;
  double? _lastScannedWeightKg;
  WasteType? get lastScannedType => _lastScannedType;
  double? get lastScannedWeightKg => _lastScannedWeightKg;

  DawaChatViewModel() {
    final greeting = DawaChatbotService.greeting;
    _addBotMessage(greeting);
  }

  // ──────────────────────────────────────────────
  //  User-typed message
  // ──────────────────────────────────────────────

  // Standard follow-up chips offered after every Gemini reply so the
  // guided-navigation UX is preserved even for open-ended AI answers.
  static List<DawaEntry> _geminiFollowUps() => [
    DawaChatbotService.entryById('how_to_post_request'),
    DawaChatbotService.entryById('waste_types'),
    DawaChatbotService.entryById('support'),
  ];

  Future<void> handleUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isBusy) return;

    _messages.add(DawaMessage(text: trimmed, isUser: true));
    _isThinking = true;
    _safeNotify();

    try {
      final reply = await GeminiChatService.instance.sendMessage(trimmed);
      if (!_disposed) {
        _messages.add(
          DawaMessage(
            text: reply,
            isUser: false,
            followUps: _geminiFollowUps(),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[DawaChatVM] Gemini error: $e\n$st');
      if (!_disposed) _addBotMessage(DawaChatbotService.match(trimmed));
    } finally {
      _isThinking = false;
      _safeNotify();
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  Follow-up chip tap
  // ──────────────────────────────────────────────

  /// Called when the user taps a follow-up chip below a bot message.
  ///
  /// `scan_oil_sample` / `scan_wood_sample` trigger ML Kit on bundled assets.
  Future<void> handleFollowUpTap(String entryId) async {
    if (entryId == 'scan_oil_sample') {
      await _handleAssetScan('assets/images/sample_oil.jpg', 'زيت مستعمل');
      return;
    }
    if (entryId == 'scan_wood_sample') {
      await _handleAssetScan('assets/images/sample_wood.jpg', 'خشب بناء');
      return;
    }
    final entry = DawaChatbotService.entryById(entryId);
    _messages.add(
      DawaMessage(text: entry.response.split('\n').first, isUser: true),
    );
    notifyListeners();
    _addBotMessage(entry);
  }

  /// Loads a bundled asset image, writes it to a temp file, runs ML Kit,
  /// and shows the same enriched recycling response as [handleImagePick].
  Future<void> _handleAssetScan(String assetKey, String displayName) async {
    _isScanning = true;
    notifyListeners();
    try {
      final data = await rootBundle.load(assetKey);
      final bytes = data.buffer.asUint8List();
      final tempPath =
          '${Directory.systemTemp.path}/dawer_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);
      _messages.add(
        DawaMessage(
          text: 'تحليل عينة: $displayName',
          isUser: true,
          imagePath: tempPath,
        ),
      );
      notifyListeners();
      final result = await DawaImageScanService.classify(tempFile);
      _isScanning = false;
      _applyScannedCategory(result.category);
      if (result.category == 'unknown') {
        final confPct = (result.confidence * 100).toStringAsFixed(0);
        _addBotMessage(
          DawaEntry(
            id: 'ml_not_recognized',
            keywords: const [],
            response:
                'لم أتعرف على المادة في الصورة النموذجية.\n'
                'أعلى تسمية رُصدت: "${result.topLabel}" ($confPct%)\n\n'
                'اختر مادتك يدوياً:',
            followUpIds: const ['recycle_oil', 'recycle_wood'],
          ),
          mlSource: result.topLabel,
        );
      } else {
        final entry = DawaChatbotService.matchFromMlLabel(result.category);
        final ar = result.category == 'oil' ? 'زيت مستعمل' : 'خشب بناء';
        final pct = (result.confidence * 100).toStringAsFixed(0);
        _addBotMessage(
          DawaEntry(
            id: entry.id,
            keywords: entry.keywords,
            response: 'تم التعرف على: $ar (دقة: $pct%)\n\n${entry.response}',
            followUpIds: entry.followUpIds,
            mlLabel: entry.mlLabel,
          ),
          mlSource: result.category,
        );
      }
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      final detail = e is DawaImageScanException ? e.message : e.toString();
      _addBotMessage(
        DawaEntry(
          id: 'ml_error',
          keywords: const [],
          response:
              'تعذّر قراءة الصورة النموذجية.\n'
              'السبب: $detail\n\n'
              'اختر المادة يدوياً:',
          followUpIds: const ['recycle_oil', 'recycle_wood'],
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  //  Google ML Kit integration
  // ──────────────────────────────────────────────

  /// Called when Google ML Kit classifies a waste-type image.
  ///
  /// [mlLabel] is the ML Kit detection label (e.g. 'plastic', 'metal').
  /// [confidencePercent] is the confidence score (0–100).
  ///
  /// Adds a user-side "scanning..." bubble then the bot's ML-driven response.
  void handleMlResult(String mlLabel, {double confidencePercent = 0.0}) {
    final confidenceText = confidencePercent > 0
        ? ' (دقة: ${confidencePercent.toStringAsFixed(0)}%)'
        : '';

    _messages.add(
      DawaMessage(
        text: '📸 جاري تحليل صورة النفايات...$confidenceText',
        isUser: true,
        mlSource: mlLabel,
      ),
    );
    notifyListeners();

    final entry = DawaChatbotService.matchFromMlLabel(mlLabel);
    _addBotMessage(entry, mlSource: mlLabel);
  }

  /// Lets the user pick an image from [source].
  ///
  /// Flow:
  /// 1. ML Kit classifies the image on-device (fast, any material type).
  /// 2. Gemini Vision runs a deep quality analysis for the detected material
  ///    (or any material if ML Kit returns "unknown") and shows a rich card.
  /// 3. Falls back to KB entry if Gemini is unavailable or returns null.
  Future<void> handleImagePick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final imagePath = picked.path;
    _messages.add(
      DawaMessage(text: '📸 صورة للتحليل', isUser: true, imagePath: imagePath),
    );
    _isScanning = true;
    _safeNotify();

    try {
      final mlResult = await DawaImageScanService.classify(File(imagePath));
      _isScanning = false;
      _applyScannedCategory(mlResult.category);
      // Always attempt Gemini Vision regardless of ML Kit category —
      // it handles any material type and may identify what ML Kit missed.
      await _runWasteAnalysis(imagePath, mlResult);
    } catch (e) {
      _isScanning = false;
      final detail = e is DawaImageScanException ? e.message : e.toString();
      _addBotMessage(
        DawaEntry(
          id: 'ml_error',
          keywords: const [],
          response:
              'تعذّر قراءة الصورة.\n'
              'السبب: $detail\n\n'
              'يمكنك اختيار المادة يدوياً أدناه:',
          followUpIds: const ['recycle_oil', 'recycle_wood', 'waste_types'],
        ),
      );
    }
  }

  /// Runs Gemini Vision analysis for any recyclable material type.
  ///
  /// On success: shows a [WasteAnalysisResultCard] in the chat.
  /// If Gemini says not recyclable: shows an Arabic explanation message.
  /// If Gemini fails/unavailable: falls back to ML Kit KB entry or
  /// the "material not recognized" message for unknown material.
  Future<void> _runWasteAnalysis(
    String imagePath,
    DawaImageScanResult mlResult,
  ) async {
    if (_disposed) return;
    _isAnalyzing = true;
    _safeNotify();

    final wasteResult = await GeminiWasteAnalysisService.instance.analyze(
      imagePath,
    );

    if (_disposed) return;
    _isAnalyzing = false;

    if (wasteResult != null && wasteResult.isRecyclable) {
      _messages.add(
        DawaMessage(
          text: wasteResult.explanation,
          isUser: false,
          wasteAnalysis: wasteResult,
          followUps: [
            DawaChatbotService.entryById('how_to_post_request'),
            DawaChatbotService.entryById('waste_types'),
            DawaChatbotService.entryById('support'),
          ],
          mlSource: mlResult.category,
        ),
      );
      _safeNotify();
    } else if (wasteResult != null && !wasteResult.isRecyclable) {
      // AI confirmed this material is not recyclable.
      _addBotMessage(
        DawaEntry(
          id: 'ai_not_recyclable',
          keywords: const [],
          response:
              '🤖 ${wasteResult.explanation}\n\n'
              'هل لديك مواد أخرى تريد تدويرها؟',
          followUpIds: const ['waste_types', 'how_to_post_request', 'support'],
        ),
        mlSource: mlResult.category,
      );
    } else {
      // Gemini unavailable — fall back based on ML Kit result.
      _addMlFallbackEntry(mlResult);
    }
  }

  void _addMlFallbackEntry(DawaImageScanResult result) {
    if (result.category == 'unknown') {
      final confPct = (result.confidence * 100).toStringAsFixed(0);
      _addBotMessage(
        DawaEntry(
          id: 'ml_not_recognized',
          keywords: const [],
          response:
              '🔍 لم أتعرف على المادة في صورتك.\n'
              'أعلى تسمية رُصدت: "${result.topLabel}" ($confPct%)\n\n'
              'تأكد من:\n'
              '• إضاءة جيدة وصورة واضحة\n'
              '• أن تكون المادة في مقدمة الصورة\n\n'
              'اختر مادتك يدوياً:',
          followUpIds: const [
            'recycle_oil',
            'recycle_wood',
            'waste_types',
            'how_to_post_request',
          ],
        ),
        mlSource: result.topLabel,
      );
    } else {
      final entry = DawaChatbotService.matchFromMlLabel(result.category);
      final categoryAr = switch (result.category) {
        'oil' => 'زيت مستعمل 🛢️',
        'wood' => 'خشب بناء 🪵',
        _ => result.category,
      };
      final confPct = (result.confidence * 100).toStringAsFixed(0);
      _addBotMessage(
        DawaEntry(
          id: entry.id,
          keywords: entry.keywords,
          response:
              '✅ تم التعرف على: $categoryAr (دقة: $confPct%)\n\n${entry.response}',
          followUpIds: entry.followUpIds,
          mlLabel: entry.mlLabel,
        ),
        mlSource: result.category,
      );
    }
  }

  // ──────────────────────────────────────────────
  //  Internal
  // ──────────────────────────────────────────────

  void _applyScannedCategory(String category) {
    switch (category) {
      case 'oil':
        _lastScannedType = WasteType.oil;
      case 'wood':
        _lastScannedType = WasteType.wood;
      default:
        _lastScannedType = null;
    }
    notifyListeners();
  }

  void _addBotMessage(DawaEntry entry, {String? mlSource}) {
    final followUps = entry.followUpIds
        .map(DawaChatbotService.entryById)
        .toList();

    _messages.add(
      DawaMessage(
        text: entry.response,
        isUser: false,
        followUps: followUps,
        mlSource: mlSource,
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // Session is intentionally NOT reset here — the conversation history
    // should survive widget disposal (e.g. bottom-sheet swipe-down).
    // Call GeminiChatService.instance.resetSession() only when the user
    // explicitly wants to start a fresh conversation.
    super.dispose();
  }
}
