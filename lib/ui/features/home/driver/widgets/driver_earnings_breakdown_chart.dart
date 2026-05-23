import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../viewmodels/driver_earnings_viewmodel.dart';

class DriverEarningsBreakdownChart extends StatelessWidget {
  final DriverEarningsSummary summary;

  const DriverEarningsBreakdownChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    if (summary.jdByType.isEmpty) return const SizedBox.shrink();

    final sorted = summary.jdByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأرباح حسب نوع النفايات',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((e) => _buildBar(e.key, e.value, max)),
        ],
      ),
    );
  }

  Widget _buildBar(WasteType type, double jd, double max) {
    final fraction = max > 0 ? (jd / max).clamp(0.05, 1.0) : 0.05;
    final trips = summary.tripsByType[type] ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              type.label,
              style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF404943)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A5E3E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${jd.toStringAsFixed(2)} د',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
              if (trips > 0)
                Text(
                  '$trips رحلة',
                  style: GoogleFonts.cairo(fontSize: 9, color: const Color(0xFF9099A2)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
