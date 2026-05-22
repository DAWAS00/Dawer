import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen image preview with pinch-to-zoom and swipe-to-dismiss.
/// Optionally shows a re-analyze button when [onAnalyze] is provided.
class ImagePreviewOverlay extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onAnalyze;

  const ImagePreviewOverlay({
    super.key,
    required this.imagePath,
    this.onAnalyze,
  });

  static Future<void> show(
    BuildContext context, {
    required String imagePath,
    VoidCallback? onAnalyze,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => ImagePreviewOverlay(
          imagePath: imagePath,
          onAnalyze: onAnalyze,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tap outside image
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const ColoredBox(
              color: Colors.transparent,
              child: SizedBox.expand(),
            ),
          ),

          // Zoomable image
          Center(
            child: Hero(
              tag: 'img_preview_$imagePath',
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5.0,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Toolbar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (onAnalyze != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onAnalyze!();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E40AF).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                size: 15, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'إعادة التحليل',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
