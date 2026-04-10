import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showArrow;

  const DriverProfileTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF06402B)),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const Spacer(),
          if (value.isNotEmpty)
            Text(
              value,
              textDirection: TextDirection.ltr,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF717973),
                fontWeight: FontWeight.w600,
              ),
            ),
          if (showArrow) ...[
            if (value.isNotEmpty) const SizedBox(width: 12),
            const Icon(Icons.chevron_left_rounded, color: Color(0xFFC0C9C1), size: 20),
          ]
        ],
      ),
    );
  }
}
