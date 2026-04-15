import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Thrown by [DawaImageScanService.classify] when the ML Kit model is
/// unavailable or the image cannot be processed.
class DawaImageScanException implements Exception {
  final String message;
  const DawaImageScanException(this.message);
  @override
  String toString() => 'DawaImageScanException: $message';
}

/// Returned by [DawaImageScanService.classify].
class DawaImageScanResult {
  /// Normalized category: `'oil'`, `'wood'`, or `'unknown'`.
  final String category;

  /// The highest-confidence raw ML Kit label string.
  final String topLabel;

  /// Confidence of [topLabel] on a 0.0–1.0 scale.
  final double confidence;

  const DawaImageScanResult({
    required this.category,
    required this.topLabel,
    required this.confidence,
  });
}

/// Thin wrapper around Google ML Kit Image Labeling.
///
/// Recognises two materials relevant to Dawer's recycling marketplace:
///   - **oil**  — used motor/cooking oil, petroleum fluids
///   - **wood** — construction timber, lumber, wooden planks
///
/// Any image whose labels don't map to those categories returns `'unknown'`.
class DawaImageScanService {
  DawaImageScanService._();

  /// Low threshold — we apply our own category filter on top, so we want
  /// every label the model returns, even low-confidence ones.
  static const double _threshold = 0.10;

  /// Classifies [imageFile] using the on-device ML Kit base model.
  ///
  /// Throws a [DawaImageScanException] with an Arabic message when the model
  /// is unavailable or the image cannot be decoded, so callers can surface it.
  static Future<DawaImageScanResult> classify(File imageFile) async {
    if (!imageFile.existsSync()) {
      throw DawaImageScanException('الملف غير موجود: ${imageFile.path}');
    }
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: _threshold),
    );
    try {
      final input = InputImage.fromFilePath(imageFile.path);
      final labels = await labeler.processImage(input);

      final topLabel = labels.isEmpty ? '' : labels.first.label;
      final topConf  = labels.isEmpty ? 0.0  : labels.first.confidence;
      final category = _categorise(labels);

      return DawaImageScanResult(
        category: category,
        topLabel: topLabel,
        confidence: topConf,
      );
    } catch (e) {
      if (e is DawaImageScanException) rethrow;
      throw DawaImageScanException(
        'تعذّر تشغيل نموذج التعرف. تفاصيل: $e',
      );
    } finally {
      await labeler.close();
    }
  }

  // ─────────────────────────────────────────────
  //  Category mapping
  // ─────────────────────────────────────────────

  static const _oilTerms = [
    'oil', 'petroleum', 'lubricant', 'grease', 'automotive',
    'motor', 'engine', 'fuel', 'diesel', 'fluid',
  ];

  static const _woodTerms = [
    'wood', 'lumber', 'timber', 'plank', 'hardwood', 'softwood',
    'log', 'board', 'beam', 'construction', 'sawdust', 'trunk',
  ];

  static String _categorise(List<ImageLabel> labels) {
    for (final lbl in labels) {
      final l = lbl.label.toLowerCase();
      if (_oilTerms.any((t) => l.contains(t)))  return 'oil';
      if (_woodTerms.any((t) => l.contains(t))) return 'wood';
    }
    return 'unknown';
  }
}
