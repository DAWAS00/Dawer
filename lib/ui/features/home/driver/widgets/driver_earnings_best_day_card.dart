import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/l10n/l10n.dart';

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
    final l10n = context.l10n;

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
                l10n.earningsBestDay,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF92400E),
                ),
              ),
              Text(
                '${bestDayJd.toStringAsFixed(2)} ${l10n.currencyJodShort}',
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
                _weekdayName(bestDay!.weekday, l10n),
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

  static String _weekdayName(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case DateTime.monday: return l10n.weekdayMonday;
      case DateTime.tuesday: return l10n.weekdayTuesday;
      case DateTime.wednesday: return l10n.weekdayWednesday;
      case DateTime.thursday: return l10n.weekdayThursday;
      case DateTime.friday: return l10n.weekdayFriday;
      case DateTime.saturday: return l10n.weekdaySaturday;
      case DateTime.sunday: return l10n.weekdaySunday;
      default: return '';
    }
  }
}
