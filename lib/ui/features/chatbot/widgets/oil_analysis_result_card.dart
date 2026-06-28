import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dwaar/data/models/oil_analysis_result.dart';

/// Rich card displayed in the Dawa chat when Gemini Vision analyzes
/// a user-submitted oil photo. Shown instead of a plain text bubble.
class OilAnalysisResultCard extends StatelessWidget {
  final OilAnalysisResult result;

  const OilAnalysisResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.gradeColor.withValues(alpha: 0.30),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(result: result),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OilConfirmRow(isOil: result.isUsedCookingOil),
                const SizedBox(height: 10),
                _GradeBadge(result: result),
                const SizedBox(height: 12),
                _IndicatorRow(
                  icon: Icons.water_drop_rounded,
                  label: 'محتوى الماء',
                  value: result.waterLabel,
                  valueColor: result.waterColor,
                ),
                const SizedBox(height: 6),
                _IndicatorRow(
                  icon: Icons.warning_amber_rounded,
                  label: 'الشوائب',
                  value: result.impurityLabel,
                  valueColor: result.impurityColor,
                ),
                if (result.estimatedLiters > 0) ...[
                  const SizedBox(height: 6),
                  _IndicatorRow(
                    icon: Icons.local_drink_rounded,
                    label: 'الكمية المقدّرة',
                    value: '~${result.estimatedLiters.toStringAsFixed(1)} لتر',
                    valueColor: const Color(0xFF1E5C35),
                  ),
                ],
                const SizedBox(height: 6),
                _IndicatorRow(
                  icon: Icons.payments_rounded,
                  label: 'السعر المتوقع',
                  value: result.payoutRangeLabel,
                  valueColor: const Color(0xFF1E5C35),
                  bold: true,
                ),
                if (result.explanation.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    result.explanation,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.75) ??
                          Colors.black54,
                      height: 1.65,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final OilAnalysisResult result;
  const _Header({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: result.gradeSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Text('🛢️', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            'تحليل جودة الزيت المستعمل',
            style: GoogleFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: result.gradeColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: result.gradeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Gemini AI',
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: result.gradeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Oil confirmation row ─────────────────────────────────────────────────────

class _OilConfirmRow extends StatelessWidget {
  final bool isOil;
  const _OilConfirmRow({required this.isOil});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isOil ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isOil ? const Color(0xFF1E5C35) : const Color(0xFF991B1B),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          isOil ? 'زيت طبخ مستعمل حقيقي' : 'ليس زيت طبخ مستعمل',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isOil ? const Color(0xFF1E5C35) : const Color(0xFF991B1B),
          ),
        ),
      ],
    );
  }
}

// ── Grade badge ──────────────────────────────────────────────────────────────

class _GradeBadge extends StatelessWidget {
  final OilAnalysisResult result;
  const _GradeBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: result.gradeSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: result.gradeColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Text(
            'الدرجة',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: result.gradeColor.withValues(alpha: 0.70),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            result.gradeLabel,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: result.gradeColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Indicator row ────────────────────────────────────────────────────────────

class _IndicatorRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _IndicatorRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: valueColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.65) ??
                Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
