import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/services/gemini_service.dart';

void main() {
  group('GeminiService.extractJson —', () {
    // ── clean JSON ────────────────────────────────────────────────────────────

    test('parses clean JSON object', () {
      const raw = '{"grade": "A", "isRecyclable": true}';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['grade'], 'A');
      expect(result['isRecyclable'], isTrue);
    });

    test('parses JSON with nested objects', () {
      const raw =
          '{"material": {"type": "oil", "grade": "B"}, "payout": 2.5}';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect((result!['material'] as Map)['grade'], 'B');
      expect(result['payout'], 2.5);
    });

    test('parses JSON with Arabic string values', () {
      const raw =
          '{"materialType": "زيت طبخ مستعمل", "explanation": "زيت نظيف."}';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['materialType'], 'زيت طبخ مستعمل');
    });

    // ── markdown code fence stripping ─────────────────────────────────────────

    test('strips ```json ... ``` fence', () {
      const raw = '```json\n{"grade": "B"}\n```';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['grade'], 'B');
    });

    test('strips plain ``` ... ``` fence', () {
      const raw = '```\n{"grade": "C"}\n```';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['grade'], 'C');
    });

    test('strips ```JSON (uppercase) fence', () {
      const raw = '```JSON\n{"grade": "A"}\n```';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['grade'], 'A');
    });

    test('handles leading/trailing whitespace around fences', () {
      const raw = '  ```json\n  {"key": "value"}\n  ```  ';
      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['key'], 'value');
    });

    // ── malformed / empty input ────────────────────────────────────────────────

    test('returns null for empty string', () {
      expect(GeminiService.extractJson(''), isNull);
    });

    test('returns null for plain text (no JSON)', () {
      expect(GeminiService.extractJson('Hello, I am Gemini.'), isNull);
    });

    test('returns null for malformed JSON (unclosed brace)', () {
      expect(GeminiService.extractJson('{"grade": "A"'), isNull);
    });

    test('returns null for JSON array (not an object)', () {
      // extractJson expects a Map, not a List
      expect(GeminiService.extractJson('["A", "B"]'), isNull);
    });

    test('returns null for JSON number', () {
      expect(GeminiService.extractJson('42'), isNull);
    });

    test('returns null for JSON boolean', () {
      expect(GeminiService.extractJson('true'), isNull);
    });

    // ── number and boolean values ─────────────────────────────────────────────

    test('preserves double values', () {
      final result = GeminiService.extractJson('{"payout": 2.50}');
      expect(result, isNotNull);
      expect(result!['payout'], 2.5);
    });

    test('preserves boolean false', () {
      final result = GeminiService.extractJson('{"isRecyclable": false}');
      expect(result, isNotNull);
      expect(result!['isRecyclable'], isFalse);
    });

    test('preserves null value inside object', () {
      final result = GeminiService.extractJson('{"note": null}');
      expect(result, isNotNull);
      expect(result!['note'], isNull);
    });

    test('preserves list value inside object', () {
      final result = GeminiService.extractJson(
        '{"tips": ["نصيحة 1", "نصيحة 2"]}',
      );
      expect(result, isNotNull);
      expect(result!['tips'], ['نصيحة 1', 'نصيحة 2']);
    });

    // ── multi-field waste analysis response ───────────────────────────────────

    test('round-trips a full waste analysis response', () {
      const raw = '''
```json
{
  "isRecyclable": true,
  "materialType": "زيت طبخ مستعمل",
  "materialTypeEn": "used_cooking_oil",
  "grade": "A",
  "estimatedQuantity": 5.0,
  "quantityUnit": "لتر",
  "estimatedPayoutMinJod": 2.0,
  "estimatedPayoutMaxJod": 2.5,
  "explanation": "زيت نظيف ممتاز.",
  "recycleTips": ["احفظه في حاوية مغلقة"]
}
```''';

      final result = GeminiService.extractJson(raw);
      expect(result, isNotNull);
      expect(result!['isRecyclable'], isTrue);
      expect(result['materialTypeEn'], 'used_cooking_oil');
      expect(result['grade'], 'A');
      expect(result['estimatedQuantity'], 5.0);
      expect(result['quantityUnit'], 'لتر');
      expect(result['estimatedPayoutMinJod'], 2.0);
      expect(result['recycleTips'], ['احفظه في حاوية مغلقة']);
    });
  });
}
