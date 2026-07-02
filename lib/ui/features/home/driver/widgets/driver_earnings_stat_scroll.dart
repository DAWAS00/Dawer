import 'package:flutter/material.dart';
import '../../../analytics/widgets/kpi_strip.dart';
import '../viewmodels/driver_earnings_viewmodel.dart';

/// Earnings stat row for the driver home. Rebuilt on the shared [KpiStrip]
/// (horizontal scroll, overflow-proof, consistent with the analytics tab).
class DriverEarningsStatScroll extends StatelessWidget {
  final DriverEarningsSummary summary;

  const DriverEarningsStatScroll({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return KpiStrip(
      items: [
        KpiItem(
          label: 'إجمالي الأرباح',
          value: '${summary.totalEarnings.toStringAsFixed(1)} د',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF0A5E3E),
        ),
        KpiItem(
          label: 'عدد الطلبات',
          value: summary.totalOrders.toString(),
          icon: Icons.local_shipping_rounded,
          color: const Color(0xFF1E40AF),
        ),
        KpiItem(
          label: 'نسبة النمو',
          value: '+${summary.netGrowth}%',
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF92400E),
        ),
      ],
    );
  }
}
