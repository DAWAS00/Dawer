import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/order_enums.dart';
import '../../domain/services/i_waste_classifier.dart';

class WasteClassifierService implements IWasteClassifier {
  static const Map<String, WasteType> _labelMap = {
    // Plastic
    'Bottle': WasteType.plastic,
    'Plastic': WasteType.plastic,
    'Plastic bottle': WasteType.plastic,
    'Plastic bag': WasteType.plastic,
    'Container': WasteType.plastic,
    // Metal
    'Can': WasteType.metal,
    'Metal': WasteType.metal,
    'Tin': WasteType.metal,
    'Aluminum': WasteType.metal,
    'Iron': WasteType.metal,
    'Steel': WasteType.metal,
    // Paper
    'Paper': WasteType.paper,
    'Cardboard': WasteType.paper,
    'Newspaper': WasteType.paper,
    'Book': WasteType.paper,
    'Box': WasteType.paper,
    // Glass
    'Glass': WasteType.glass,
    'Glass bottle': WasteType.glass,
    'Jar': WasteType.glass,
    'Window': WasteType.glass,
    // Electronics
    'Electronic device': WasteType.electronics,
    'Mobile phone': WasteType.electronics,
    'Computer': WasteType.electronics,
    'Laptop': WasteType.electronics,
    'Television': WasteType.electronics,
    'Electronics': WasteType.electronics,
    // Organic
    'Food': WasteType.organic,
    'Vegetable': WasteType.organic,
    'Fruit': WasteType.organic,
    'Plant': WasteType.organic,
    'Leaf': WasteType.organic,
    // Textile
    'Clothing': WasteType.textile,
    'Textile': WasteType.textile,
    'Fabric': WasteType.textile,
    // Wood
    'Wood': WasteType.wood,
    'Furniture': WasteType.furniture,
    'Table': WasteType.furniture,
    'Chair': WasteType.furniture,
    // Rubber / Tires
    'Tire': WasteType.tires,
    'Rubber': WasteType.rubber,
    // Batteries
    'Battery': WasteType.batteries,
    // Oil
    'Oil': WasteType.oil,
    // Construction
    'Brick': WasteType.construction,
    'Concrete': WasteType.construction,
    'Rubble': WasteType.construction,
  };

  @override
  Future<WasteClassificationResult> classify(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.4),
    );
    try {
      final labels = await labeler.processImage(inputImage);

      for (final label in labels) {
        final type = _labelMap[label.label];
        if (type != null) {
          return WasteClassificationResult(
            wasteType: type,
            confidence: label.confidence,
          );
        }
      }

      return const WasteClassificationResult(wasteType: null, confidence: 0);
    } catch (e) {
      AppLogger.error('WasteClassifierService', e);
      return const WasteClassificationResult(wasteType: null, confidence: 0);
    } finally {
      await labeler.close();
    }
  }
}
