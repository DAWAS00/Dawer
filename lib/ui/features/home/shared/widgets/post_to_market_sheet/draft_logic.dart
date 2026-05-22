// ignore_for_file: library_private_types_in_public_api
part of '../post_to_market_sheet.dart';

extension DraftLogicExt on _PostToMarketSheetState {
  void loadDraft() {
    final draft = widget.localStore.readMarketDraft();
    if (draft == null) return;
    _updateState(() {
      final rawTypes = draft['wasteTypes'];
      if (rawTypes is List) {
        _selected.addAll(rawTypes
            .whereType<String>()
            .map((s) => WasteType.values.where((e) => e.name == s).firstOrNull)
            .whereType<WasteType>());
      }
      final rawForm = draft['wasteForm'] as String?;
      if (rawForm != null) {
        _wasteForm = WasteForm.values.where((e) => e.name == rawForm).firstOrNull;
      }
      final rawWeight = draft['weightCategory'] as String?;
      if (rawWeight != null) {
        _weightCategory =
            WeightCategory.values.where((e) => e.name == rawWeight).firstOrNull;
      }
      final price = draft['price'] as String?;
      if (price != null && price.isNotEmpty) _priceCtrl.text = price;
      final notes = draft['notes'] as String?;
      if (notes != null && notes.isNotEmpty) _notesCtrl.text = notes;
      if (_selected.isNotEmpty ||
          _wasteForm != null ||
          _weightCategory != null ||
          price != null ||
          notes != null) {
        _isDirty = true;
      }
    });
  }

  void saveDraft() {
    if (!_isDirty) return;
    widget.localStore.writeMarketDraft({
      'wasteTypes': _selected.map((t) => t.name).toList(),
      if (_wasteForm != null) 'wasteForm': _wasteForm!.name,
      if (_weightCategory != null) 'weightCategory': _weightCategory!.name,
      if (_priceCtrl.text.trim().isNotEmpty) 'price': _priceCtrl.text.trim(),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
    });
  }

  void clearDraft() => widget.localStore.clearMarketDraft();
}
