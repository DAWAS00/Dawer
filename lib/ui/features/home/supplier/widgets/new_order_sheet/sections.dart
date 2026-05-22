// ignore_for_file: library_private_types_in_public_api
part of '../new_order_sheet.dart';

extension SectionsExt on _NewOrderSheetState {
  List<Widget> buildSections(BuildContext context, AppTokens dt) {
    return [
      _buildHeader(context, dt),
      const SizedBox(height: 20),
      // ── 1. Waste type ──
      _sectionLabel(context.l10n.newOrderWasteTypeLabel, dt),
      const SizedBox(height: 10),
      _wasteTypeChips(dt),
      const SizedBox(height: 20),
      // ── 2. Waste form ──
      _sectionLabel(context.l10n.newOrderWasteFormLabel, dt),
      const SizedBox(height: 10),
      _wasteFormToggle(dt),
      const SizedBox(height: 20),
      // ── 3. Weight ──
      _sectionLabel(context.l10n.newOrderWeightCategoryLabel, dt),
      const SizedBox(height: 10),
      _weightList(dt),
      const SizedBox(height: 20),
      // ── 4. Location ──
      _sectionLabel(context.l10n.newOrderPickupAddressLabel, dt),
      const SizedBox(height: 8),
      _locationPicker(context, dt),
      const SizedBox(height: 20),
      // ── 5. Images + AI ──
      _sectionLabel(context.l10n.newOrderImagesLabel, dt),
      const SizedBox(height: 8),
      _imagesSection(context, dt),
      const SizedBox(height: 20),
      // ── 6. Pickup target ──
      _sectionLabel(context.l10n.newOrderPickupTargetLabel, dt),
      const SizedBox(height: 10),
      _pickupTargetToggle(dt),
      const SizedBox(height: 20),
      // ── 7. Price ──
      Row(children: [
        if (_aiPriceHint != null) _aiPriceChip(dt),
        const Spacer(),
        _sectionLabel(context.l10n.newOrderPriceLabel, dt),
      ]),
      const SizedBox(height: 4),
      Text(
        _pickupTarget == PickupTarget.riderBuy
            ? context.l10n.newOrderPriceHintDriver
            : context.l10n.newOrderPriceHintCompany,
        style: GoogleFonts.cairo(fontSize: 11, color: dt.onSurfaceMuted),
      ),
      const SizedBox(height: 8),
      _priceField(context, dt),
      const SizedBox(height: 20),
      // ── 8. Notes ──
      _sectionLabel(context.l10n.newOrderNotesLabel, dt),
      const SizedBox(height: 8),
      _notesField(dt),
      const SizedBox(height: 20),
      // ── Delivery fee ──
      _deliveryFeeCard(context, dt),
      const SizedBox(height: 28),
      // ── Submit ──
      _submitButton(context, dt),
    ];
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, AppTokens dt) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: dt.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.close_rounded, size: 20, color: dt.onSurfaceMuted),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(context.l10n.newOrderTitle,
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dt.onSurface)),
            Text(context.l10n.newOrderSubtitle,
                style: GoogleFonts.cairo(
                    fontSize: 12, color: dt.onSurfaceMuted)),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF06402B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.recycling_rounded,
              size: 20, color: Color(0xFF06402B)),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, AppTokens dt) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.bold, color: dt.onSurfaceVariant));

  // ── Waste types ──────────────────────────────────────────────────────────────

  Widget _wasteTypeChips(AppTokens dt) {
    final hasError = _attempted && _selected.isEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: hasError
            ? Border.all(color: Colors.red.shade400, width: 1.5)
            : Border.all(color: Colors.transparent),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: _NewOrderSheetState._wasteCategories.map((entry) {
          final (type, icon) = entry;
          final isSel = _selected.contains(type);
          return GestureDetector(
            onTap: () => _updateState(() =>
                isSel ? _selected.remove(type) : _selected.add(type)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF06402B) : dt.surfaceVariant,
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

  // ── Waste form ───────────────────────────────────────────────────────────────

  Widget _wasteFormToggle(AppTokens dt) {
    return Row(
      children: _NewOrderSheetState._wasteFormOptions.reversed.map((entry) {
        final (form, icon) = entry;
        final isSel = _wasteForm == form;
        return Expanded(
          child: GestureDetector(
            onTap: () => _updateState(() => _wasteForm = isSel ? null : form),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                  left: form != _NewOrderSheetState._wasteFormOptions.last.$1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF06402B) : dt.surfaceVariant,
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

  // ── Weight category ──────────────────────────────────────────────────────────

  Widget _weightList(AppTokens dt) {
    return Column(
      children: WeightCategory.values.map((cat) {
        final isSel = _weightCategory == cat;
        final entry = _NewOrderSheetState._weightOptions.firstWhere((e) => e.$1 == cat);
        return GestureDetector(
          onTap: () => _updateState(() => _weightCategory = isSel ? null : cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF06402B) : dt.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isSel ? const Color(0xFF06402B) : dt.border,
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
                width: 36,
                height: 36,
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

  // ── Location ─────────────────────────────────────────────────────────────────

  Widget _locationPicker(BuildContext context, AppTokens dt) {
    final hasError = _attempted && _pickedLat == null;
    return GestureDetector(
      onTap: pickLocation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasError
              ? Colors.red.shade50
              : _pickedLat != null
                  ? const Color(0xFF06402B).withValues(alpha: 0.06)
                  : dt.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError
                ? Colors.red.shade400
                : _pickedLat != null
                    ? const Color(0xFF06402B).withValues(alpha: 0.4)
                    : dt.border,
            width: hasError ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(context.l10n.newOrderSelectButton,
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06402B))),
          ),
          const Spacer(),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(locationLabel,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _pickedLat != null
                          ? const Color(0xFF06402B)
                          : dt.onSurface)),
              Text(context.l10n.newOrderTapToSelectLocation,
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: dt.onSurfaceMuted)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _pickedLat != null
                  ? Icons.location_on_rounded
                  : Icons.add_location_alt_rounded,
              size: 20,
              color: const Color(0xFF06402B),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Images + AI banner ───────────────────────────────────────────────────────

  Widget _imagesSection(BuildContext context, AppTokens dt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_ai.isAnalyzing)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF1E40AF))),
              const SizedBox(width: 10),
              Text(context.l10n.postMarketAiAnalyzing,
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: const Color(0xFF1E40AF))),
            ]),
          ),
        if (_ai.filledFieldLabels.isNotEmpty && !_ai.isAnalyzing)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              if (_ai.hasLowConfidence)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.orange.shade600),
                ),
              const Spacer(),
              Text(
                _ai.hasLowConfidence
                    ? '${context.l10n.postMarketAiFilled} — تحقق من الحقول'
                    : context.l10n.postMarketAiFilled,
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: _ai.hasLowConfidence
                        ? Colors.orange.shade700
                        : const Color(0xFF065F46)),
              ),
              const SizedBox(width: 6),
              Icon(Icons.auto_awesome_rounded,
                  size: 14,
                  color: _ai.hasLowConfidence
                      ? Colors.orange.shade600
                      : const Color(0xFF065F46)),
            ]),
          ),
        ImagePickerGrid(
          imagePaths: _images,
          onAnalyze: runAiAnalysis,
          onAdd: (path) {
            _updateState(() => _images.add(path));
            if (_images.length == 1) runAiAnalysis(path);
          },
          onRemove: (i) => _updateState(() {
            _images.removeAt(i);
            if (_images.isEmpty) {
              _aiPriceHint = null;
              _ai.clearAnalysis();
            }
          }),
        ),
      ],
    );
  }

  // ── Pickup target ────────────────────────────────────────────────────────────

  Widget _pickupTargetToggle(AppTokens dt) {
    return Row(
      children: PickupTarget.values.reversed.map((target) {
        final isSel = _pickupTarget == target;
        final icon = target == PickupTarget.company
            ? Icons.business_rounded
            : Icons.delivery_dining_rounded;
        return Expanded(
          child: GestureDetector(
            onTap: () => _updateState(() => _pickupTarget = target),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                  left: target == PickupTarget.riderBuy ? 8 : 0),
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF06402B) : dt.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSel ? const Color(0xFF06402B) : dt.border,
                    width: isSel ? 2 : 1),
              ),
              child: Column(children: [
                Icon(icon,
                    size: 28,
                    color: isSel ? Colors.white : dt.onSurfaceMuted),
                const SizedBox(height: 8),
                Text(target.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : dt.onSurfaceVariant)),
                if (isSel) ...[
                  const SizedBox(height: 6),
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white.withValues(alpha: 0.8), size: 18),
                ],
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── AI price hint chip ───────────────────────────────────────────────────────

  Widget _aiPriceChip(AppTokens dt) {
    return GestureDetector(
      onTap: () => _updateState(() {
        _priceCtrl.text = _aiPriceHint!.toStringAsFixed(2);
        _aiPriceHint = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF06402B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF06402B).withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'تقدير AI: ~${_aiPriceHint!.toStringAsFixed(2)} د.أ',
            style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF06402B)),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.touch_app_rounded,
              size: 13, color: Color(0xFF06402B)),
        ]),
      ),
    );
  }

  // ── Price field ──────────────────────────────────────────────────────────────

  Widget _priceField(BuildContext context, AppTokens dt) {
    return Container(
      decoration: BoxDecoration(
          color: dt.surfaceVariant, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: _priceCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: GoogleFonts.dmSans(
            fontSize: 16, fontWeight: FontWeight.bold, color: dt.onSurface),
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
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon: Icon(
            _pickupTarget == PickupTarget.riderBuy
                ? Icons.sell_rounded
                : Icons.storefront_rounded,
            color: dt.onSurfaceMuted,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ── Notes field ──────────────────────────────────────────────────────────────

  Widget _notesField(AppTokens dt) {
    return Container(
      decoration: BoxDecoration(
          color: dt.surfaceVariant, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: _notesCtrl,
        maxLines: 3,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 14, color: dt.onSurface),
        decoration: InputDecoration(
          hintText: context.l10n.newOrderNotesHint,
          hintStyle: GoogleFonts.cairo(
              fontSize: 13,
              color: dt.onSurfaceMuted.withValues(alpha: 0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  // ── Delivery fee card ────────────────────────────────────────────────────────

  Widget _deliveryFeeCard(BuildContext context, AppTokens dt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(children: [
        Text(
          '${_deliveryFee.toStringAsFixed(1)} ${context.l10n.orderCurrencyJD}',
          style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC8860A)),
        ),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(context.l10n.newOrderDeliveryFeeLabel,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF92400E))),
          Text(context.l10n.newOrderDeliveryFeeSubtitle,
              style: GoogleFonts.cairo(
                  fontSize: 11, color: const Color(0xFFB45309))),
        ]),
        const SizedBox(width: 12),
        const Icon(Icons.local_shipping_rounded,
            color: Color(0xFFC8860A), size: 22),
      ]),
    );
  }

  // ── Submit button ────────────────────────────────────────────────────────────

  Widget _submitButton(BuildContext context, AppTokens dt) {
    final canSubmit = _selected.isNotEmpty && _pickedLat != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06402B),
          disabledBackgroundColor:
              const Color(0xFF06402B).withValues(alpha: 0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(context.l10n.newOrderSubmitButton,
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canSubmit ? Colors.white : Colors.white60)),
          const SizedBox(width: 8),
          Icon(Icons.send_rounded,
              color: canSubmit ? Colors.white : Colors.white60, size: 20),
        ]),
      ),
    );
  }
}
