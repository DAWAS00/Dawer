import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/order/order.dart';
import '../../../../core/constants/app_colors.dart';

class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.order});

  final Order order;

  String _formatDate(DateTime dt) {
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${dt.day} ${months[dt.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wasteType = order.wasteTypes.firstOrNull ?? WasteType.plastic;
    final color = wasteType.ganttColor;
    final dateStr =
        order.completedAt != null ? _formatDate(order.completedAt!) : '—';
    final weightStr = order.weightKg != null
        ? '${order.weightKg!.toStringAsFixed(1)} كغ'
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.recycling_rounded, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wasteType.label,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '$dateStr · $weightStr',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${order.reward.toStringAsFixed(1)} د.أ',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
