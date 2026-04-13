import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../../../../core/constants/app_colors.dart';

class NewPickupRequestView extends StatelessWidget {
  final WasteType? preselectedWasteType;

  const NewPickupRequestView({super.key, this.preselectedWasteType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(
          'طلب استلام جديد',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_box_rounded, size: 64, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 24),
            Text(
              'قريباً...',
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
            const SizedBox(height: 8),
            Text(
              'نموذج طلب الاستلام قيد التطوير',
              style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF717973)),
            ),
            if (preselectedWasteType != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.ctaGradientStart,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  preselectedWasteType!.label,
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
