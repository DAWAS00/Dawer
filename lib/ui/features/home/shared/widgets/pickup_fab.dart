import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PickupFab extends StatelessWidget {
  final VoidCallback onPressed;

  const PickupFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF06402B),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'طلب استلام',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}
