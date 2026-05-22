part of '../order_form_view.dart';

extension _Step1Ext on _OrderFormViewState {
  static const _wasteFormOpts = [
    (WasteForm.solid, Icons.inventory_2_rounded, 'صلب'),
    (WasteForm.liquid, Icons.water_drop_rounded, 'سائل'),
    (WasteForm.mixed, Icons.blender_rounded, 'مختلط'),
  ];

  static const _weightOpts = [
    (WeightCategory.light, Icons.spa_rounded),
    (WeightCategory.medium, Icons.fitness_center_rounded),
    (WeightCategory.heavy, Icons.luggage_rounded),
    (WeightCategory.veryHeavy, Icons.local_shipping_rounded),
  ];

  Widget _buildStep1(OrderFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RoleBanner(supplierType: widget.supplierType, userName: widget.userName),
          _buildPhotoCard(vm),
          _buildWasteTypesCard(vm),
          _buildWasteFormCard(vm),
          _buildWeightCard(vm),
        ],
      ),
    );
  }

  // ── Photo + AI ────────────────────────────────────────────────────────────

  Widget _buildPhotoCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'صور المخلفات',
      subtitle: 'الذكاء الاصطناعي سيحلل الصورة ويعبّئ الحقول تلقائياً',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ImagePickerGrid(
          imagePaths: vm.images,
          crossAxisCount: 2,
          tileHeight: 140,
          onAdd: (path) async {
            vm.addImage(path);
            if (vm.images.length == 1) await _runAiAnalysis(path, vm);
          },
          onRemove: vm.removeImage,
          onAnalyze: (path) => _runAiAnalysis(path, vm),
        ),
        const SizedBox(height: 10),
        if (_vm.ai.isAnalyzing) _analyzingBanner(),
        if (!_vm.ai.isAnalyzing && _vm.ai.filledFieldLabels.isNotEmpty) _filledBanner(vm),
        _aiHint(),
      ]),
    );
  }

  Future<void> _runAiAnalysis(String path, OrderFormViewModel vm) async {
    try {
      final result = await vm.ai.analyze(File(path), Localizations.localeOf(context));
      if (!mounted || result == null) return;
      final filled = vm.applyAiResult(result);
      vm.ai.reportFilledFields(filled);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل تحليل الصورة — حاول مجدداً', style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  Widget _analyzingBanner() => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF1E40AF).withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      const SizedBox(width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E40AF))),
      const SizedBox(width: 12),
      const Spacer(),
      Text('جارٍ تحليل الصورة بالذكاء الاصطناعي...',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF))),
      const SizedBox(width: 8),
      const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF1E40AF)),
    ]),
  );

  Widget _filledBanner(OrderFormViewModel vm) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF065F46).withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF065F46).withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF065F46)),
      const SizedBox(width: 10),
      Expanded(child: Wrap(spacing: 6, runSpacing: 4, alignment: WrapAlignment.end,
        children: vm.ai.filledFieldLabels.map((f) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFF065F46).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20)),
          child: Text(f, style: GoogleFonts.cairo(fontSize: 11,
              color: const Color(0xFF065F46), fontWeight: FontWeight.bold)),
        )).toList())),
    ]),
  );

  Widget _aiHint() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Expanded(child: Text('أضف صورة لتفعيل التحليل التلقائي بالذكاء الاصطناعي',
          textAlign: TextAlign.end,
          style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)))),
      const SizedBox(width: 8),
      const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF9CA3AF)),
    ]),
  );

  // ── Waste Types ───────────────────────────────────────────────────────────

  Widget _buildWasteTypesCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'نوع المخلفات *',
      hasError: vm.errors.containsKey('wasteTypes'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Wrap(
          spacing: 8, runSpacing: 8, alignment: WrapAlignment.end,
          children: WasteTypeIcons.all.map((entry) {
            final (type, icon) = entry;
            final sel = vm.wasteTypes.contains(type);
            return Semantics(
              label: type.label,
              selected: sel,
              button: true,
              child: GestureDetector(
                onTap: () => vm.toggleWasteType(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF06402B) : const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(30),
                    border: sel ? null : Border.all(color: const Color(0xFFE6E9E7)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(type.label,
                        style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : const Color(0xFF404943))),
                    const SizedBox(width: 6),
                    Icon(icon, size: 15, color: sel ? Colors.white : const Color(0xFF717973)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
        if (vm.errors.containsKey('wasteTypes'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.errors['wasteTypes']!,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.red)),
          ),
      ]),
    );
  }

  // ── Waste Form ────────────────────────────────────────────────────────────

  Widget _buildWasteFormCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'حالة المخلفات',
      child: Row(
        children: _wasteFormOpts.reversed.map((entry) {
          final (form, icon, label) = entry;
          final sel = vm.wasteForm == form;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setWasteForm(sel ? null : form),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(left: form != WasteForm.mixed ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF06402B) : const Color(0xFFF2F4F2),
                  borderRadius: BorderRadius.circular(14),
                  border: sel ? null : Border.all(color: const Color(0xFFE6E9E7)),
                ),
                child: Column(children: [
                  Icon(icon, size: 22, color: sel ? Colors.white : const Color(0xFF717973)),
                  const SizedBox(height: 6),
                  Text(label, style: GoogleFonts.cairo(fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: sel ? Colors.white : const Color(0xFF404943))),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Weight Category ───────────────────────────────────────────────────────

  Widget _buildWeightCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'الكمية التقديرية',
      child: Column(
        children: _weightOpts.map((entry) {
          final (cat, icon) = entry;
          final sel = vm.weightCategory == cat;
          return GestureDetector(
            onTap: () => vm.setWeightCategory(sel ? null : cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFF06402B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? const Color(0xFF06402B) : const Color(0xFFE6E9E7),
                    width: sel ? 2 : 1),
              ),
              child: Row(children: [
                sel
                    ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                    : const Icon(Icons.radio_button_off_rounded, color: Color(0xFFBBBFBD), size: 20),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(cat.shortLabel,
                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold,
                          color: sel ? Colors.white : const Color(0xFF002819))),
                  Text(cat.label,
                      style: GoogleFonts.cairo(fontSize: 11,
                          color: sel ? Colors.white70 : const Color(0xFF717973))),
                ]),
                const SizedBox(width: 12),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: sel ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: sel ? Colors.white : const Color(0xFF717973)),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}
