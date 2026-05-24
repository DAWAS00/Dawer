import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/reward_transaction.dart';

class DriverTransactionTile extends StatelessWidget {
  final RewardTransaction tx;

  const DriverTransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.type.isPositive;

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
              color: isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
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
                  _formatDate(tx.createdAt),
                  style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF9099A2)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : '-'}${(tx.points / 10).toStringAsFixed(2)} د.أ',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? const Color(0xFF166534) : const Color(0xFF991B1B),
                ),
              ),
              Text(
                '${tx.points} نقطة',
                style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF9099A2)),
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
