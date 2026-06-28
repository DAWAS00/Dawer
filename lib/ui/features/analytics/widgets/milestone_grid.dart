import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'milestone_badge.dart';

class _Milestone {
  const _Milestone({
    required this.icon,
    required this.label,
    required this.description,
    required this.achieved,
  });
  final IconData icon;
  final String label;
  final String description;
  final bool achieved;
}

class MilestoneGrid extends StatelessWidget {
  const MilestoneGrid({
    super.key,
    required this.totalOrders,
    required this.totalWeightKg,
    required this.totalEarnings,
  });

  final int totalOrders;
  final double totalWeightKg;
  final double totalEarnings;

  List<_Milestone> _milestones() => [
        _Milestone(
          icon: Icons.recycling_rounded,
          label: 'أول طلب',
          description: 'أكملت طلبك الأول',
          achieved: totalOrders >= 1,
        ),
        _Milestone(
          icon: Icons.scale_rounded,
          label: '100 كغ',
          description: 'معالجة ١٠٠ كيلوغرام',
          achieved: totalWeightKg >= 100,
        ),
        _Milestone(
          icon: Icons.emoji_events_rounded,
          label: '10 طلبات',
          description: 'إتمام ١٠ طلبات',
          achieved: totalOrders >= 10,
        ),
        _Milestone(
          icon: Icons.local_atm_rounded,
          label: '100 د.أ',
          description: 'أرباح تتجاوز ١٠٠ دينار',
          achieved: totalEarnings >= 100,
        ),
        _Milestone(
          icon: Icons.star_rounded,
          label: '500 كغ',
          description: 'معالجة ٥٠٠ كيلوغرام',
          achieved: totalWeightKg >= 500,
        ),
        _Milestone(
          icon: Icons.workspace_premium_rounded,
          label: '50 طلبات',
          description: 'إتمام ٥٠ طلبًا',
          achieved: totalOrders >= 50,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final milestones = _milestones();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'إنجازاتي',
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
          children: milestones
              .map((m) => MilestoneBadge(
                    icon: m.icon,
                    label: m.label,
                    description: m.description,
                    achieved: m.achieved,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
