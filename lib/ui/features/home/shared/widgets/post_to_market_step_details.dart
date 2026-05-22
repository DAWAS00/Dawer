import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';

// A quick-select preset: label, waste types to select, optional weight hint.
typedef _Preset = ({String label, List<WasteType> types, WeightCategory? weight});

const List<_Preset> _presets = [
  (label: 'معادن', types: [WasteType.metal], weight: WeightCategory.medium),
  (label: 'بلاستيك', types: [WasteType.plastic], weight: WeightCategory.light),
  (label: 'ورق', types: [WasteType.paper], weight: WeightCategory.light),
  (label: 'إلكترونيات', types: [WasteType.electronics], weight: WeightCategory.medium),
];

class PostMarketStepDetails extends StatelessWidget {
  final Set<WasteType> selected;
  final WasteForm? wasteForm;
  final WeightCategory? weightCategory;
  final TextEditingController priceCtrl;
  final bool attempted;
  final double? aiPriceHint;
  final ValueChanged<WasteType> onWasteTypeToggle;
  final ValueChanged<WasteForm?> onWasteFormSelect;
  final ValueChanged<WeightCategory?> onWeightSelect;
  final VoidCallback onAcceptPriceHint;
  final void Function(List<WasteType> types, WeightCategory? weight) onPresetSelected;

  const PostMarketStepDetails({
    super.key,
    required this.selected,
    required this.wasteForm,
    required this.weightCategory,
    required this.priceCtrl,
    required this.attempted,
    required this.aiPriceHint,
    required this.onWasteTypeToggle,
    required this.onWasteFormSelect,
    required this.onWeightSelect,
    required this.onAcceptPriceHint,
    required this.onPresetSelected,
  });

  static const _wasteFormOptions = [
    (WasteForm.solid, Icons.inventory_2_rounded),
    (WasteForm.liquid, Icons.water_drop_rounded),
    (WasteForm.gas, Icons.air_rounded),
    (WasteForm.mixed, Icons.layers_rounded),
  ];

  static const _weightOptions = [
    (WeightCategory.light, Icons.spa_rounded),
    (WeightCategory.medium, Icons.fitness_center_rounded),
    (WeightCategory.heavy, Icons.luggage_rounded),
    (WeightCategory.veryHeavy, Icons.local_shipping_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Quick presets ──
          _presetsRow(dt),
          const SizedBox(height: 20),
          _label(context.l10n.postMarketWasteTypeLabel, dt),
          const SizedBox(height: 10),
          _wasteTypeChips(dt),
          const SizedBox(height: 24),
          _label(context.l10n.postMarketWasteFormLabel, dt),
          const SizedBox(height: 10),
          _wasteFormToggle(dt),
          const SizedBox(height: 24),
          _label(context.l10n.newOrderWeightCategoryLabel, dt),
          const SizedBox(height: 10),
          _weightList(dt),
          const SizedBox(height: 24),
          // ── Price label + AI hint chip ──
          Row(children: [
            if (aiPriceHint != null) _priceHintChip(),
            const Spacer(),
            _label(context.l10n.postMarketPriceLabel, dt),
          ]),
          const SizedBox(height: 8),
          _priceField(context, dt),
        ],
      ),
    );
  }

  Widget _label(String text, AppTokens dt) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: dt.onSurfaceVariant));

  // ── Quick presets row ──────────────────────────────────────────────────────

  Widget _presetsRow(AppTokens dt) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text('اختيار سريع',
          style: GoogleFonts.cairo(
              fontSize: 12, color: dt.onSurfaceMuted)),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.end,
        children: _presets.map((p) {
          final isActive = p.types.every(selected.contains) &&
              selected.length == p.types.length;
          return GestureDetector(
            onTap: () => onPresetSelected(p.types, p.weight),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF06402B)
                    : dt.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF06402B)
                      : dt.border,
                ),
              ),
              child: Text(p.label,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : dt.onSurfaceVariant)),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  // ── AI price hint chip ─────────────────────────────────────────────────────

  Widget _priceHintChip() {
    return GestureDetector(
      onTap: onAcceptPriceHint,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'تقدير AI: ~${aiPriceHint!.toStringAsFixed(2)} د.أ',
            style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E40AF)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.touch_app_rounded,
              size: 13, color: Color(0xFF1E40AF)),
        ]),
      ),
    );
  }

  // ── Waste type chips ───────────────────────────────────────────────────────

  Widget _wasteTypeChips(AppTokens dt) {
    final hasError = attempted && selected.isEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: hasError
            ? Border.all(color: Colors.red.shade400, width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: WasteTypeIcons.all.map((entry) {
          final (type, icon) = entry;
          final isSel = selected.contains(type);
          return GestureDetector(
            onTap: () => onWasteTypeToggle(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1E40AF) : dt.surfaceVariant,
                borderRadius: BorderRadius.circular(30),
                border: isSel ? null : Border.all(color: dt.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(type.label,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : dt.onSurfaceVariant)),
                const SizedBox(width: 6),
                Icon(icon,
                    size: 15,
                    color: isSel ? Colors.white : dt.onSurfaceMuted),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _wasteFormToggle(AppTokens dt) {
    return Row(
      children: _wasteFormOptions.reversed.map((entry) {
        final (form, icon) = entry;
        final isSel = wasteForm == form;
        return Expanded(
          child: GestureDetector(
            onTap: () => onWasteFormSelect(isSel ? null : form),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                  left: form != _wasteFormOptions.last.$1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1E40AF) : dt.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: isSel ? null : Border.all(color: dt.border),
              ),
              child: Column(children: [
                Icon(icon,
                    size: 22,
                    color: isSel ? Colors.white : dt.onSurfaceMuted),
                const SizedBox(height: 6),
                Text(form.label,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : dt.onSurfaceVariant)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _weightList(AppTokens dt) {
    return Column(
      children: WeightCategory.values.map((cat) {
        final isSel = weightCategory == cat;
        final entry = _weightOptions.firstWhere((e) => e.$1 == cat);
        return GestureDetector(
          onTap: () => onWeightSelect(isSel ? null : cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF1E40AF) : dt.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSel ? const Color(0xFF1E40AF) : dt.border,
                  width: isSel ? 2 : 1),
            ),
            child: Row(children: [
              isSel
                  ? const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20)
                  : Icon(Icons.radio_button_off_rounded,
                      color: dt.border, size: 20),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(cat.shortLabel,
                    style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : dt.onSurface)),
                Text(cat.label,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isSel ? Colors.white70 : dt.onSurfaceMuted)),
              ]),
              const SizedBox(width: 12),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isSel
                      ? Colors.white.withValues(alpha: 0.15)
                      : dt.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(entry.$2,
                    size: 18,
                    color: isSel ? Colors.white : dt.onSurfaceMuted),
              ),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _priceField(BuildContext context, AppTokens dt) {
    return Container(
      decoration: BoxDecoration(
          color: dt.surfaceVariant,
          borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: priceCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: dt.onSurface),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: GoogleFonts.dmSans(
              fontSize: 16,
              color: dt.onSurfaceMuted.withValues(alpha: 0.4)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(context.l10n.orderCurrencyJD,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: dt.onSurfaceMuted)),
          ),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon:
              Icon(Icons.sell_rounded, color: dt.onSurfaceMuted, size: 20),
        ),
      ),
    );
  }
}
