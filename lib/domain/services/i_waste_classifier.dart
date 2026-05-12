import '../../data/models/order_enums.dart';

class WasteClassificationResult {
  final WasteType? wasteType;
  final double confidence;
  final bool isHighConfidence;

  const WasteClassificationResult({
    this.wasteType,
    required this.confidence,
  }) : isHighConfidence = confidence >= 0.65;
}

abstract interface class IWasteClassifier {
  /// Returns the most likely [WasteType] for the image at [imagePath],
  /// or null if the image doesn't match any known waste category.
  Future<WasteClassificationResult> classify(String imagePath);
}
