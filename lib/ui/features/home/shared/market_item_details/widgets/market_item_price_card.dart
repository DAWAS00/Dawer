import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../data/models/order.dart';

class MarketItemPriceCard extends StatelessWidget {
  final Order item;

  const MarketItemPriceCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Text(
            '${item.itemPrice?.toStringAsFixed(1) ?? '0'} د.أ',
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC8860A),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'سعر المواد',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF92400E),
                ),
              ),
              Text(
                'قابل للتفاوض',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFC8860A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sell_rounded, color: Color(0xFFC8860A), size: 24),
          ),
        ],
      ),
    );
  }
}
