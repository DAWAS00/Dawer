import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'app_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.cairoTextTheme();

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentAmber,
        surface: AppColors.surface,
        error: AppColors.statusCancelledBg,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF191C1B),
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF191C1B),
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF191C1B),
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF191C1B),
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.mutedText,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF191C1B),
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE6E9E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme);
    
    const textPrimary = Color(0xFFF0F7F2);
    const textSecondary = Color(0xFF94A3B8);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.shamrock400,
      scaffoldBackgroundColor: AppColors.shamrock1300,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.shamrock400,
        secondary: Color(0xFFFBBF24), // Lighter accent amber for dark mode
        surface: AppColors.shamrock1200,
        error: Color(0xFFF87171),
        onSurface: textPrimary,
        outline: AppColors.shamrock1000,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.shamrock1200,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.shamrock400,
          foregroundColor: AppColors.shamrock1300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.shamrock1100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.shamrock1200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.shamrock1200,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.shamrock1000, width: 1),
        ),
      ),
      extensions: [AppTokens.dark],
    );
  }

  static TextStyle dmSans(TextStyle style) {
    return GoogleFonts.dmSans(textStyle: style);
  }
}

