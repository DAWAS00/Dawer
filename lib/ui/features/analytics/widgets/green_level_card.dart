// lib/ui/features/analytics/widgets/green_level_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/green_level.dart';

/// Displays a user's خُضَر balance, level badge (emoji + Arabic name),
/// unlock benefit text, and a progress bar toward the next level.
///
/// Intended to be placed inside the Analytics tab's CustomScrollView.
class GreenLevelCard extends StatelessWidget {
  const GreenLevelCard({
    super.key,
    required this.greenPoints,
  });

  /// The user's current cumulative خُضَر balance.
  final int greenPoints;

  @override
  Widget build(BuildContext context) {
    final level = GreenLevelInfo.fromPoints(greenPoints);
    final progress = level.isMaxLevel
        ? 1.0
        : ((greenPoints - level.lowerThreshold) /
               (level.nextThreshold - level.lowerThreshold))
            .clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Emoji badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  level.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              // Level name + unlock description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.arabicLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.unlockDescription,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // خُضَر balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$greenPoints',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    'خُضَر',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.13),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 6),
          // Progress label
          Text(
            level.isMaxLevel
                ? 'وصلت للمستوى الأعلى 🎉'
                : '$greenPoints / ${level.nextThreshold} للمستوى التالي',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: level.isMaxLevel
                  ? AppColors.primaryGreen
                  : AppColors.mutedText,
              fontWeight: level.isMaxLevel
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
