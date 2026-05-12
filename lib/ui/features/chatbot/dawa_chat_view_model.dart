import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../data/models/order.dart';
import 'dawa_chatbot_service.dart';
import 'service/dawa_scan_handler.dart';

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
    _addBotMessage(DawaChatbotService.greeting);
  }

  // ──────────────────────────────────────────────
  //  User-typed message
  // ──────────────────────────────────────────────

  void handleUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _messages.add(DawaMessage(text: trimmed, isUser: true));
    notifyListeners();

    _addBotMessage(DawaChatbotService.match(trimmed));
  }

  // ──────────────────────────────────────────────
  //  Follow-up chip tap
  // ──────────────────────────────────────────────

  /// `scan_oil_sample` / `scan_wood_sample` trigger ML Kit on bundled assets.
  Future<void> handleFollowUpTap(String entryId) async {
    if (entryId == 'scan_oil_sample') {
      await _runAssetScan('assets/images/sample_oil.jpg', 'زيت مستعمل');
      return;
    }
    if (entryId == 'scan_wood_sample') {
      await _runAssetScan('assets/images/sample_wood.jpg', 'خشب بناء');
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

  // ──────────────────────────────────────────────
  //  Google ML Kit integration
  // ──────────────────────────────────────────────

  /// Called when Google ML Kit classifies a waste-type image.
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

    _addBotMessage(
      DawaChatbotService.matchFromMlLabel(mlLabel),
      mlSource: mlLabel,
    );
  }

  /// Lets the user pick an image from [source], runs ML Kit, and replies
  /// with detailed recycling information for oil or construction wood.
  Future<void> handleImagePick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    _messages.add(DawaMessage(
      text: '📸 صورة للتحليل',
      isUser: true,
      imagePath: picked.path,
    ));
    _isScanning = true;
    notifyListeners();

    try {
      final outcome = await DawaScanHandler.scanFile(File(picked.path));
      _isScanning = false;
      _applyScannedCategory(outcome.mlSource);
      _addBotMessage(outcome.entry, mlSource: outcome.mlSource);
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      _addBotMessage(DawaScanHandler.buildErrorEntry(e, isAsset: false));
    }
  }

  // ──────────────────────────────────────────────
  //  Internal
  // ──────────────────────────────────────────────

  Future<void> _runAssetScan(String assetKey, String displayName) async {
    _isScanning = true;
    notifyListeners();
    try {
      final outcome = await DawaScanHandler.scanAsset(
        assetKey: assetKey,
        displayName: displayName,
      );
      _messages.add(DawaMessage(
        text: 'تحليل عينة: $displayName',
        isUser: true,
        imagePath: outcome.tempImagePath,
      ));
      _isScanning = false;
      _applyScannedCategory(outcome.mlSource);
      _addBotMessage(outcome.entry, mlSource: outcome.mlSource);
    } catch (e) {
      _isScanning = false;
      notifyListeners();
      _addBotMessage(DawaScanHandler.buildErrorEntry(e, isAsset: true));
    }
  }

  void _applyScannedCategory(String? category) {
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
    final followUps =
        entry.followUpIds.map(DawaChatbotService.entryById).toList();
    _messages.add(DawaMessage(
      text: entry.response,
      isUser: false,
      followUps: followUps,
      mlSource: mlSource,
    ));
    notifyListeners();
  }
}
