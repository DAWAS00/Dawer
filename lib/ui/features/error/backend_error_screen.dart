import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BackendErrorScreen extends StatelessWidget {
  const BackendErrorScreen({super.key, required this.detail});
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06402B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 24),
              Text(
                'تعذّر الاتصال بالخادم',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى التحقق من اتصالك بالإنترنت والمحاولة مجدداً.\nإذا استمرت المشكلة، تواصل مع الدعم الفني.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              if (detail.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  detail,
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
