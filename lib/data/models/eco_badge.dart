import 'package:flutter/material.dart';

enum EcoBadgeType {
  firstStep,        // 1st order completed
  recycleChampion,  // 10 kg lifetime
  oilSaver,         // 25 kg oil lifetime
  ecoHero,          // 100 kg lifetime (Dr. Mansour milestone)
  recycleLegend,    // 500 kg lifetime
}

/// A supplier achievement badge earned through real collection activity.
class EcoBadge {
  final EcoBadgeType type;
  final String emoji;
  final String label;
  final String description;

  /// kg threshold that unlocks this badge (0 = order-count based).
  final double kgThreshold;

  /// orders threshold (used when kgThreshold == 0).
  final int ordersThreshold;

  final Color color;
  final Color surface;

  const EcoBadge({
    required this.type,
    required this.emoji,
    required this.label,
    required this.description,
    required this.kgThreshold,
    required this.ordersThreshold,
    required this.color,
    required this.surface,
  });

  bool isEarned({required double lifetimeKg, required int completedOrders}) {
    if (kgThreshold > 0) return lifetimeKg >= kgThreshold;
    return completedOrders >= ordersThreshold;
  }

  String get requirementLabel {
    if (kgThreshold > 0) return '${kgThreshold.toStringAsFixed(0)} كغ مجمّعة';
    return '$ordersThreshold طلبات مكتملة';
  }

  // ── All available badges ──────────────────────────────────────────────────

  static const List<EcoBadge> all = [
    EcoBadge(
      type: EcoBadgeType.firstStep,
      emoji: '🌱',
      label: 'أول خطوة',
      description: 'أكملت أول طلب تدوير!',
      kgThreshold: 0,
      ordersThreshold: 1,
      color: Color(0xFF166534),
      surface: Color(0xFFDCFCE7),
    ),
    EcoBadge(
      type: EcoBadgeType.recycleChampion,
      emoji: '♻️',
      label: 'بطل التدوير',
      description: 'جمعت 10 كغ من المواد القابلة للتدوير',
      kgThreshold: 10,
      ordersThreshold: 0,
      color: Color(0xFF0369A1),
      surface: Color(0xFFE0F2FE),
    ),
    EcoBadge(
      type: EcoBadgeType.oilSaver,
      emoji: '🛢️',
      label: 'محارب الزيت',
      description: 'جمعت 25 كغ من الزيت المستعمل',
      kgThreshold: 25,
      ordersThreshold: 0,
      color: Color(0xFFC8860A),
      surface: Color(0xFFFEF3C7),
    ),
    EcoBadge(
      type: EcoBadgeType.ecoHero,
      emoji: '🌟',
      label: 'بطل إيكو',
      description: 'جمعت 100 كغ — أنت بطل حقيقي للبيئة!',
      kgThreshold: 100,
      ordersThreshold: 0,
      color: Color(0xFF7C3AED),
      surface: Color(0xFFF5F3FF),
    ),
    EcoBadge(
      type: EcoBadgeType.recycleLegend,
      emoji: '🏆',
      label: 'أسطورة التدوير',
      description: 'جمعت 500 كغ — أنت أسطورة!',
      kgThreshold: 500,
      ordersThreshold: 0,
      color: Color(0xFFB45309),
      surface: Color(0xFFFFF7ED),
    ),
  ];
}
