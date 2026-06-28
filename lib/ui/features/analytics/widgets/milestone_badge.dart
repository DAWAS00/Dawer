import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class MilestoneBadge extends StatelessWidget {
  const MilestoneBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.achieved,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool achieved;

  @override
  Widget build(BuildContext context) {
    final color = achieved ? AppColors.primaryGreen : const Color(0xFFD1D5DB);
    final bg = achieved
        ? AppColors.primaryGreen.withValues(alpha: 0.08)
        : const Color(0xFFF9FAFB);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved
              ? AppColors.primaryGreen.withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (achieved)
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: achieved ? AppColors.textMain : const Color(0xFF9CA3AF),
            ),
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: achieved ? AppColors.mutedText : const Color(0xFFD1D5DB),
            ),
          ),
        ],
      ),
    );
  }
}
