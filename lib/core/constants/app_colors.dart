import 'package:flutter/material.dart';

class AppColors {
  // Brand Tokens (Committed Color Strategy - Shamrock)
  static const Color primaryGreen = Color(0xFF0F5A34); // Deep, rich brand hue
  static const Color primaryDark = Color(0xFF06331C); // Very dark tint for high contrast
  static const Color accentAmber = Color(0xFFD97706); // Action accent
  static const Color amberContainer = Color(0xFFFEF3C7); // Legacy warning container

  // Tinted Neutrals (Tinted slightly towards primary green to avoid muddy grays)
  static const Color background = Color(0xFFF3F7F5); // #F3F7F5 OKLCH approx
  static const Color surface = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8E5);
  static const Color mutedText = Color(0xFF6A7973);
  static const Color textMain = Color(0xFF14241C);

  // Status Colors (Softer backgrounds, high contrast text)
  static const Color statusPendingBg = Color(0xFFFEF3C7);
  static const Color statusPendingText = Color(0xFF92400E);
  static const Color statusActiveBg = Color(0xFFD1FAE5);
  static const Color statusActiveText = Color(0xFF065F46);
  static const Color statusInTransitBg = Color(0xFFDBEAFE);
  static const Color statusInTransitText = Color(0xFF1E40AF);
  static const Color statusCompletedBg = Color(0xFFDCFCE7);
  static const Color statusCompletedText = Color(0xFF166534);
  static const Color statusCancelledBg = Color(0xFFFEE2E2);
  static const Color statusCancelledText = Color(0xFF991B1B);

  // Gradient Tokens
  static const Color ctaGradientStart = Color(0xFF0A4D2A);
  static const Color ctaGradientEnd = Color(0xFF127B45);
  static const Color headerGradientEnd = Color(0xFF1B8A52);

  // Map Tokens
  static const Color mapPickupPin = Color(0xFF06402B);
  static const Color mapDropoffPin = Color(0xFFE53935);
  static const Color mapRouteLine = Color(0xFF0F5A34);
  static const Color mapSurface = Color(0xFFE8F5E9);
  
  // Marketplace — Job Blue (collection jobs distinct visual treatment)
  static const Color jobBlue = Color(0xFF1E40AF);
  static const Color jobBlueBg = Color(0xFFEFF6FF);
  static const Color jobBlueBorder = Color(0xFFBFDBFE);

  // Marketplace — Surface Alt (green-tinted chip/tag background)
  static const Color surfaceAlt = Color(0xFFEEF4EE);
  static const Color surfaceAltBorder = Color(0xFFC8DFCE);

  // Legacy Shamrock Palette (Kept for compatibility, try to migrate to semantic names)
  static const Color shamrock50 = Color(0xFFFFFFFF);
  static const Color shamrock100 = Color(0xFF8DFFDA);
  static const Color shamrock200 = Color(0xFF57F9C6);
  static const Color shamrock300 = Color(0xFF5CEBBC);
  static const Color shamrock400 = Color(0xFF5ED0B4);
  static const Color shamrock500 = Color(0xFF61D6AE);
  static const Color shamrock600 = Color(0xFF5DC39F);
  static const Color shamrock700 = Color(0xFF56AB8D);
  static const Color shamrock800 = Color(0xFF4A8F77);
  static const Color shamrock900 = Color(0xFF3C715E);
  static const Color shamrock1000 = Color(0xFF315E4E);
  static const Color shamrock1100 = Color(0xFF244A3C);
  static const Color shamrock1200 = Color(0xFF17352A);
  static const Color shamrock1300 = Color(0xFF0B2219);
}
