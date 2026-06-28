import 'package:flutter/material.dart';
import 'kpi_card.dart';

class KpiStrip extends StatelessWidget {
  const KpiStrip({
    super.key,
    required this.earningsJd,
    required this.weightKg,
    required this.co2Kg,
    required this.orderCount,
  });

  final double earningsJd;
  final double weightKg;
  final double co2Kg;
  final int orderCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SizedBox(
            width: 140,
            child: KpiCard(
              value: '${earningsJd.toStringAsFixed(1)} د.أ',
              label: 'إجمالي الأرباح',
              icon: Icons.monetization_on_rounded,
              color: const Color(0xFF0F5A34),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: KpiCard(
              value: '${weightKg.toStringAsFixed(0)} كغ',
              label: 'وزن معالج',
              icon: Icons.scale_rounded,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 130,
            child: KpiCard(
              value: '${co2Kg.toStringAsFixed(0)} كغ',
              label: 'CO₂ وُفِّر',
              icon: Icons.eco_rounded,
              color: const Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: KpiCard(
              value: orderCount.toString(),
              label: 'طلبات مكتملة',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
