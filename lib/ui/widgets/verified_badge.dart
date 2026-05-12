import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Small inline badge shown next to a supplier or company name when verified.
/// Usage: place inside a [Row] alongside the name text.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified_rounded, size: size, color: const Color(0xFF0A5E3E)),
        const SizedBox(width: 3),
        Text(
          'موثّق',
          style: GoogleFonts.cairo(
            fontSize: size * 0.75,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A5E3E),
          ),
        ),
      ],
    );
  }
}

/// Overlay badge for profile avatars — positioned at bottom-right of a Stack.
class VerifiedAvatarOverlay extends StatelessWidget {
  const VerifiedAvatarOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.verified_rounded, color: Color(0xFF0A5E3E), size: 20),
    );
  }
}
