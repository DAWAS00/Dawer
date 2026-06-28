import 'package:flutter/material.dart';

enum OilGrade { a, b, c, rejected }

enum WaterContent { none, low, high }

enum ImpurityLevel { clean, moderate, heavy }

/// Structured result returned by [GeminiOilAnalysisService].
class OilAnalysisResult {
  final bool isUsedCookingOil;
  final WaterContent waterContent;
  final ImpurityLevel impurityLevel;
  final OilGrade grade;
  final double estimatedLiters;
  final double estimatedPayoutMinJod;
  final double estimatedPayoutMaxJod;

  /// 2–3 Arabic sentences from Gemini explaining the assessment.
  final String explanation;

  const OilAnalysisResult({
    required this.isUsedCookingOil,
    required this.waterContent,
    required this.impurityLevel,
    required this.grade,
    required this.estimatedLiters,
    required this.estimatedPayoutMinJod,
    required this.estimatedPayoutMaxJod,
    required this.explanation,
  });

  factory OilAnalysisResult.fromJson(Map<String, dynamic> json) {
    return OilAnalysisResult(
      isUsedCookingOil: json['isUsedCookingOil'] as bool? ?? false,
      waterContent: _parseWater(json['waterContent'] as String? ?? 'none'),
      impurityLevel: _parseImpurity(json['impurityLevel'] as String? ?? 'clean'),
      grade: _parseGrade(json['grade'] as String? ?? 'rejected'),
      estimatedLiters: (json['estimatedLiters'] as num? ?? 0).toDouble(),
      estimatedPayoutMinJod:
          (json['estimatedPayoutMinJod'] as num? ?? 0).toDouble(),
      estimatedPayoutMaxJod:
          (json['estimatedPayoutMaxJod'] as num? ?? 0).toDouble(),
      explanation: json['explanation'] as String? ?? '',
    );
  }

  static WaterContent _parseWater(String v) => switch (v) {
        'low' => WaterContent.low,
        'high' => WaterContent.high,
        _ => WaterContent.none,
      };

  static ImpurityLevel _parseImpurity(String v) => switch (v) {
        'moderate' => ImpurityLevel.moderate,
        'heavy' => ImpurityLevel.heavy,
        _ => ImpurityLevel.clean,
      };

  static OilGrade _parseGrade(String v) => switch (v.toUpperCase()) {
        'A' => OilGrade.a,
        'B' => OilGrade.b,
        'C' => OilGrade.c,
        _ => OilGrade.rejected,
      };

  // ── Display helpers ────────────────────────────────────────────────────────

  String get gradeLabel => switch (grade) {
        OilGrade.a => 'A — ممتاز',
        OilGrade.b => 'B — جيد',
        OilGrade.c => 'C — مقبول',
        OilGrade.rejected => 'مرفوض',
      };

  Color get gradeColor => switch (grade) {
        OilGrade.a => const Color(0xFF1E5C35),
        OilGrade.b => const Color(0xFFC8860A),
        OilGrade.c => const Color(0xFFE53935),
        OilGrade.rejected => const Color(0xFF991B1B),
      };

  Color get gradeSurface => switch (grade) {
        OilGrade.a => const Color(0xFFD1FAE5),
        OilGrade.b => const Color(0xFFFEF3C7),
        OilGrade.c => const Color(0xFFFEE2E2),
        OilGrade.rejected => const Color(0xFFFEE2E2),
      };

  String get waterLabel => switch (waterContent) {
        WaterContent.none => 'لا يوجد',
        WaterContent.low => 'منخفض',
        WaterContent.high => 'مرتفع',
      };

  Color get waterColor => switch (waterContent) {
        WaterContent.none => const Color(0xFF1E5C35),
        WaterContent.low => const Color(0xFFC8860A),
        WaterContent.high => const Color(0xFF991B1B),
      };

  String get impurityLabel => switch (impurityLevel) {
        ImpurityLevel.clean => 'نظيف',
        ImpurityLevel.moderate => 'متوسط',
        ImpurityLevel.heavy => 'شديد',
      };

  Color get impurityColor => switch (impurityLevel) {
        ImpurityLevel.clean => const Color(0xFF1E5C35),
        ImpurityLevel.moderate => const Color(0xFFC8860A),
        ImpurityLevel.heavy => const Color(0xFF991B1B),
      };

  bool get hasEstimatedPayout =>
      estimatedPayoutMinJod > 0 || estimatedPayoutMaxJod > 0;

  String get payoutRangeLabel {
    if (!hasEstimatedPayout) return 'لا يوجد';
    return '${estimatedPayoutMinJod.toStringAsFixed(2)} – '
        '${estimatedPayoutMaxJod.toStringAsFixed(2)} دينار';
  }
}
