import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/utils/haptic_util.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_wizard_controller.dart';

class SignupWizardBottomActions extends StatelessWidget {
  final SignupWizardController controller;

  const SignupWizardBottomActions({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = controller.currentStep == 3;
    final isScanning = controller.isScanning;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          if (controller.currentStep > 0 && !isScanning)
            _CircleIconButton(
              icon: Icons.arrow_forward_ios_rounded,
              onTap: () {
                HapticUtil.light();
                controller.prevStep();
              },
            ),
          const SizedBox(width: 12),
          Expanded(
            child: _PrimaryButton(
              label: isLast ? 'إنشاء الحساب' : 'التالي',
              isLoading: controller.isLoading,
              onTap: isScanning ? null : () {
                HapticUtil.medium();
                if (isLast) {
                  controller.submit();
                } else {
                  controller.nextStep();
                }
              },
              color: isLast ? const Color(0xFF1B5E20) : const Color(0xFF06402B),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 20),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color color;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: enabled ? color : const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
