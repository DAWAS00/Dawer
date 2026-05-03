import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../data/models/order.dart';
import 'dawa_chatbot_service.dart';
import 'dawa_image_scan_service.dart';

/// Represents a single chat bubble in the Dawa support conversation.
class DawaMessage {
  final String text;
  final bool isUser;
  final List<DawaEntry> followUps;

  /// When non-null, this message was triggered by an ML Kit image result.
  final String? mlSource;

  /// When non-null, displays an image thumbnail above the text bubble.
  final String? imagePath;

  const DawaMessage({
    required this.text,
    required this.isUser,
    this.followUps = const [],
    this.mlSource,
    this.imagePath,
  });
}

/// Manages the static keyword-based support chat for the Dawer platform.
///
/// Architecture mirrors Faz3a's [SupportChatViewModel]:
///   - On creation: shows the greeting entry with follow-up chips.
///   - [handleUserMessage]: scores text input → adds user bubble → adds bot reply.
///   - [handleFollowUpTap]: quick-select a topic chip → adds both bubbles.
///   - [handleMlResult]: Google ML Kit image label → drives chatbot response.
class DawaChatViewModel extends ChangeNotifier {
  final List<DawaMessage> _messages = [];
  List<DawaMessage> get messages => List.unmodifiable(_messages);

  bool _isScanning = false;
  bool get isScanning => _isScanning;

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

  /// Called when the user types and submits a text message.
  void handleUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _messages.add(DawaMessage(text: trimmed, isUser: true));
    notifyListeners();

    final entry = DawaChatbotService.match(trimmed);
    _addBotMessage(entry);
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
    _messages.add(DawaMessage(
      text: entry.response.split('\n').first,
      isUser: true,
    ));
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
      _messages.add(DawaMessage(
        text: 'تحليل عينة: $displayName',
        isUser: true,
        imagePath: tempPath,
      ));
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
            response: 'لم أتعرف على المادة في الصورة النموذجية.\n'
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

    _messages.add(DawaMessage(
      text: '📸 جاري تحليل صورة النفايات...$confidenceText',
      isUser: true,
      mlSource: mlLabel,
    ));
    notifyListeners();

    final entry = DawaChatbotService.matchFromMlLabel(mlLabel);
    _addBotMessage(entry, mlSource: mlLabel);
  }

  /// Lets the user pick an image from [source], runs ML Kit, and replies
  /// with detailed recycling information for oil or construction wood.
  Future<void> handleImagePick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final imagePath = picked.path;
    _messages.add(DawaMessage(
      text: '📸 صورة للتحليل',
      isUser: true,
      imagePath: imagePath,
    ));
    _isScanning = true;
    notifyListeners();

    try {
      final result = await DawaImageScanService.classify(File(imagePath));
      _isScanning = false;
      _applyScannedCategory(result.category);

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
        final categoryAr =
            result.category == 'oil' ? 'زيت مستعمل 🛢️' : 'خشب بناء 🪵';
        final confPct = (result.confidence * 100).toStringAsFixed(0);
        final header =
            '✅ تم التعرف على: $categoryAr (دقة: $confPct%)';
        final enriched = DawaEntry(
          id: entry.id,
          keywords: entry.keywords,
          response: '$header\n\n${entry.response}',
          followUpIds: entry.followUpIds,
          mlLabel: entry.mlLabel,
        );
        _addBotMessage(enriched, mlSource: result.category);
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
              'تعذّر قراءة الصورة.\n'
              'السبب: $detail\n\n'
              'يمكنك اختيار المادة يدوياً أدناه:',
          followUpIds: const ['recycle_oil', 'recycle_wood', 'waste_types'],
        ),
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

    _messages.add(DawaMessage(
      text: entry.response,
      isUser: false,
      followUps: followUps,
      mlSource: mlSource,
    ));
    notifyListeners();
  }
}
