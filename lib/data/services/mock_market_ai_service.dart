import 'dart:io';
import 'dart:ui';
import '../models/order/order.dart';
import 'market_ai_service.dart';

class MockMarketAiService implements IMarketAiService {
  @override
  Future<MarketAiResult> analyze(File image, {required Locale locale}) async {
    await Future.delayed(const Duration(seconds: 2));

    final isAr = locale.languageCode == 'ar';

    return MarketAiResult(
      wasteTypes: [WasteType.plastic],
      wasteForm: WasteForm.solid,
      weightCategory: WeightCategory.light,
      estimatedWeightKg: 2.5,
      approxPriceJd: 0.5,
      note: isAr
          ? 'تم تحليل الصورة (محاكاة): عبوات بلاستيكية شفافة، وزن خفيف.'
          : 'Image analyzed (mock): Clear plastic containers, light weight.',
      confidence: 0.95,
    );
  }
}
