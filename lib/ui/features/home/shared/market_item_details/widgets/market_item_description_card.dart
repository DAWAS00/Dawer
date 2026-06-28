import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketItemDescriptionCard extends StatelessWidget {
  final String? notes;

  const MarketItemDescriptionCard({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes!.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                'وصف المنتج',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF06402B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: Color(0xFF06402B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notes!,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: const Color(0xFF404943),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
