import 'package:flutter/material.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/layout/app_layout.dart';

class HomeKpiRow extends StatelessWidget {
  const HomeKpiRow({
    super.key,
    required this.activeCount,
    required this.earnings,
    required this.avgEta,
  });

  final int activeCount;
  final double earnings;
  final int avgEta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              icon: Icons.inventory_2_outlined,
              value: '$activeCount',
              label: 'نشطة',
              iconBg: const Color(0xFFE8F5E9),
              valueColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: Icons.payments_outlined,
              value: earnings.toStringAsFixed(1),
              label: 'دينار',
              iconBg: const Color(0xFFE3F2FD),
              valueColor: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _KpiCard(
              icon: Icons.schedule_outlined,
              value: '$avgEta',
              label: 'دقيقة',
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
    final small = context.layout.isSmall;
    final iconBox = small ? 24.0 : 28.0;
    final valueFontSize = small ? 15.0 : 18.0;

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
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: iconBox * 0.54, color: valueColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: dt.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
