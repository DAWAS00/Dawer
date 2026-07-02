import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'milestone_badge.dart';

/// Horizontal-scrolling strip of milestone badges. Achieved badges come
/// first (full color); locked ones are dimmed and appear at the end.
///
/// Each badge is fixed-width (118px) so the row scrolls cleanly. A progress
/// count (e.g. "3 / 6") is shown in the section header.
class MilestoneStrip extends StatelessWidget {
  const MilestoneStrip({
    super.key,
    required this.totalOrders,
    required this.totalWeightKg,
    required this.totalEarnings,
  });

  final int totalOrders;
  final double totalWeightKg;
  final double totalEarnings;

  List<_Milestone> get _all => [
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
          label: '50 طلبًا',
          description: 'إتمام ٥٠ طلبًا',
          achieved: totalOrders >= 50,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final all = _all;
    final achievedCount = all.where((m) => m.achieved).length;
    // Achieved first, locked after — preserves a stable order within each.
    final sorted = [
      ...all.where((m) => m.achieved),
      ...all.where((m) => !m.achieved),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'إنجازاتي',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$achievedCount / ${all.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final m = sorted[i];
              return SizedBox(
                width: 118,
                child: MilestoneBadge(
                  icon: m.icon,
                  label: m.label,
                  description: m.description,
                  achieved: m.achieved,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
