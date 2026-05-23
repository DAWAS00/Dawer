import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/publish_form_controller.dart';

class WizardBottomActions extends StatelessWidget {
  final PublishFormController controller;
  final VoidCallback onPublish;

  const WizardBottomActions({
    super.key,
    required this.controller,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = controller.currentStep == 2;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          if (controller.currentStep > 0) ...[
            _CircleIconBtn(
              icon: Icons.arrow_forward_ios_rounded,
              onTap: controller.prevStep,
              size: 48,
              bordered: true,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isLast
                  ? _PrimaryButton(
                      key: const ValueKey('publish'),
                      label: 'نشر الإعلان',
                      icon: Icons.campaign_outlined,
                      onTap: controller.canProceed ? onPublish : null,
                      color: const Color(0xFF2E7D32),
                    )
                  : _PrimaryButton(
                      key: const ValueKey('next'),
                      label: 'التالي',
                      icon: Icons.arrow_back_ios_rounded,
                      onTap: controller.canProceed ? controller.nextStep : null,
                      color: const Color(0xFF06402B),
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
  final double size;
  final bool bordered;

  const _CircleIconBtn({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(size / 3),
          border: bordered ? Border.all(color: const Color(0xFFE0E0E0)) : null,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF6B6B6B)),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? color : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
