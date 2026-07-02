import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dwaar/data/models/waste_analysis_result.dart';

/// Rich card displayed in the Dawa chat when Gemini Vision analyzes a
/// user-submitted photo of ANY recyclable material — oil, wood, plastic,
/// metal, electronics, and more. Shown instead of a plain text bubble.
class WasteAnalysisResultCard extends StatelessWidget {
  final WasteAnalysisResult result;

  const WasteAnalysisResultCard({super.key, required this.result});

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
                _RecyclabilityRow(result: result),
                const SizedBox(height: 10),
                _GradeBadge(result: result),
                const SizedBox(height: 12),
                if (result.estimatedQuantity > 0) ...[
                  _MetricRow(
                    icon: Icons.scale_rounded,
                    label: 'الكمية المقدّرة',
                    value: result.quantityLabel,
                    valueColor: const Color(0xFF1E5C35),
                  ),
                  const SizedBox(height: 6),
                ],
                _MetricRow(
                  icon: Icons.payments_rounded,
                  label: 'السعر المتوقع',
                  value: result.payoutRangeLabel,
                  valueColor: result.hasEstimatedPayout
                      ? const Color(0xFF1E5C35)
                      : const Color(0xFF991B1B),
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
                      color:
                          Theme.of(context).textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.75) ??
                          Colors.black54,
                      height: 1.65,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
                if (result.recycleTips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...result.recycleTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color:
                                    Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.70) ??
                                    Colors.black54,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final WasteAnalysisResult result;
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
          Text(result.materialIcon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.materialType.isNotEmpty
                  ? result.materialType
                  : 'تحليل المواد القابلة للتدوير',
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: result.gradeColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
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

// ── Recyclability row ─────────────────────────────────────────────────────────

class _RecyclabilityRow extends StatelessWidget {
  final WasteAnalysisResult result;
  const _RecyclabilityRow({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isRecyclable
        ? const Color(0xFF1E5C35)
        : const Color(0xFF991B1B);
    return Row(
      children: [
        Icon(
          result.isRecyclable
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          result.isRecyclable ? 'مادة قابلة للتدوير' : 'غير قابلة للتدوير',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Grade badge ───────────────────────────────────────────────────────────────

class _GradeBadge extends StatelessWidget {
  final WasteAnalysisResult result;
  const _GradeBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: result.gradeSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: result.gradeColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            'درجة الجودة',
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

// ── Metric row ────────────────────────────────────────────────────────────────

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _MetricRow({
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
            color:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.65) ??
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
