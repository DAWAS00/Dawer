import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverEarningsBestDayCard extends StatelessWidget {
  final DateTime? bestDay;
  final double bestDayJd;

  const DriverEarningsBestDayCard({
    super.key,
    required this.bestDay,
    required this.bestDayJd,
  });

  @override
  Widget build(BuildContext context) {
    if (bestDay == null || bestDayJd <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: Color(0xFFD97706),
            size: 36,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'يومك الأفضل',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF92400E),
                ),
              ),
              Text(
                '${bestDayJd.toStringAsFixed(2)} د.أ',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF78350F),
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _arabicDayName(bestDay!.weekday),
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF92400E),
                ),
              ),
              Text(
                '${bestDay!.day}/${bestDay!.month}/${bestDay!.year}',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _arabicDayName(int weekday) {
    const names = [
      '',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekday < names.length ? names[weekday] : '';
  }
}
