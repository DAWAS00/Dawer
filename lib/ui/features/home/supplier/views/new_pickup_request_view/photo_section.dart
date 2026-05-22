// ignore_for_file: library_private_types_in_public_api
part of '../new_pickup_request_view.dart';

extension _PhotoSectionExt on _NewPickupRequestViewState {
  Future<void> _runAiAnalysis(String imagePath) async {
    try {
      final result = await _ai.analyze(File(imagePath), Localizations.localeOf(context));
      if (!mounted || result == null) return;
      _applyAiResult(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text('فشل تحليل الصورة — تحقق من الاتصال وحاول مجدداً',
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  void _applyAiResult(MarketAiResult result) {
    final filled = <String>[];
    _updateState(() {
      if (result.wasteTypes.isNotEmpty) {
        _selectedTypes..clear()..addAll(result.wasteTypes);
        filled.add('نوع المخلفات');
      }
      if (result.wasteForm != null) {
        _wasteForm = result.wasteForm;
        filled.add('حالة المخلفات');
      }
      if (result.weightCategory != null) {
        _weightCategory = result.weightCategory;
        filled.add('الكمية');
      }
      if (result.approxPriceJd != null) {
        _priceCtrl.text = result.approxPriceJd!.toStringAsFixed(2);
        filled.add('السعر');
      }
      if (result.note != null && result.note!.isNotEmpty) {
        _notesCtrl.text = result.note!;
        filled.add('الملاحظات');
      }
    });
    _ai.reportFilledFields(filled);
    if (mounted && filled.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم تعبئة الحقول بواسطة الذكاء الاصطناعي ✓',
            style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Widget _buildPhotoSection() {
    return _SectionCard(
      title: 'صور المخلفات',
      subtitle: 'الذكاء الاصطناعي سيحلل الصورة ويعبّئ الحقول تلقائياً',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImagePickerGrid(
            imagePaths: _images,
            crossAxisCount: 2,
            tileHeight: 140,
            onAdd: (path) {
              _updateState(() => _images.add(path));
              if (_images.length == 1) _runAiAnalysis(path);
            },
            onRemove: (i) {
              _updateState(() {
                _images.removeAt(i);
                if (_images.isEmpty) _ai.clearAnalysis();
              });
            },
            onAnalyze: _runAiAnalysis,
          ),
          const SizedBox(height: 12),
          if (_ai.isAnalyzing) _aiAnalyzingBanner(),
          if (!_ai.isAnalyzing && _ai.filledFieldLabels.isNotEmpty) _aiFilledBanner(),
          _aiHintRow(),
        ],
      ),
    );
  }

  Widget _aiAnalyzingBanner() => Container(
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
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold,
              color: const Color(0xFF1E40AF))),
      const SizedBox(width: 8),
      const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF1E40AF)),
    ]),
  );

  Widget _aiFilledBanner() => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF065F46).withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF065F46).withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      Expanded(
        child: Wrap(spacing: 6, runSpacing: 4, alignment: WrapAlignment.end,
          children: _ai.filledFieldLabels.map((f) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(f, style: GoogleFonts.cairo(fontSize: 11,
                color: const Color(0xFF065F46), fontWeight: FontWeight.bold)),
          )).toList(),
        ),
      ),
      const SizedBox(width: 10),
      const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF065F46)),
    ]),
  );

  Widget _aiHintRow() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Expanded(
        child: Text(
          'أضف صورة واحدة على الأقل لتفعيل التحليل التلقائي — الفريق يراجع النتائج قبل التنفيذ',
          textAlign: TextAlign.end,
          style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)),
        ),
      ),
      const SizedBox(width: 8),
      const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF9CA3AF)),
    ]),
  );
}
