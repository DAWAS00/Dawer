import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order_arabic_labels.dart';
import '../../../../../data/models/order_enums.dart';
import '../../../../../data/models/reward_transaction.dart';
import '../../../../../domain/services/carbon_calculator.dart';
import '../viewmodels/driver_earnings_viewmodel.dart';

class DriverEarningsTab extends StatelessWidget {
  const DriverEarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverEarningsViewModel>();
    final s = vm.summary;
    final transactions = vm.recentTransactions();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, s)),
          SliverToBoxAdapter(child: _buildCo2Card(context, s)),
          if (s.jdByType.isNotEmpty)
            SliverToBoxAdapter(child: _buildBreakdownChart(context, s)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'آخر العمليات',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
            ),
          ),
          if (transactions.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty(context))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _TransactionTile(tx: transactions[i]),
                childCount: transactions.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EarningsSummary s) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06402B), Color(0xFF0A5E3E)],
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
            'أرباحي',
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
                '${s.totalJd.toStringAsFixed(2)} د.أ',
                'إجمالي الأرباح',
                Icons.payments_rounded,
              ),
              const SizedBox(width: 16),
              _buildStat(
                '${s.totalPoints}',
                'النقاط',
                Icons.stars_rounded,
              ),
              const SizedBox(width: 16),
              _buildStat(
                '${s.completedTrips}',
                'رحلة مكتملة',
                Icons.local_shipping_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCo2Card(BuildContext context, EarningsSummary s) {
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
                'CO₂ وفّرتها من البيئة',
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

  Widget _buildBreakdownChart(BuildContext context, EarningsSummary s) {
    final sorted = s.jdByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = sorted.first.value;

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
            'الأرباح حسب نوع النفايات',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((e) => _buildBar(e.key, e.value, max)),
        ],
      ),
    );
  }

  Widget _buildBar(WasteType type, double jd, double max) {
    final fraction = max > 0 ? (jd / max).clamp(0.05, 1.0) : 0.05;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              type.label,
              style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF404943)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A5E3E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            child: Text(
              '${jd.toStringAsFixed(2)} د',
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
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_rounded, size: 56, color: Color(0xFFCDD5D0)),
          const SizedBox(height: 16),
          Text(
            'لا توجد معاملات بعد',
            style: GoogleFonts.cairo(fontSize: 15, color: const Color(0xFF9099A2)),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});
  final RewardTransaction tx;

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.type.isPositive;
    final dateLabel = _formatDate(tx.createdAt);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 18,
              color: isPositive ? const Color(0xFF166534) : const Color(0xFF991B1B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819),
                  ),
                ),
                Text(
                  dateLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF9099A2),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}${tx.points} نقطة',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPositive
                      ? const Color(0xFF166534)
                      : const Color(0xFF991B1B),
                ),
              ),
              Text(
                tx.type.label,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: const Color(0xFF9099A2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
