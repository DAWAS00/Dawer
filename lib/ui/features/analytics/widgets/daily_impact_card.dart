import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/utils/eco_impact_calculator.dart';

/// "Today's report" card — shared across all roles. Shows what was
/// processed today (orders + weight) and the resulting environmental
/// impact (CO₂/water/energy saved), independent of the analytics period
/// filter so it always reflects the current day.
class DailyImpactCard extends StatelessWidget {
  const DailyImpactCard({
    super.key,
    required this.impact,
    required this.orderCount,
    required this.weightKg,
    required this.date,
  });

  final EcoImpactResult impact;
  final int orderCount;
  final double weightKg;
  final DateTime date;

  static const _weekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  String get _dateLabel {
    final day = _weekdays[date.weekday - 1];
    return '$day، ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
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
              Icon(
                Icons.today_rounded,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تقرير اليوم — $_dateLabel',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '$orderCount',
                  label: 'طلبات مكتملة',
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '${weightKg.toStringAsFixed(0)} كغ',
                  label: 'وزن معالج',
                  icon: Icons.scale_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '${impact.co2SavedKg.toStringAsFixed(1)} كغ',
                  label: 'CO₂ وُفِّر',
                  icon: Icons.eco_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '${impact.waterSavedLiters.toStringAsFixed(0)} ل',
                  label: 'مياه وُفِّرت',
                  icon: Icons.water_drop_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '${impact.energySavedKwh.toStringAsFixed(1)} kWh',
                  label: 'طاقة وُفِّرت',
                  icon: Icons.bolt_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 10, color: AppColors.mutedText),
        ),
      ],
    );
  }
}
