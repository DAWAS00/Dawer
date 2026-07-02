import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/layout/app_layout.dart';

class DriverKpiRow extends StatelessWidget {
  const DriverKpiRow({
    super.key,
    required this.earnings,
    required this.completedCount,
    this.rating = 5.0,
  });

  final double earnings;
  final int completedCount;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              icon: LucideIcons.coins,
              value: '${earnings.toStringAsFixed(1)} د.أ',
              label: 'الأرباح',
              gradientColors: const [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
              accentColor: AppColors.accentAmber,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: LucideIcons.checkCircle2,
              value: '$completedCount',
              label: 'الرحلات',
              gradientColors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              accentColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: LucideIcons.star,
              value: rating.toStringAsFixed(1),
              label: 'التقييم',
              gradientColors: const [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
              accentColor: const Color(0xFF6A1B9A),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradientColors,
    required this.accentColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradientColors;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final small = context.layout.isSmall;
    final iconSize = small ? 32.0 : 38.0;
    final valueFontSize = small ? 14.0 : 16.0;
    final labelFontSize = small ? 10.0 : 11.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: iconSize * 0.5, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              color: accentColor,
              height: 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
