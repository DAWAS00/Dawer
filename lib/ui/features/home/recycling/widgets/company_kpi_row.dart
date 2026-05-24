import 'package:flutter/material.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';

class CompanyKpiRow extends StatelessWidget {
  const CompanyKpiRow({
    super.key,
    required this.activeJobs,
    required this.totalWeight,
    required this.driversInProgress,
  });

  final int activeJobs;
  final double totalWeight; // in tonnes
  final int driversInProgress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              icon: Icons.assignment_outlined,
              value: '$activeJobs',
              label: 'مهام نشطة',
              iconBg: const Color(0xFFE8F5E9),
              valueColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: Icons.analytics_outlined,
              value: totalWeight > 1000 ? '${(totalWeight/1000).toStringAsFixed(1)}t' : '${totalWeight.round()}kg',
              label: 'تمت معالجته',
              iconBg: const Color(0xFFE3F2FD),
              valueColor: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: Icons.local_shipping_outlined,
              value: '$driversInProgress',
              label: 'سائقين',
              iconBg: AppColors.amberContainer,
              valueColor: AppColors.accentAmber,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.valueColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dt.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: dt.shadow.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: valueColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: dt.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
