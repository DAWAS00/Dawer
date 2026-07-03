import 'package:flutter/material.dart';

enum WasteGrade { a, b, c, rejected }

/// Structured result returned by [GeminiWasteAnalysisService] for any
/// recyclable material type — oil, wood, plastic, metal, electronics, etc.
class WasteAnalysisResult {
  final bool isRecyclable;

  /// Material name in Arabic (e.g. "زيت طبخ مستعمل", "خشب بناء", "بلاستيك").
  final String materialType;

  /// Canonical English slug for icon/routing logic
  /// (e.g. "used_cooking_oil", "wood", "plastic", "metal").
  final String materialTypeEn;

  final WasteGrade grade;

  /// Liters for liquids (oil), kg for solids, count for items (electronics).
  final double estimatedQuantity;

  /// 'لتر' | 'كغ' | 'قطعة'
  final String quantityUnit;

  final double estimatedPayoutMinJod;
  final double estimatedPayoutMaxJod;

  /// 2–3 Arabic sentences from Gemini assessing quality and recommending action.
  final String explanation;

  /// 1–2 short Arabic practical tips for the user (empty list is fine).
  final List<String> recycleTips;

  const WasteAnalysisResult({
    required this.isRecyclable,
    required this.materialType,
    required this.materialTypeEn,
    required this.grade,
    required this.estimatedQuantity,
    required this.quantityUnit,
    required this.estimatedPayoutMinJod,
    required this.estimatedPayoutMaxJod,
    required this.explanation,
    required this.recycleTips,
  });

  factory WasteAnalysisResult.fromJson(Map<String, dynamic> json) {
    return WasteAnalysisResult(
      isRecyclable: json['isRecyclable'] as bool? ?? false,
      materialType: json['materialType'] as String? ?? '',
      materialTypeEn: (json['materialTypeEn'] as String? ?? 'unknown')
          .toLowerCase(),
      grade: _parseGrade(json['grade'] as String? ?? 'rejected'),
      estimatedQuantity: (_coerceDouble(json['estimatedQuantity']) ?? 0).clamp(
        0.0,
        99999.0,
      ),
      quantityUnit: _parseUnit(json['quantityUnit'] as String? ?? 'كغ'),
      estimatedPayoutMinJod: (_coerceDouble(json['estimatedPayoutMinJod']) ?? 0)
          .clamp(0.0, 9999.0),
      estimatedPayoutMaxJod: (_coerceDouble(json['estimatedPayoutMaxJod']) ?? 0)
          .clamp(0.0, 9999.0),
      explanation: json['explanation'] as String? ?? '',
      recycleTips: _parseTips(json['recycleTips']),
    );
  }

  // ── Private parsers ────────────────────────────────────────────────────────

  static WasteGrade _parseGrade(String v) => switch (v.toUpperCase()) {
    'A' => WasteGrade.a,
    'B' => WasteGrade.b,
    'C' => WasteGrade.c,
    _ => WasteGrade.rejected,
  };

  /// Accepts Arabic units and English synonyms the model may emit.
  static String _parseUnit(String v) {
    final s = v.trim().toLowerCase();
    if (s == 'liter' || s == 'liters' || s == 'l' || s == 'لتر') return 'لتر';
    if (s == 'piece' || s == 'pieces' || s == 'قطعة' || s == 'قطع') {
      return 'قطعة';
    }
    return 'كغ'; // default for solids
  }

  static List<String> _parseTips(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  /// Tolerant numeric parser — Gemini sometimes emits strings even when JSON
  /// mode is active (e.g. `"estimatedQuantity": "5.0"`).
  static double? _coerceDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim());
    }
    return null;
  }

  // ── Display helpers ────────────────────────────────────────────────────────

  String get gradeLabel => switch (grade) {
    WasteGrade.a => 'A — ممتاز',
    WasteGrade.b => 'B — جيد',
    WasteGrade.c => 'C — مقبول',
    WasteGrade.rejected => 'مرفوض',
  };

  Color get gradeColor => switch (grade) {
    WasteGrade.a => const Color(0xFF1E5C35),
    WasteGrade.b => const Color(0xFFC8860A),
    WasteGrade.c => const Color(0xFFE53935),
    WasteGrade.rejected => const Color(0xFF991B1B),
  };

  Color get gradeSurface => switch (grade) {
    WasteGrade.a => const Color(0xFFD1FAE5),
    WasteGrade.b => const Color(0xFFFEF3C7),
    WasteGrade.c || WasteGrade.rejected => const Color(0xFFFEE2E2),
  };

  String get materialIcon => switch (materialTypeEn) {
    'used_cooking_oil' || 'cooking_oil' || 'oil' => '🛢️',
    'wood' || 'construction_wood' || 'lumber' || 'timber' => '🪵',
    'plastic' || 'plastic_pet' || 'plastic_hdpe' || 'pvc' => '♻️',
    'metal' ||
    'iron' ||
    'steel' ||
    'aluminum' ||
    'aluminium' ||
    'copper' => '⚙️',
    'paper' || 'cardboard' => '📄',
    'glass' => '🫙',
    'electronics' || 'e_waste' || 'ewaste' => '📱',
    'textile' || 'fabric' || 'clothes' || 'clothing' => '👕',
    'rubber' || 'tires' || 'tyres' => '⭕',
    'batteries' || 'battery' => '🔋',
    'chemicals' || 'chemical' => '⚗️',
    'furniture' => '🪑',
    'organic' => '🌿',
    _ => '♻️',
  };

  bool get hasEstimatedPayout =>
      estimatedPayoutMinJod > 0 || estimatedPayoutMaxJod > 0;

  String get payoutRangeLabel {
    if (!hasEstimatedPayout) return 'لا يوجد';
    if (estimatedPayoutMinJod == estimatedPayoutMaxJod) {
      return '${estimatedPayoutMinJod.toStringAsFixed(2)} دينار';
    }
    return '${estimatedPayoutMinJod.toStringAsFixed(2)} – '
        '${estimatedPayoutMaxJod.toStringAsFixed(2)} دينار';
  }

  String get quantityLabel {
    if (estimatedQuantity <= 0) return 'غير محدد';
    return '~${estimatedQuantity % 1 == 0 ? estimatedQuantity.toStringAsFixed(0) : estimatedQuantity.toStringAsFixed(1)} $quantityUnit';
  }
}
