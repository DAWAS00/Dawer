import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/driver_earnings_viewmodel.dart';

class DriverEarningsStatScroll extends StatelessWidget {
  final DriverEarningsSummary summary;

  const DriverEarningsStatScroll({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _StatCard(
            label: 'إجمالي الأرباح',
            value: '${summary.totalEarnings.toStringAsFixed(1)} د',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF0A5E3E),
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'عدد الطلبات',
            value: summary.totalOrders.toString(),
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFF1E40AF),
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'نسبة النمو',
            value: '+${summary.netGrowth}%',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF92400E),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
