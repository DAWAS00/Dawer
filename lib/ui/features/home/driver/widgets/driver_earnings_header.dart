import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/driver_earnings_viewmodel.dart';

class DriverEarningsHeader extends StatelessWidget {
  final DriverEarningsSummary summary;
  final EarningsPeriod currentPeriod;
  final ValueChanged<EarningsPeriod> onPeriodChanged;

  const DriverEarningsHeader({
    super.key,
    required this.summary,
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF002819),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _PeriodChip(
                label: 'شهر',
                isSelected: currentPeriod == EarningsPeriod.month,
                onTap: () => onPeriodChanged(EarningsPeriod.month),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'أسبوع',
                isSelected: currentPeriod == EarningsPeriod.week,
                onTap: () => onPeriodChanged(EarningsPeriod.week),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'يوم',
                isSelected: currentPeriod == EarningsPeriod.day,
                onTap: () => onPeriodChanged(EarningsPeriod.day),
              ),
              const Spacer(),
              Text(
                'الأرباح',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'إجمالي الأرباح الصافية',
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'د.أ',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                summary.totalEarnings.toStringAsFixed(2),
                style: GoogleFonts.dmSans(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Color(0xFF4ADE80), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+${summary.netGrowth}%',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'زيادة عن الفترة السابقة',
                style: GoogleFonts.cairo(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF002819) : Colors.white,
          ),
        ),
      ),
    );
  }
}
