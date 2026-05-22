part of '../new_pickup_request_view.dart';

extension _WasteSectionsExt on _NewPickupRequestViewState {
  static const List<(WasteForm, IconData)> _wasteFormOptions = [
    (WasteForm.solid, Icons.inventory_2_rounded),
    (WasteForm.liquid, Icons.water_drop_rounded),
    (WasteForm.mixed, Icons.blender_rounded),
  ];

  static const List<(WeightCategory, IconData)> _weightOptions = [
    (WeightCategory.light, Icons.spa_rounded),
    (WeightCategory.medium, Icons.fitness_center_rounded),
    (WeightCategory.heavy, Icons.luggage_rounded),
    (WeightCategory.veryHeavy, Icons.local_shipping_rounded),
  ];

  // ── Section 1: Waste types ───────────────────────────────────────────────

  Widget _buildSection1WasteTypes() {
    return _SectionCard(
      title: 'نوع المخلفات *',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_selectedTypes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('اختر نوعاً أو أكثر',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9CA3AF))),
            ),
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.end,
            children: WasteTypeIcons.all.map((entry) {
              final (type, icon) = entry;
              final isSelected = _selectedTypes.contains(type);
              return GestureDetector(
                onTap: () => _updateState(() {
                  if (isSelected) {
                    _selectedTypes.remove(type);
                  } else {
                    _selectedTypes.add(type);
                    if (_showTypeError) _showTypeError = false;
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF06402B) : const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(30),
                    border: isSelected ? null : Border.all(color: const Color(0xFFE6E9E7)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(type.label,
                        style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF404943))),
                    const SizedBox(width: 6),
                    Icon(icon, size: 15,
                        color: isSelected ? Colors.white : const Color(0xFF717973)),
                  ]),
                ),
              );
            }).toList(),
          ),
          if (_showTypeError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('يرجى اختيار نوع المخلفات',
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.red)),
            ),
        ],
      ),
    );
  }

  // ── Section 2: Waste form ────────────────────────────────────────────────

  Widget _buildSection2WasteForm() {
    return _SectionCard(
      title: 'حالة المخلفات',
      child: Row(
        children: _wasteFormOptions.reversed.map((entry) {
          final (form, icon) = entry;
          final isSelected = _wasteForm == form;
          return Expanded(
            child: GestureDetector(
              onTap: () => _updateState(() => _wasteForm = isSelected ? null : form),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(left: form != WasteForm.mixed ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF06402B) : const Color(0xFFF2F4F2),
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected ? null : Border.all(color: const Color(0xFFE6E9E7)),
                ),
                child: Column(children: [
                  Icon(icon, size: 22,
                      color: isSelected ? Colors.white : const Color(0xFF717973)),
                  const SizedBox(height: 6),
                  Text(form.label,
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF404943))),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section 3: Weight category ────────────────────────────────────────────

  Widget _buildSection3WeightCategory() {
    return _SectionCard(
      title: 'الكمية التقديرية',
      child: Column(
        children: _weightOptions.map((entry) {
          final (cat, icon) = entry;
          final isSelected = _weightCategory == cat;
          return GestureDetector(
            onTap: () => _updateState(() => _weightCategory = isSelected ? null : cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF06402B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFF06402B) : const Color(0xFFE6E9E7),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(children: [
                isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                    : const Icon(Icons.radio_button_off_rounded,
                        color: Color(0xFFBBBFBD), size: 20),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(cat.shortLabel,
                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF002819))),
                  Text(cat.label,
                      style: GoogleFonts.cairo(fontSize: 11,
                          color: isSelected ? Colors.white70 : const Color(0xFF717973))),
                ]),
                const SizedBox(width: 12),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.15)
                        : const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF717973)),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
