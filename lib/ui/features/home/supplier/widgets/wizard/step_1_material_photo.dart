import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/core/constants/waste_type_icons.dart';
import 'package:dwaar/ui/features/home/supplier/controllers/publish_form_controller.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/image_picker_grid.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'wizard_style_tokens.dart';

class Step1MaterialAndPhoto extends StatelessWidget {
  final PublishFormController controller;

  const Step1MaterialAndPhoto({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _StepHeader(
            title: l10n.wizardStep1Title,
            subtitle: l10n.wizardStep1Subtitle,
          ),
          _FieldLabel(text: l10n.wizardMaterialPhotosOptional),
          const SizedBox(height: 10),
          ImagePickerGrid(
            imagePaths: controller.images,
            onAdd: controller.addImage,
            onRemove: controller.removeImage,
            onAnalyze: controller.runAiAnalysis,
          ),
          const SizedBox(height: 16),
          if (controller.aiController.isAnalyzing)
            _aiAnalyzingBanner(l10n)
          else if (controller.aiError != null)
            _aiErrorBanner(l10n, controller.aiError!)
          else if (controller.aiController.filledFieldLabels.isNotEmpty)
            _aiFilledBanner(controller.aiController.filledFieldLabels),
          const SizedBox(height: 24),
          _FieldLabel(text: l10n.wizardMaterialTypeRequired),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: WasteTypeIcons.all.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, i) {
              final (type, icon) = WasteTypeIcons.all[i];
              final isSelected = controller.selectedTypes.contains(type);
              return _MaterialTypeCard(
                type: type,
                icon: icon,
                selected: isSelected,
                onTap: () => controller.toggleWasteType(type),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _aiAnalyzingBanner(AppLocalizations l10n) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF1E40AF).withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF1E40AF),
          ),
        ),
        const Spacer(),
        Text(
          l10n.wizardAiAnalyzing,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.psychology_rounded,
          size: 22,
          color: Color(0xFF1E40AF),
        ),
      ],
    ),
  );

  Widget _aiFilledBanner(List<String> labels) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF065F46).withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF065F46).withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: labels
                .map(
                  (f) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF065F46).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.verified_rounded, size: 22, color: Color(0xFF065F46)),
      ],
    ),
  );

  Widget _aiErrorBanner(AppLocalizations l10n, String error) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFC62828).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.2)),
    ),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close, size: 18, color: Color(0xFFC62828)),
          onPressed: controller.clearAiError,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            l10n.wizardAiAnalysisFailed(error),
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC62828),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(
          Icons.error_outline_rounded,
          size: 22,
          color: Color(0xFFC62828),
        ),
      ],
    ),
  );
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: WizardColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: WizardColors.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: WizardColors.textSecondary,
        ),
      ),
    );
  }
}

class _MaterialTypeCard extends StatelessWidget {
  final WasteType type;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MaterialTypeCard({
    required this.type,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? WizardColors.primaryLight : WizardColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? WizardColors.borderSelected : WizardColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? WizardColors.primaryBorder
                    : WizardColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected
                    ? WizardColors.primaryMid
                    : WizardColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              type.label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected
                    ? WizardColors.primaryMid
                    : WizardColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
