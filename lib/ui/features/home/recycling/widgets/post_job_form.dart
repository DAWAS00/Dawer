import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';

/// Pure form-body widget for the collection job sheet.
/// Receives all mutable state and callbacks from [PostJobSheet].
class PostJobFormBody extends StatelessWidget {
  final Set<WasteType> selectedTypes;
  final ValueChanged<WasteType> onToggleType;
  final PaymentModel paymentModel;
  final ValueChanged<PaymentModel> onPaymentModelChanged;
  final TextEditingController priceCtrl;
  final TextEditingController minQtyCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController descriptionCtrl;

  const PostJobFormBody({
    super.key,
    required this.selectedTypes,
    required this.onToggleType,
    required this.paymentModel,
    required this.onPaymentModelChanged,
    required this.priceCtrl,
    required this.minQtyCtrl,
    required this.areaCtrl,
    required this.descriptionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SectionLabel(text: '${l10n.collectionJobRequiredMaterials} *'),
        const SizedBox(height: 10),
        _WasteTypeChips(
          allTypes: WasteTypeIcons.all,
          selectedTypes: selectedTypes,
          onToggle: onToggleType,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: l10n.collectionJobPaymentModelLabel),
        const SizedBox(height: 10),
        _PaymentToggle(
          current: paymentModel,
          onChange: onPaymentModelChanged,
        ),
        const SizedBox(height: 20),
        _SectionLabel(
          text: l10n.collectionJobPriceLabel(paymentModel.unitLabel),
        ),
        const SizedBox(height: 8),
        _FormField(
          controller: priceCtrl,
          hint: paymentModel == PaymentModel.perKg
              ? l10n.collectionJobPricePerKgHint
              : l10n.collectionJobPriceFlatHint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
        ),
        if (paymentModel == PaymentModel.perKg) ...[
          const SizedBox(height: 16),
          _SectionLabel(text: l10n.collectionJobMinQtyLabel),
          const SizedBox(height: 8),
          _FormField(
            controller: minQtyCtrl,
            hint: l10n.collectionJobMinQtyHint,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
        const SizedBox(height: 20),
        _SectionLabel(text: '${l10n.collectionJobCollectionArea} *'),
        const SizedBox(height: 8),
        _FormField(
          controller: areaCtrl,
          hint: l10n.collectionJobAreaHint,
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: '${l10n.collectionJobDescTitle} *'),
        const SizedBox(height: 8),
        _FormField(
          controller: descriptionCtrl,
          hint: l10n.collectionJobDescHint,
          maxLines: 4,
        ),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF404943),
      ),
    );
  }
}

class _WasteTypeChips extends StatelessWidget {
  final List<(WasteType, IconData)> allTypes;
  final Set<WasteType> selectedTypes;
  final ValueChanged<WasteType> onToggle;

  const _WasteTypeChips({
    required this.allTypes,
    required this.selectedTypes,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: allTypes.map((entry) {
        final (type, icon) = entry;
        final isSel = selectedTypes.contains(type);
        return GestureDetector(
          onTap: () => onToggle(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF14401F) : const Color(0xFFF2F4F2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : const Color(0xFF404943),
                  ),
                ),
                const SizedBox(width: 5),
                Icon(icon,
                    size: 13,
                    color: isSel ? Colors.white : const Color(0xFF717973)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentToggle extends StatelessWidget {
  final PaymentModel current;
  final ValueChanged<PaymentModel> onChange;

  const _PaymentToggle({required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleOption(
            label: l10n.collectionJobFlatFeeLabel,
            icon: Icons.payments_rounded,
            isSelected: current == PaymentModel.flatFee,
            onTap: () => onChange(PaymentModel.flatFee),
          ),
          const SizedBox(width: 4),
          _ToggleOption(
            label: l10n.collectionJobPerKgLabel,
            icon: Icons.scale_rounded,
            isSelected: current == PaymentModel.perKg,
            onTap: () => onChange(PaymentModel.perKg),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF14401F) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? Colors.white : const Color(0xFF717973)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF404943),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6E9E7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF6B7280).withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 14 : 12,
          ),
        ),
      ),
    );
  }
}
