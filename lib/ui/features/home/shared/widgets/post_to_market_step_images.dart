import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../supplier/widgets/image_picker_grid.dart';

class PostMarketStepImages extends StatelessWidget {
  final List<String> imagePaths;
  final bool isAnalyzing;
  final List<String> filledFieldLabels;
  final bool hasLowConfidence;
  final double confidence;
  final double? estimatedWeightKg;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<String> onAnalyze;

  const PostMarketStepImages({
    super.key,
    required this.imagePaths,
    required this.isAnalyzing,
    required this.filledFieldLabels,
    required this.hasLowConfidence,
    required this.confidence,
    required this.estimatedWeightKg,
    required this.onAdd,
    required this.onRemove,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _label('الصور', dt),
          const SizedBox(height: 10),
          ImagePickerGrid(
            imagePaths: imagePaths,
            onAdd: onAdd,
            onRemove: onRemove,
            onAnalyze: onAnalyze,
          ),
          const SizedBox(height: 16),
          if (isAnalyzing) _analyzingBanner(context),
          if (!isAnalyzing && filledFieldLabels.isNotEmpty) ...[
            _filledSummary(),
            if (hasLowConfidence) _confidenceMeter(),
          ],
          if (estimatedWeightKg != null) ...[
            const SizedBox(height: 8),
            _weightBadge(),
          ],
          const SizedBox(height: 12),
          _hint(context, dt),
        ],
      ),
    );
  }

  Widget _label(String text, AppTokens dt) => Text(text,
      style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: dt.onSurfaceVariant));

  Widget _hint(BuildContext context, AppTokens dt) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dt.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(
              child: Text('أضف صورة واحدة على الأقل لتفعيل التحليل التلقائي',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.cairo(
                      fontSize: 12, color: dt.onSurfaceMuted))),
          const SizedBox(width: 8),
          Icon(Icons.info_outline_rounded, size: 16, color: dt.onSurfaceMuted),
        ]),
      );

  Widget _analyzingBanner(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFF1E40AF).withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF1E40AF))),
          const SizedBox(width: 12),
          const Spacer(),
          Text('جارٍ تحليل الصورة...',
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E40AF))),
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome_rounded,
              size: 18, color: Color(0xFF1E40AF)),
        ]),
      );

  Widget _filledSummary() => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF065F46).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF065F46).withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: filledFieldLabels
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF065F46).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(f,
                            style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: const Color(0xFF065F46),
                                fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.check_circle_rounded,
              size: 18, color: Color(0xFF065F46)),
        ]),
      );

  Widget _confidenceMeter() => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: confidence),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: v,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation(confidence >= 0.85
                        ? const Color(0xFF065F46)
                        : confidence >= 0.70
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFB91C1C)),
                    minHeight: 6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.warning_amber_rounded,
                size: 18, color: Color(0xFFF59E0B)),
          ]),
          const SizedBox(height: 6),
          Text('الصورة غير واضحة — تحقق من الحقول قبل النشر',
              textAlign: TextAlign.end,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF92400E),
                  fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _weightBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E40AF).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF1E40AF).withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.scale_rounded, size: 16, color: Color(0xFF1E40AF)),
          const SizedBox(width: 8),
          Text('${estimatedWeightKg!.toStringAsFixed(1)} كغ',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E40AF))),
          const Spacer(),
          Text('الوزن التقديري (AI)',
              style: GoogleFonts.cairo(
                  fontSize: 11, color: const Color(0xFF1E40AF))),
        ]),
      );
}
