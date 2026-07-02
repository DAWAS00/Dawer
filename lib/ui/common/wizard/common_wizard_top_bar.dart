import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonWizardTopBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final String title;
  final List<String> stepTitles;

  const CommonWizardTopBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.title,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _CircleIconBtn(icon: Icons.arrow_forward_ios_rounded, onTap: onBack),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                if (currentStep < stepTitles.length)
                  Text(
                    stepTitles[currentStep],
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentStep + 1} / $totalSteps',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF6B6B6B)),
      ),
    );
  }
}
