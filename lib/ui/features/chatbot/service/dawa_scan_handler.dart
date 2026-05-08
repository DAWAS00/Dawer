import 'dart:io';
import 'package:flutter/services.dart';
import '../dawa_chatbot_service.dart';
import '../dawa_image_scan_service.dart';

/// Result returned by the [DawaScanHandler] for a single asset/picked image.
///
/// The view-model uses [entry] to display the bot reply, [mlSource] to tag
/// the bubble with the ML Kit label, and [tempImagePath] to render the image
/// thumbnail when an asset was scanned.
class DawaScanOutcome {
  final DawaEntry entry;
  final String? mlSource;
  final String? tempImagePath;

  const DawaScanOutcome({
    required this.entry,
    this.mlSource,
    this.tempImagePath,
  });
}

/// Pure-logic helper used by [DawaChatViewModel] to run ML Kit on either a
/// bundled asset or a freshly picked image and convert the classification
/// result into a chat-ready [DawaEntry].
class DawaScanHandler {
  DawaScanHandler._();

  /// Loads [assetKey] from bundled assets, writes it to a temp file, runs
  /// ML Kit, and returns a [DawaScanOutcome] for the chat view-model.
  static Future<DawaScanOutcome> scanAsset({
    required String assetKey,
    required String displayName,
  }) async {
    final data = await rootBundle.load(assetKey);
    final bytes = data.buffer.asUint8List();
    final tempPath =
        '${Directory.systemTemp.path}/dawer_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(bytes);

    final result = await DawaImageScanService.classify(tempFile);
    final entry = _buildEntryFromResult(result, isAsset: true);
    return DawaScanOutcome(
      entry: entry,
      mlSource: result.category == 'unknown' ? result.topLabel : result.category,
      tempImagePath: tempPath,
    );
  }

  /// Runs ML Kit on a user-picked [file] and returns the chat-ready outcome.
  static Future<DawaScanOutcome> scanFile(File file) async {
    final result = await DawaImageScanService.classify(file);
    final entry = _buildEntryFromResult(result, isAsset: false);
    return DawaScanOutcome(
      entry: entry,
      mlSource: result.category == 'unknown' ? result.topLabel : result.category,
    );
  }

  /// Wraps an arbitrary scan exception into a chat-ready fallback entry.
  static DawaEntry buildErrorEntry(Object error, {required bool isAsset}) {
    final detail =
        error is DawaImageScanException ? error.message : error.toString();
    final intro = isAsset
        ? 'تعذّر قراءة الصورة النموذجية.'
        : 'تعذّر قراءة الصورة.';
    final tail = isAsset
        ? 'اختر المادة يدوياً:'
        : 'يمكنك اختيار المادة يدوياً أدناه:';
    return DawaEntry(
      id: 'ml_error',
      keywords: const [],
      response: '$intro\nالسبب: $detail\n\n$tail',
      followUpIds: isAsset
          ? const ['recycle_oil', 'recycle_wood']
          : const ['recycle_oil', 'recycle_wood', 'waste_types'],
    );
  }

  // ──────────────────────────────────────────────
  //  Internal
  // ──────────────────────────────────────────────

  static DawaEntry _buildEntryFromResult(
    DawaImageScanResult result, {
    required bool isAsset,
  }) {
    if (result.category == 'unknown') {
      return _buildUnknownEntry(result, isAsset: isAsset);
    }
    return _buildRecognizedEntry(result, isAsset: isAsset);
  }

  static DawaEntry _buildUnknownEntry(
    DawaImageScanResult result, {
    required bool isAsset,
  }) {
    final confPct = (result.confidence * 100).toStringAsFixed(0);
    if (isAsset) {
      return DawaEntry(
        id: 'ml_not_recognized',
        keywords: const [],
        response: 'لم أتعرف على المادة في الصورة النموذجية.\n'
            'أعلى تسمية رُصدت: "${result.topLabel}" ($confPct%)\n\n'
            'اختر مادتك يدوياً:',
        followUpIds: const ['recycle_oil', 'recycle_wood'],
      );
    }
    return DawaEntry(
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
    );
  }

  static DawaEntry _buildRecognizedEntry(
    DawaImageScanResult result, {
    required bool isAsset,
  }) {
    final entry = DawaChatbotService.matchFromMlLabel(result.category);
    final confPct = (result.confidence * 100).toStringAsFixed(0);
    final ar = result.category == 'oil' ? 'زيت مستعمل' : 'خشب بناء';
    final header = isAsset
        ? 'تم التعرف على: $ar (دقة: $confPct%)'
        : '✅ تم التعرف على: $ar ${result.category == 'oil' ? '🛢️' : '🪵'} '
            '(دقة: $confPct%)';
    return DawaEntry(
      id: entry.id,
      keywords: entry.keywords,
      response: '$header\n\n${entry.response}',
      followUpIds: entry.followUpIds,
      mlLabel: entry.mlLabel,
    );
  }
}
