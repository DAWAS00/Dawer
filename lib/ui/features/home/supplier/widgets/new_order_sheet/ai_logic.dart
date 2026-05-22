// ignore_for_file: library_private_types_in_public_api
part of '../new_order_sheet.dart';

extension AiLogicExt on _NewOrderSheetState {
  Future<void> runAiAnalysis(String imagePath) async {
    try {
      final result =
          await _ai.analyze(File(imagePath), Localizations.localeOf(context));
      if (!mounted || result == null) return;
      applyAiResult(result);
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final short = raw.length > 140 ? '${raw.substring(0, 140)}…' : raw;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text('${context.l10n.postMarketAiFailed}\n$short',
            style: const TextStyle(color: Colors.white, fontSize: 12)),
        duration: const Duration(seconds: 5),
      ));
    }
  }

  void applyAiResult(MarketAiResult result) {
    final filled = <String>[];
    _updateState(() {
      if (result.wasteTypes.isNotEmpty) {
        _selected
          ..clear()
          ..addAll(result.wasteTypes);
        filled.add(context.l10n.newOrderWasteTypeLabel);
      }
      if (result.wasteForm != null) {
        _wasteForm = result.wasteForm;
        filled.add(context.l10n.newOrderWasteFormLabel);
      }
      if (result.weightCategory != null) {
        _weightCategory = result.weightCategory;
        filled.add(context.l10n.newOrderWeightCategoryLabel);
      }
      if (result.approxPriceJd != null) {
        _aiPriceHint = result.approxPriceJd;
        filled.add(context.l10n.newOrderPriceLabel);
      }
      if (result.note != null && result.note!.isNotEmpty) {
        _notesCtrl.text = result.note!;
        filled.add(context.l10n.newOrderNotesLabel);
      }
    });
    _ai.reportFilledFields(filled);
    if (mounted) {
      final msg = _ai.hasLowConfidence
          ? '${context.l10n.postMarketAiFilled} — تحقق من الحقول'
          : context.l10n.postMarketAiFilled;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.cairo())));
    }
  }
}
