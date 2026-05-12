import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/order.dart';
import '../../domain/services/carbon_calculator.dart';

/// Computes and displays the total CO₂ saved across a list of completed orders.
///
/// Shows nothing (zero-height) when no weight data is available.
class CarbonBadge extends StatelessWidget {
  const CarbonBadge({super.key, required this.orders, this.compact = false});

  final List<Order> orders;
  final bool compact;

  double _totalCo2() {
    double total = 0;
    for (final o in orders) {
      final w = o.weightKg ?? o.estimatedWeightKg;
      if (w == null || w <= 0 || o.wasteTypes.isEmpty) continue;
      total += CarbonCalculator.savedKgCo2Multi(o.wasteTypes, w);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final co2 = _totalCo2();
    if (co2 <= 0) return const SizedBox.shrink();

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF166534)),
          const SizedBox(width: 4),
          Text(
            CarbonCalculator.label(co2),
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF166534),
            ),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CarbonCalculator.label(co2),
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF14532D),
                  ),
                ),
                Text(
                  'CO₂ تم توفيرها من البيئة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
