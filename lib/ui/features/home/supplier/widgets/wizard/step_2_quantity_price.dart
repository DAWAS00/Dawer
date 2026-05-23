import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../data/models/order.dart';
import '../../controllers/publish_form_controller.dart';

class Step2QuantityAndPrice extends StatelessWidget {
  final PublishFormController controller;

  const Step2QuantityAndPrice({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _StepHeader(
            title: 'تفاصيل المادة',
            subtitle: 'حدد الكمية والحالة والسعر المطلوب',
          ),
          const _FieldLabel(text: 'حالة المواد *'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: WasteForm.values.map((form) {
              final isSelected = controller.wasteForm == form;
              return _ConditionChip(
                label: form.label,
                icon: Icons.layers_outlined, // Fallback icon
                selected: isSelected,
                onTap: () => controller.selectWasteForm(form),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const _FieldLabel(text: 'حجم الكمية *'),
          const SizedBox(height: 10),
          ...WeightCategory.values.map((cat) {
            final isSelected = controller.weightCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _QuantityCard(
                label: cat.shortLabel,
                range: cat.label,
                icon: Icons.fitness_center_outlined, // Fallback icon
                selected: isSelected,
                onTap: () => controller.selectWeightCategory(cat),
              ),
            );
          }),
          const SizedBox(height: 24),
          const _FieldLabel(text: 'السعر المطلوب (د.أ) — اختياري'),
          const SizedBox(height: 10),
          _PriceInput(controller: controller.priceCtrl),
          const SizedBox(height: 24),
        ],
      ),
    );
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
          color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
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
                color: selected ? const Color(0xFF2E7D32) : const Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 16,
              color: selected ? const Color(0xFF2E7D32) : const Color(0xFF6B6B6B),
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
          color: selected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xFF2E7D32),
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
                      color: selected ? const Color(0xFF2E7D32) : const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    range,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFA5D6A7) : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? const Color(0xFF2E7D32) : const Color(0xFF6B6B6B),
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
          color: const Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFAAAAAA),
          ),
          suffixText: 'دينار',
          suffixStyle: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF6B6B6B),
          ),
          prefixIcon: const Icon(
            Icons.sell_outlined,
            color: Color(0xFF2E7D32),
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
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF6B6B6B)),
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
          color: const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}
