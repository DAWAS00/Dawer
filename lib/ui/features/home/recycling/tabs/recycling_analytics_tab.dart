import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order.dart';
import '../../../../../domain/services/carbon_calculator.dart';
import '../viewmodels/recycling_analytics_viewmodel.dart';

class RecyclingAnalyticsTab extends StatelessWidget {
  const RecyclingAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecyclingAnalyticsViewModel>();
    final s = vm.summary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, s)),
          SliverToBoxAdapter(child: _buildCo2Card(context, s)),
          if (s.kgByType.isNotEmpty)
            SliverToBoxAdapter(child: _buildWasteBreakdown(context, s)),
          SliverToBoxAdapter(child: _buildMonthlyChart(context, s)),
          if (s.topSuppliers.isNotEmpty)
            SliverToBoxAdapter(child: _buildTopSuppliers(context, s)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AnalyticsSummary s) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحليلات',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStat(
                  '${s.totalKg.toStringAsFixed(0)} كغ', 'إجمالي الكميات'),
              const SizedBox(width: 12),
              _buildStat(
                  '${s.totalSpendJd.toStringAsFixed(2)} د.أ', 'الإنفاق الكلي'),
              const SizedBox(width: 12),
              _buildStat(s.totalShipments.toString(), 'الشحنات المستلمة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style:
                  GoogleFonts.cairo(fontSize: 10, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCo2Card(BuildContext context, AnalyticsSummary s) {
    if (s.totalCo2Kg <= 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, color: Color(0xFF166534), size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CarbonCalculator.label(s.totalCo2Kg),
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14532D),
                ),
              ),
              Text(
                'CO₂ وُفِّرت من إعادة التدوير',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWasteBreakdown(BuildContext context, AnalyticsSummary s) {
    final sorted = s.kgByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

    return _sectionCard(
      title: 'الكميات حسب نوع النفايات',
      child: Column(
        children: sorted.take(6).map((e) {
          final fraction = max > 0 ? (e.value / max).clamp(0.05, 1.0) : 0.05;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 68,
                  child: Text(
                    e.key.label,
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: const Color(0xFF404943)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F2),
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E6B35),
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 58,
                  child: Text(
                    '${e.value.toStringAsFixed(0)} كغ',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, AnalyticsSummary s) {
    final data = s.monthly;
    final maxWeight = data.fold<double>(
        0, (m, e) => e.weightKg > m ? e.weightKg : m);

    return _sectionCard(
      title: 'الكميات الشهرية (آخر ٦ أشهر)',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((m) {
          final fraction =
              maxWeight > 0 ? (m.weightKg / maxWeight).clamp(0.0, 1.0) : 0.0;
          final barH = (fraction * 80).clamp(4.0, 80.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (m.weightKg > 0)
                    Text(
                      m.weightKg.toStringAsFixed(0),
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: const Color(0xFF404943),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    height: barH,
                    decoration: BoxDecoration(
                      color: m.weightKg > 0
                          ? const Color(0xFF1E6B35)
                          : const Color(0xFFE8F0EA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m.label.substring(0, 3), // first 3 chars of month name
                    style: GoogleFonts.cairo(
                        fontSize: 10, color: const Color(0xFF9099A2)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopSuppliers(BuildContext context, AnalyticsSummary s) {
    return _sectionCard(
      title: 'أكثر الموردين نشاطاً',
      child: Column(
        children: s.topSuppliers.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final name = entry.value.key;
          final spend = entry.value.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? const Color(0xFFFEF9C3)
                        : const Color(0xFFF2F4F2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rank',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: rank == 1
                          ? const Color(0xFF854D0E)
                          : const Color(0xFF404943),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: const Color(0xFF002819)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${spend.toStringAsFixed(2)} د.أ',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
