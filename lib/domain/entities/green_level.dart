// lib/domain/entities/green_level.dart

import '../../core/constants/green_credits_config.dart';

/// The four experience levels in the خُضَر reward ladder.
enum GreenLevel {
  seedling, // 0 – 499 خُضَر
  sapling, // 500 – 1999 خُضَر
  tree, // 2000 – 4999 خُضَر
  forestGuardian, // 5000+ خُضَر
}

extension GreenLevelInfo on GreenLevel {
  /// Arabic display name shown in the level badge.
  String get arabicLabel => switch (this) {
    GreenLevel.seedling => 'شتلة',
    GreenLevel.sapling => 'غرسة',
    GreenLevel.tree => 'شجرة',
    GreenLevel.forestGuardian => 'حارس الغابة',
  };

  /// Emoji prefix for the level badge.
  String get emoji => switch (this) {
    GreenLevel.seedling => '🌱',
    GreenLevel.sapling => '🌿',
    GreenLevel.tree => '🌳',
    GreenLevel.forestGuardian => '🌍',
  };

  /// One-line description of the unlock benefit at this level.
  String get unlockDescription => switch (this) {
    GreenLevel.seedling => 'تطابق معياري',
    GreenLevel.sapling => 'أولوية المطابقة مع السائقين',
    GreenLevel.tree => 'الوصول إلى وظائف السوق المتميزة',
    GreenLevel.forestGuardian => 'خصم رسوم المنصة + شهادة CO₂',
  };

  /// Points required to enter the NEXT level.
  /// Returns [GreenCreditsConfig.forestGuardianThreshold] when already at max.
  int get nextThreshold => switch (this) {
    GreenLevel.seedling => GreenCreditsConfig.saplingThreshold,
    GreenLevel.sapling => GreenCreditsConfig.treeThreshold,
    GreenLevel.tree => GreenCreditsConfig.forestGuardianThreshold,
    GreenLevel.forestGuardian => GreenCreditsConfig.forestGuardianThreshold,
  };

  /// Points at which THIS level begins (lower bound, inclusive).
  int get lowerThreshold => switch (this) {
    GreenLevel.seedling => 0,
    GreenLevel.sapling => GreenCreditsConfig.saplingThreshold,
    GreenLevel.tree => GreenCreditsConfig.treeThreshold,
    GreenLevel.forestGuardian => GreenCreditsConfig.forestGuardianThreshold,
  };

  bool get isMaxLevel => this == GreenLevel.forestGuardian;

  /// Derive the level from a raw خُضَر balance.
  static GreenLevel fromPoints(int points) {
    if (points >= GreenCreditsConfig.forestGuardianThreshold) {
      return GreenLevel.forestGuardian;
    }
    if (points >= GreenCreditsConfig.treeThreshold) {
      return GreenLevel.tree;
    }
    if (points >= GreenCreditsConfig.saplingThreshold) {
      return GreenLevel.sapling;
    }
    return GreenLevel.seedling;
  }
}
