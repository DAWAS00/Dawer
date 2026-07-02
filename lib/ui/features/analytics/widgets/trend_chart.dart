import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../analytics_viewmodel.dart';

/// Area-chart trend of the hero metric across the selected period.
/// Empty/insufficient data renders a friendly empty state instead of a
/// broken axis.
class TrendChart extends StatelessWidget {
  const TrendChart({
    super.key,
    required this.series,
    required this.color,
    this.periodLabel,
  });

  /// Oldest-first trend points.
  final List<TrendPoint> series;
  final Color color;
  final String? periodLabel;

  @override
  Widget build(BuildContext context) {
    if (series.length < 2) {
      return _EmptyState();
    }

    final maxX = (series.length - 1).toDouble();
    final values = series.map((p) => p.value).toList();
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final minY = values.reduce((a, b) => a < b ? a : b);
    // Pad Y so the line isn't glued to the top/bottom edge.
    final yPad = (maxY - minY) * 0.15 + (maxY == minY ? maxY * 0.1 + 1 : 0);
    final top = maxY + yPad;
    final bottom = (minY - yPad).clamp(0.0, double.infinity).toDouble();

    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 8),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: bottom,
            maxY: top,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (top - bottom) / 3,
              getDrawingHorizontalLine: (v) => FlLine(
                color: AppColors.borderSubtle.withValues(alpha: 0.6),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: (maxX / 4).clamp(1, double.infinity),
                  getTitlesWidget: (value, meta) {
                    final i = value.round();
                    if (i < 0 || i >= series.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _xLabel(series[i].day),
                        style: GoogleFonts.cairo(
                          fontSize: 9,
                          color: AppColors.mutedText,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (var i = 0; i < series.length; i++)
                    FlSpot(i.toDouble(), series[i].value),
                ],
                isCurved: true,
                curveSmoothness: 0.3,
                color: color,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.28),
                      color.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: const LineTouchData(enabled: false),
          ),
        ),
      ),
    );
  }

  String _xLabel(DateTime day) {
    return '${day.day}/${day.month}';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 36, color: AppColors.mutedText.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              'لا يوجد بيانات كافية',
              style: GoogleFonts.cairo(color: AppColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
