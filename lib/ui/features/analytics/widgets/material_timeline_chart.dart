import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/order/order.dart';
import '../../../../core/constants/app_colors.dart';

class MaterialTimelineChart extends StatelessWidget {
  const MaterialTimelineChart({
    super.key,
    required this.orders,
    required this.periodStart,
    required this.periodEnd,
    this.onTap,
  });

  final List<Order> orders;
  final DateTime periodStart;
  final DateTime periodEnd;

  /// Tap hook for drill-down (no-op safe when null).
  final VoidCallback? onTap;

  static const double _rowHeight = 32.0;
  static const double _rowSpacing = 6.0;
  static const double _axisHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'لا يوجد نشاط في هذه الفترة',
            style: GoogleFonts.cairo(color: AppColors.mutedText),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalMs = periodEnd.difference(periodStart).inMilliseconds;
        final chartHeight =
            orders.length * (_rowHeight + _rowSpacing) + _axisHeight;

        return RepaintBoundary(
          child: GestureDetector(
            onTap: onTap,
            child: SizedBox(
              height: chartHeight,
              width: availableWidth,
              child: CustomPaint(
                size: Size(availableWidth, chartHeight),
                painter: _GanttPainter(
                  orders: orders,
                  periodStart: periodStart,
                  totalMs: totalMs,
                  rowHeight: _rowHeight,
                  rowSpacing: _rowSpacing,
                  axisHeight: _axisHeight,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GanttPainter extends CustomPainter {
  _GanttPainter({
    required this.orders,
    required this.periodStart,
    required this.totalMs,
    required this.rowHeight,
    required this.rowSpacing,
    required this.axisHeight,
  });

  final List<Order> orders;
  final DateTime periodStart;
  final int totalMs;
  final double rowHeight;
  final double rowSpacing;
  final double axisHeight;

  @override
  void paint(Canvas canvas, Size size) {
    _drawAxisLine(canvas, size);
    _drawDateLabels(canvas, size);
    _drawOrderBars(canvas, size);
  }

  void _drawAxisLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8E5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, axisHeight - 1),
      Offset(size.width, axisHeight - 1),
      paint,
    );
  }

  void _drawDateLabels(Canvas canvas, Size size) {
    const labelCount = 4;
    for (var i = 0; i <= labelCount; i++) {
      final fraction = i / labelCount;
      final x = fraction * size.width;
      final date =
          periodStart.add(Duration(milliseconds: (totalMs * fraction).round()));
      final label = '${date.day}/${date.month}';

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 9,
            fontFamily: 'DM Sans',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, 6));
    }
  }

  void _drawOrderBars(Canvas canvas, Size size) {
    for (var i = 0; i < orders.length; i++) {
      final order = orders[i];
      final created = order.createdAt;
      final completed = order.completedAt!;

      final startFraction =
          created.difference(periodStart).inMilliseconds / totalMs;
      final endFraction =
          completed.difference(periodStart).inMilliseconds / totalMs;

      final barLeft = startFraction.clamp(0.0, 1.0) * size.width;
      final barRight = endFraction.clamp(0.0, 1.0) * size.width;
      const minBarWidth = 6.0;
      final barWidth = (barRight - barLeft).clamp(minBarWidth, size.width);

      final top = axisHeight + i * (rowHeight + rowSpacing);
      final rect = RRect.fromLTRBR(
        barLeft,
        top,
        barLeft + barWidth,
        top + rowHeight,
        const Radius.circular(6),
      );

      final wasteType = order.wasteTypes.firstOrNull ?? WasteType.plastic;
      final paint = Paint()
        ..color = wasteType.ganttColor.withValues(alpha: 0.85);
      canvas.drawRRect(rect, paint);

      if (barWidth > 30) {
        final tp = TextPainter(
          text: TextSpan(
            text: wasteType.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: barWidth - 8);
        tp.paint(canvas, Offset(barLeft + 4, top + (rowHeight - tp.height) / 2));
      }
    }
  }

  @override
  bool shouldRepaint(_GanttPainter old) =>
      old.orders != orders || old.totalMs != totalMs;
}
