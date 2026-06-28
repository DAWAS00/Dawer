import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/ui/features/home/supplier/controllers/publish_form_controller.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'wizard_style_tokens.dart';

class Step2QuantityAndPrice extends StatelessWidget {
  final PublishFormController controller;

  const Step2QuantityAndPrice({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _StepHeader(
            title: l10n.wizardStep2Title,
            subtitle: l10n.wizardStep2Subtitle,
          ),
          _FieldLabel(text: l10n.wizardMaterialCondition),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: WasteForm.values.map((form) {
              final isSelected = controller.wasteForm == form;
              return _ConditionChip(
                label: form.label,
                icon: _getIconForWasteForm(form),
                selected: isSelected,
                onTap: () => controller.selectWasteForm(form),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _FieldLabel(text: l10n.wizardQuantitySize),
          const SizedBox(height: 10),
          ...WeightCategory.values.map((cat) {
            final isSelected = controller.weightCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _QuantityCard(
                label: cat.shortLabel,
                range: cat.label,
                icon: _getIconForWeightCategory(cat),
                selected: isSelected,
                onTap: () => controller.selectWeightCategory(cat),
              ),
            );
          }),
          const SizedBox(height: 24),
          _FieldLabel(text: l10n.wizardRequestedPrice),
          const SizedBox(height: 10),
          _PriceInput(controller: controller.priceCtrl),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _getIconForWasteForm(WasteForm form) {
    switch (form) {
      case WasteForm.solid: return Icons.crop_square_outlined;
      case WasteForm.liquid: return Icons.water_drop_outlined;
      case WasteForm.gas: return Icons.air_outlined;
      case WasteForm.mixed: return Icons.layers_outlined;
    }
  }

  IconData _getIconForWeightCategory(WeightCategory cat) {
    switch (cat) {
      case WeightCategory.light: return Icons.eco_outlined;
      case WeightCategory.medium: return Icons.straighten_outlined;
      case WeightCategory.heavy: return Icons.fitness_center_outlined;
      case WeightCategory.veryHeavy: return Icons.local_shipping_outlined;
    }
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ConditionChip({
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? WizardColors.primaryLight : WizardColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? WizardColors.borderSelected : WizardColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? WizardColors.primaryMid : WizardColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 16,
              color: selected ? WizardColors.primaryMid : WizardColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  final String label;
  final String range;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _QuantityCard({
    required this.label,
    required this.range,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? WizardColors.primaryLight : WizardColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? WizardColors.borderSelected : WizardColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? WizardColors.primaryMid : WizardColors.border,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? WizardColors.primaryMid : WizardColors.textPrimary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    range,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: WizardColors.textSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? WizardColors.primaryBorder : WizardColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? WizardColors.primaryMid : WizardColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceInput extends StatelessWidget {
  final TextEditingController controller;

  const _PriceInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WizardColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WizardColors.border),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: WizardColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: WizardColors.textHint,
          ),
          suffixText: context.l10n.orderCurrencyJD,
          suffixStyle: GoogleFonts.cairo(
            fontSize: 13,
            color: WizardColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.sell_outlined,
            color: WizardColors.primaryMid,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
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
            style: GoogleFonts.cairo(fontSize: 13, color: WizardColors.textSecondary),
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
