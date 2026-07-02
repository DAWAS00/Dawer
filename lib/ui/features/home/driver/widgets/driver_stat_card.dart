import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const DriverStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF717973),
            ),
          ),
        ],
      ),
    );
  }
}
