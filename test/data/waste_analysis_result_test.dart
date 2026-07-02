import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/waste_analysis_result.dart';

void main() {
  // ── fromJson — material detection ─────────────────────────────────────────

  group('WasteAnalysisResult.fromJson — oil', () {
    late WasteAnalysisResult result;

    setUp(() {
      result = WasteAnalysisResult.fromJson({
        'isRecyclable': true,
        'materialType': 'زيت طبخ مستعمل',
        'materialTypeEn': 'used_cooking_oil',
        'grade': 'A',
        'estimatedQuantity': 5.0,
        'quantityUnit': 'لتر',
        'estimatedPayoutMinJod': 2.0,
        'estimatedPayoutMaxJod': 2.5,
        'explanation': 'زيت نظيف وجيد.',
        'recycleTips': ['احفظه في حاوية مغلقة', 'لا تخلطه بالماء'],
      });
    });

    test('isRecyclable true', () => expect(result.isRecyclable, isTrue));
    test(
      'materialType Arabic',
      () => expect(result.materialType, 'زيت طبخ مستعمل'),
    );
    test(
      'materialTypeEn slug',
      () => expect(result.materialTypeEn, 'used_cooking_oil'),
    );
    test('grade A parsed', () => expect(result.grade, WasteGrade.a));
    test('quantity 5.0', () => expect(result.estimatedQuantity, 5.0));
    test('quantityUnit لتر', () => expect(result.quantityUnit, 'لتر'));
    test('payoutMin 2.0', () => expect(result.estimatedPayoutMinJod, 2.0));
    test('payoutMax 2.5', () => expect(result.estimatedPayoutMaxJod, 2.5));
    test('explanation non-empty', () => expect(result.explanation, isNotEmpty));
    test(
      'recycleTips list has 2 items',
      () => expect(result.recycleTips.length, 2),
    );
  });

  group('WasteAnalysisResult.fromJson — wood', () {
    test('parses wood B grade correctly', () {
      final r = WasteAnalysisResult.fromJson({
        'isRecyclable': true,
        'materialType': 'خشب بناء',
        'materialTypeEn': 'wood',
        'grade': 'B',
        'estimatedQuantity': 20.0,
        'quantityUnit': 'كغ',
        'estimatedPayoutMinJod': 0.6,
        'estimatedPayoutMaxJod': 1.4,
        'explanation': 'خشب جيد مع بعض الشوائب.',
        'recycleTips': ['نظّف الخشب من المسامير'],
      });

      expect(r.materialTypeEn, 'wood');
      expect(r.grade, WasteGrade.b);
      expect(r.quantityUnit, 'كغ');
      expect(r.recycleTips, hasLength(1));
    });
  });

  group('WasteAnalysisResult.fromJson — plastic', () {
    test('parses plastic C grade', () {
      final r = WasteAnalysisResult.fromJson({
        'isRecyclable': true,
        'materialType': 'بلاستيك',
        'materialTypeEn': 'plastic',
        'grade': 'C',
        'estimatedQuantity': 3.0,
        'quantityUnit': 'كغ',
        'estimatedPayoutMinJod': 0.03,
        'estimatedPayoutMaxJod': 0.15,
        'explanation': 'بلاستيك ملوث.',
        'recycleTips': [],
      });

      expect(r.grade, WasteGrade.c);
      expect(r.recycleTips, isEmpty);
    });
  });

  group('WasteAnalysisResult.fromJson — electronics (items)', () {
    test('parses electronics with قطعة unit', () {
      final r = WasteAnalysisResult.fromJson({
        'isRecyclable': true,
        'materialType': 'إلكترونيات',
        'materialTypeEn': 'electronics',
        'grade': 'A',
        'estimatedQuantity': 3.0,
        'quantityUnit': 'قطعة',
        'estimatedPayoutMinJod': 3.0,
        'estimatedPayoutMaxJod': 15.0,
        'explanation': 'هواتف وأجهزة لوحية بحالة جيدة.',
        'recycleTips': ['لا تكسر الشاشات'],
      });

      expect(r.quantityUnit, 'قطعة');
      expect(r.materialIcon, '📱');
    });
  });

  // ── grade parsing ─────────────────────────────────────────────────────────

  group('grade parsing', () {
    test('A → WasteGrade.a', () {
      final r = WasteAnalysisResult.fromJson({'grade': 'A'});
      expect(r.grade, WasteGrade.a);
    });

    test('B → WasteGrade.b', () {
      final r = WasteAnalysisResult.fromJson({'grade': 'B'});
      expect(r.grade, WasteGrade.b);
    });

    test('C → WasteGrade.c', () {
      final r = WasteAnalysisResult.fromJson({'grade': 'C'});
      expect(r.grade, WasteGrade.c);
    });

    test('rejected → WasteGrade.rejected', () {
      final r = WasteAnalysisResult.fromJson({'grade': 'rejected'});
      expect(r.grade, WasteGrade.rejected);
    });

    test('unknown grade defaults to rejected', () {
      final r = WasteAnalysisResult.fromJson({'grade': 'X'});
      expect(r.grade, WasteGrade.rejected);
    });

    test('grade is case-insensitive ("a" → A)', () {
      final r = WasteAnalysisResult.fromJson({'grade': 'a'});
      expect(r.grade, WasteGrade.a);
    });
  });

  // ── quantityUnit parsing ──────────────────────────────────────────────────

  group('quantityUnit parsing', () {
    test('Arabic لتر preserved', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'لتر'});
      expect(r.quantityUnit, 'لتر');
    });

    test('English "liter" → لتر', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'liter'});
      expect(r.quantityUnit, 'لتر');
    });

    test('English "liters" → لتر', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'liters'});
      expect(r.quantityUnit, 'لتر');
    });

    test('Arabic قطعة preserved', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'قطعة'});
      expect(r.quantityUnit, 'قطعة');
    });

    test('English "piece" → قطعة', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'piece'});
      expect(r.quantityUnit, 'قطعة');
    });

    test('Arabic كغ preserved', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'كغ'});
      expect(r.quantityUnit, 'كغ');
    });

    test('unknown unit defaults to كغ', () {
      final r = WasteAnalysisResult.fromJson({'quantityUnit': 'ton'});
      expect(r.quantityUnit, 'كغ');
    });
  });

  // ── numeric coercion ──────────────────────────────────────────────────────

  group('numeric coercion', () {
    test('quantity as string "5.0" is parsed', () {
      final r = WasteAnalysisResult.fromJson({'estimatedQuantity': '5.0'});
      expect(r.estimatedQuantity, 5.0);
    });

    test('payout as string "2,500.00" (comma) is parsed', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedPayoutMinJod': '2,500.00',
      });
      expect(r.estimatedPayoutMinJod, 2500.0);
    });

    test('quantity clamps at 99999', () {
      final r = WasteAnalysisResult.fromJson({'estimatedQuantity': 999999.0});
      expect(r.estimatedQuantity, 99999.0);
    });

    test('payout clamps at 9999', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedPayoutMaxJod': 99999.0,
      });
      expect(r.estimatedPayoutMaxJod, 9999.0);
    });

    test('null quantity defaults to 0', () {
      final r = WasteAnalysisResult.fromJson({});
      expect(r.estimatedQuantity, 0.0);
    });
  });

  // ── recycleTips parsing ───────────────────────────────────────────────────

  group('recycleTips parsing', () {
    test('list of strings is preserved', () {
      final r = WasteAnalysisResult.fromJson({
        'recycleTips': ['نصيحة 1', 'نصيحة 2'],
      });
      expect(r.recycleTips, ['نصيحة 1', 'نصيحة 2']);
    });

    test('null tips → empty list', () {
      final r = WasteAnalysisResult.fromJson({'recycleTips': null});
      expect(r.recycleTips, isEmpty);
    });

    test('absent tips → empty list', () {
      final r = WasteAnalysisResult.fromJson({});
      expect(r.recycleTips, isEmpty);
    });

    test('empty strings in list are filtered out', () {
      final r = WasteAnalysisResult.fromJson({
        'recycleTips': ['', 'نصيحة', ''],
      });
      expect(r.recycleTips, ['نصيحة']);
    });
  });

  // ── empty JSON ────────────────────────────────────────────────────────────

  group('empty JSON', () {
    late WasteAnalysisResult r;
    setUp(() => r = WasteAnalysisResult.fromJson({}));

    test('isRecyclable defaults false', () => expect(r.isRecyclable, isFalse));
    test('materialType defaults empty', () => expect(r.materialType, ''));
    test(
      'materialTypeEn defaults unknown',
      () => expect(r.materialTypeEn, 'unknown'),
    );
    test('grade defaults rejected', () => expect(r.grade, WasteGrade.rejected));
    test('quantity defaults 0', () => expect(r.estimatedQuantity, 0.0));
    test('quantityUnit defaults كغ', () => expect(r.quantityUnit, 'كغ'));
    test('payoutMin defaults 0', () => expect(r.estimatedPayoutMinJod, 0.0));
    test('payoutMax defaults 0', () => expect(r.estimatedPayoutMaxJod, 0.0));
    test('explanation defaults empty', () => expect(r.explanation, ''));
    test(
      'recycleTips defaults empty list',
      () => expect(r.recycleTips, isEmpty),
    );
  });

  // ── display helpers ───────────────────────────────────────────────────────

  group('gradeLabel', () {
    test('A → A — ممتاز', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'A'}).gradeLabel,
        'A — ممتاز',
      );
    });

    test('B → B — جيد', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'B'}).gradeLabel,
        'B — جيد',
      );
    });

    test('C → C — مقبول', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'C'}).gradeLabel,
        'C — مقبول',
      );
    });

    test('rejected → مرفوض', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'rejected'}).gradeLabel,
        'مرفوض',
      );
    });
  });

  group('gradeColor', () {
    test('A is green', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'A'}).gradeColor,
        const Color(0xFF1E5C35),
      );
    });

    test('B is amber', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'B'}).gradeColor,
        const Color(0xFFC8860A),
      );
    });

    test('rejected is dark red', () {
      expect(
        WasteAnalysisResult.fromJson({'grade': 'rejected'}).gradeColor,
        const Color(0xFF991B1B),
      );
    });
  });

  group('materialIcon', () {
    String icon(String en) =>
        WasteAnalysisResult.fromJson({'materialTypeEn': en}).materialIcon;

    test(
      'used_cooking_oil → 🛢️',
      () => expect(icon('used_cooking_oil'), '🛢️'),
    );
    test('wood → 🪵', () => expect(icon('wood'), '🪵'));
    test(
      'construction_wood → 🪵',
      () => expect(icon('construction_wood'), '🪵'),
    );
    test('plastic → ♻️', () => expect(icon('plastic'), '♻️'));
    test('metal → ⚙️', () => expect(icon('metal'), '⚙️'));
    test('aluminum → ⚙️', () => expect(icon('aluminum'), '⚙️'));
    test('copper → ⚙️', () => expect(icon('copper'), '⚙️'));
    test('paper → 📄', () => expect(icon('paper'), '📄'));
    test('cardboard → 📄', () => expect(icon('cardboard'), '📄'));
    test('glass → 🫙', () => expect(icon('glass'), '🫙'));
    test('electronics → 📱', () => expect(icon('electronics'), '📱'));
    test('textile → 👕', () => expect(icon('textile'), '👕'));
    test('rubber → ⭕', () => expect(icon('rubber'), '⭕'));
    test('tires → ⭕', () => expect(icon('tires'), '⭕'));
    test('batteries → 🔋', () => expect(icon('batteries'), '🔋'));
    test('chemicals → ⚗️', () => expect(icon('chemicals'), '⚗️'));
    test('furniture → 🪑', () => expect(icon('furniture'), '🪑'));
    test('organic → 🌿', () => expect(icon('organic'), '🌿'));
    test('unknown → ♻️', () => expect(icon('unknown'), '♻️'));
    test('unrecognised slug → ♻️', () => expect(icon('mystery_waste'), '♻️'));
  });

  group('payoutRangeLabel', () {
    test('returns range when min ≠ max', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedPayoutMinJod': 2.0,
        'estimatedPayoutMaxJod': 2.5,
      });
      expect(r.payoutRangeLabel, '2.00 – 2.50 دينار');
    });

    test('returns single value when min == max', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedPayoutMinJod': 3.0,
        'estimatedPayoutMaxJod': 3.0,
      });
      expect(r.payoutRangeLabel, '3.00 دينار');
    });

    test('returns لا يوجد when both are 0', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedPayoutMinJod': 0.0,
        'estimatedPayoutMaxJod': 0.0,
      });
      expect(r.payoutRangeLabel, 'لا يوجد');
    });
  });

  group('quantityLabel', () {
    test('whole number omits decimal', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedQuantity': 5.0,
        'quantityUnit': 'لتر',
      });
      expect(r.quantityLabel, '~5 لتر');
    });

    test('decimal quantity shows one decimal', () {
      final r = WasteAnalysisResult.fromJson({
        'estimatedQuantity': 5.5,
        'quantityUnit': 'كغ',
      });
      expect(r.quantityLabel, '~5.5 كغ');
    });

    test('zero quantity returns غير محدد', () {
      final r = WasteAnalysisResult.fromJson({'estimatedQuantity': 0.0});
      expect(r.quantityLabel, 'غير محدد');
    });
  });
}
