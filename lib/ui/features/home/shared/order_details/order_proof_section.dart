import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../core/components/dwaar_detail_card.dart';

class OrderProofSection extends StatelessWidget {
  final String imagePath;

  const OrderProofSection({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DwaarDetailSection(
      icon: Icons.check_circle_rounded,
      title: 'إثبات الاستلام والتسليم',
      accentColor: AppColors.primaryGreen,
      elevation: DwaarCardElevation.raised,
      animationIndex: 0,
      child: _ProofImageCard(imagePath: imagePath),
    );
  }
}

// ── Proof Image Card ─────────────────────────────────────────────────────────

class _ProofImageCard extends StatelessWidget {
  final String imagePath;
  const _ProofImageCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ── Image ──
            Image.file(
              File(imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD0EAD6),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.mutedText.withValues(alpha: 0.7),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الرابط يشير لملف غير متوفر مؤقتاً',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Verified Badge Overlay ──
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تم التحقق',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    delay: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
