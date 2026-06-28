import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// The top-of-tab hero summary: a deep-green gradient card showing one big
/// number (role-chosen), a delta chip vs the previous period, a label, and a
/// mini sparkline drawn from the trend series.
///
/// The value animates up from 0 on first build and whenever [value] changes
/// (e.g. period switch).
class AnalyticsHeroCard extends StatefulWidget {
  const AnalyticsHeroCard({
    super.key,
    required this.value,
    required this.label,
    required this.formatter,
    required this.sparkPoints,
    this.deltaPct,
    this.accentColor = Colors.white,
  });

  /// Raw numeric value to display (e.g. 342.5).
  final double value;

  /// Caption under the value (e.g. "إجمالي الأرباح · هذا الشهر").
  final String label;

  /// Turns the animated double into a display string (e.g. "342.5 د.أ").
  final String Function(double value) formatter;

  /// Sparkline samples, oldest-first. Values are graphed normalized.
  final List<double> sparkPoints;

  /// Optional percentage delta vs previous period. Null hides the chip.
  final double? deltaPct;

  /// Sparkline + delta chip color. Defaults white on the green gradient.
  final Color accentColor;

  @override
  State<AnalyticsHeroCard> createState() => _AnalyticsHeroCardState();
}

class _AnalyticsHeroCardState extends State<AnalyticsHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  double _displayedValue = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _setupAnim(widget.value);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant AnalyticsHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _setupAnim(widget.value);
      _ctrl.forward(from: 0);
    }
  }

  void _setupAnim(double target) {
    final begin = _displayedValue;
    _anim = Tween<double>(begin: begin, end: target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic))
      ..addListener(() {
        setState(() => _displayedValue = _anim.value);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.value > 0 || widget.sparkPoints.isNotEmpty;
    final delta = widget.deltaPct;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delta chip (top-right aligned via Row + Spacer)
          Row(
            children: [
              if (delta != null) _DeltaChip(pct: delta),
              const Spacer(),
              Icon(Icons.insights_rounded,
                  color: Colors.white.withValues(alpha: 0.7), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          if (hasData) ...[
            Text(
              widget.formatter(_displayedValue),
              style: GoogleFonts.dmSans(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(
                  points: widget.sparkPoints,
                  color: widget.accentColor,
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    color: Colors.white.withValues(alpha: 0.6), size: 28),
                const SizedBox(width: 12),
                Text(
                  'لا يوجد نشاط بعد',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(
                  points: const [],
                  color: widget.accentColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.pct});
  final double pct;

  @override
  Widget build(BuildContext context) {
    final isUp = pct >= 0;
    final text = '${isUp ? '+' : ''}${pct.toStringAsFixed(1)}%';
    final color = isUp ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a smooth-ish sparkline from a list of doubles. Empty/1-point lists
/// render a flat baseline so the card never looks broken.
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.points, required this.color});
  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pad = 4.0;

    // Baseline
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, h - pad),
      Offset(w, h - pad),
      basePaint,
    );

    if (points.length < 2) return;

    final maxV = points.reduce(math.max);
    final minV = points.reduce(math.min);
    final span = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    Path line(Path p) {
      for (var i = 0; i < points.length; i++) {
        final x = (i / (points.length - 1)) * w;
        final norm = (points[i] - minV) / span; // 0..1
        final y = (h - pad) - norm * (h - pad * 2);
        if (i == 0) {
          p.moveTo(x, y);
        } else {
          p.lineTo(x, y);
        }
      }
      return p;
    }

    // Filled area under the line
    final area = line(Path())
      ..lineTo(w, h - pad)
      ..lineTo(0, h - pad)
      ..close();
    canvas.drawPath(
      area,
      Paint()..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // The line itself
    canvas.drawPath(
      line(Path()),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points != points || old.color != color;
}
