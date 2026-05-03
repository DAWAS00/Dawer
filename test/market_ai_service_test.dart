import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/services/market_ai_service.dart';
import 'package:dwaar/data/models/order.dart';

void main() {
  group('MarketAiResult.fromJson —', () {
    // ── Single-type array response (new format) ──────────────────────────

    test('parses single wasteType array correctly', () {
      final result = MarketAiResult.fromJson({
        'wasteTypes': ['plastic'],
        'wasteForm': 'solid',
        'weightCategory': 'medium',
        'estimatedWeightKg': 12.5,
        'approxPriceJd': 1.5,
        'note': 'Test note',
        'confidence': 0.95,
      });

      expect(result.wasteTypes, [WasteType.plastic]);
      expect(result.wasteForm, WasteForm.solid);
      expect(result.weightCategory, WeightCategory.medium);
      expect(result.estimatedWeightKg, 12.5);
      expect(result.approxPriceJd, 1.5);
      expect(result.note, 'Test note');
      expect(result.confidence, 0.95);
    });

    // ── Multi-type array (mixed waste) ────────────────────────────────────

    test('parses multiple wasteTypes array', () {
      final result = MarketAiResult.fromJson({
        'wasteTypes': ['metal', 'plastic', 'paper'],
        'wasteForm': 'solid',
        'weightCategory': 'medium',
        'estimatedWeightKg': 8.0,
        'approxPriceJd': 1.2,
        'note': 'Mixed recyclables',
        'confidence': 0.88,
      });

      expect(result.wasteTypes, [WasteType.metal, WasteType.plastic, WasteType.paper]);
      expect(result.wasteTypes.length, 3);
    });

    // ── Synonym mappings ──────────────────────────────────────────────────

    test('maps cardboard synonym → paper', () {
      final result = MarketAiResult.fromJson({'wasteTypes': ['cardboard']});
      expect(result.wasteTypes, [WasteType.paper]);
    });

    test('maps iron synonym → metal', () {
      final result = MarketAiResult.fromJson({'wasteTypes': ['iron']});
      expect(result.wasteTypes, [WasteType.metal]);
    });

    test('maps aluminium synonym → metal', () {
      final result = MarketAiResult.fromJson({'wasteTypes': ['aluminium']});
      expect(result.wasteTypes, [WasteType.metal]);
    });

    test('maps timber synonym → wood', () {
      final result = MarketAiResult.fromJson({'wasteTypes': ['timber']});
      expect(result.wasteTypes, [WasteType.wood]);
    });

    test('maps pvc synonym → plastic', () {
      final result = MarketAiResult.fromJson({'wasteTypes': ['pvc']});
      expect(result.wasteTypes, [WasteType.plastic]);
    });

    // ── Legacy single-key fallback ────────────────────────────────────────

    test('falls back to legacy wasteType single-key when wasteTypes absent', () {
      final result = MarketAiResult.fromJson({'wasteType': 'plastic'});
      expect(result.wasteTypes, [WasteType.plastic]);
    });

    test('legacy cardboard single-key maps to paper', () {
      final result = MarketAiResult.fromJson({'wasteType': 'cardboard'});
      expect(result.wasteTypes, [WasteType.paper]);
    });

    // ── Unknown / invalid values ──────────────────────────────────────────

    test('unknown wasteType slug is silently dropped', () {
      final result = MarketAiResult.fromJson({
        'wasteTypes': ['unknown_material', 'plastic'],
      });
      expect(result.wasteTypes, [WasteType.plastic]);
    });

    test('entirely unknown wasteTypes produces empty list', () {
      final result = MarketAiResult.fromJson({
        'wasteTypes': ['unknown_material'],
        'wasteForm': 'invalid_form',
      });
      expect(result.wasteTypes, isEmpty);
      expect(result.wasteForm, isNull);
    });

    test('unknown wasteForm is null', () {
      final result = MarketAiResult.fromJson({'wasteForm': 'vapor'});
      expect(result.wasteForm, WasteForm.gas); // synonym
    });

    // ── WasteForm coverage ────────────────────────────────────────────────

    test('parses wasteForm mixed', () {
      final result = MarketAiResult.fromJson({'wasteForm': 'mixed'});
      expect(result.wasteForm, WasteForm.mixed);
    });

    test('parses wasteForm gas synonym "gaseous"', () {
      final result = MarketAiResult.fromJson({'wasteForm': 'gaseous'});
      expect(result.wasteForm, WasteForm.gas);
    });

    // ── WeightCategory coverage ───────────────────────────────────────────

    test('parses veryHeavy with underscore variant', () {
      final result = MarketAiResult.fromJson({'weightCategory': 'very_heavy'});
      expect(result.weightCategory, WeightCategory.veryHeavy);
    });

    test('parses veryHeavy camelCase variant', () {
      final result = MarketAiResult.fromJson({'weightCategory': 'veryHeavy'});
      expect(result.weightCategory, WeightCategory.veryHeavy);
    });

    // ── Value clamping ────────────────────────────────────────────────────

    test('clamps estimatedWeightKg above 500', () {
      final result = MarketAiResult.fromJson({'estimatedWeightKg': 1000.0});
      expect(result.estimatedWeightKg, 500.0);
    });

    test('clamps approxPriceJd above 10000', () {
      final result = MarketAiResult.fromJson({'approxPriceJd': 20000.0});
      expect(result.approxPriceJd, 10000.0);
    });

    test('clamps estimatedWeightKg below 0.1', () {
      final result = MarketAiResult.fromJson({'estimatedWeightKg': 0.0});
      expect(result.estimatedWeightKg, 0.1);
    });

    test('clamps confidence above 1.0', () {
      final result = MarketAiResult.fromJson({'confidence': 1.5});
      expect(result.confidence, 1.0);
    });

    test('clamps confidence below 0.0', () {
      final result = MarketAiResult.fromJson({'confidence': -0.5});
      expect(result.confidence, 0.0);
    });

    // ── Missing fields ────────────────────────────────────────────────────

    test('handles completely empty JSON without throwing', () {
      final result = MarketAiResult.fromJson({});
      expect(result.wasteTypes, isEmpty);
      expect(result.wasteForm, isNull);
      expect(result.weightCategory, isNull);
      expect(result.estimatedWeightKg, isNull);
      expect(result.approxPriceJd, isNull);
      expect(result.note, isNull);
      expect(result.confidence, 0.0);
    });

    test('confidence defaults to 0.0 when absent', () {
      final result = MarketAiResult.fromJson({'wasteTypes': ['wood']});
      expect(result.confidence, 0.0);
    });
  });
}
